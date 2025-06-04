import Foundation
import Speech
import CoreData

class DreamCreationViewModel: ObservableObject {
    @Published var dreamContent = ""
    @Published var selectedMood: Mood = .neutral
    @Published var selectedTags: [String] = []
    @Published var interpretation: DreamInterpretation?
    @Published var isRecording = false
    @Published var showingError = false
    @Published var error: Error?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let openAIService = OpenAIService(apiKey: Constants.openAIKey)
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.startRecordingSession()
                case .denied, .restricted, .notDetermined:
                    self?.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет доступа к микрофону"])
                    self?.showingError = true
                @unknown default:
                    break
                }
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    private func startRecordingSession() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Распознавание речи недоступно"])
            showingError = true
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    self.dreamContent = result.bestTranscription.formattedString
                }
                
                if error != nil {
                    self.stopRecording()
                }
            }
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
            
        } catch {
            self.error = error
            showingError = true
        }
    }
    
    func removeTag(_ tag: String) {
        selectedTags.removeAll { $0 == tag }
    }
    
//    @MainActor
//    func interpretDream() async {
//        do {
//            interpretation = try await openAIService.interpretDream(
//                dream: dreamContent,
//                mood: selectedMood.name,
//                tags: selectedTags
//            )
//        } catch {
//            self.error = error
//            showingError = true
//        }
//    }
    
    @MainActor
    func saveDream(interpretation: DreamInterpretation? = nil) async {
        let dream = DreamEntry(context: context)
        dream.id = UUID()
        
        // Проверяем содержимое сна
        print("Сохраняем содержимое сна: '\(dreamContent)'")
        if dreamContent.isEmpty {
            print("ВНИМАНИЕ: Содержимое сна пустое!")
        }
        
        dream.content = dreamContent
        dream.date = Date()
        
        // Сохраняем настроение с эмодзи
        let moodWithEmoji = "\(selectedMood.emoji) \(selectedMood.name)"
        print("Сохраняем настроение: \(moodWithEmoji)")
        dream.mood = moodWithEmoji
        
        dream.tags = selectedTags as NSArray
        dream.isSynced = false
        dream.createdAt = Date()
        dream.updatedAt = Date()
        
        if let interpretation = interpretation {
            dream.setInterpretation(interpretation)
        }
        
        do {
            try context.save()
            print("Сон успешно сохранен: '\(dream.content ?? "")'")
            print("Сохраненное настроение: \(dream.mood ?? "")")
        } catch {
            self.error = error
            showingError = true
            print("Ошибка при сохранении сна: \(error)")
        }
    }
}

enum Mood: String, CaseIterable {
    case happy = "Счастливый"
    case sad = "Грустный"
    case neutral = "Нейтральный"
    case anxious = "Тревожный"
    case excited = "Возбужденный"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .neutral: return "😐"
        case .anxious: return "😰"
        case .excited: return "🤩"
        }
    }
    
    var name: String { rawValue }
} 
