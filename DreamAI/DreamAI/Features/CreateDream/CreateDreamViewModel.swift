//
//  CreateDreamViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI
import Combine
import AVFoundation

@MainActor
class CreateDreamViewModel: ObservableObject {
    
    // MARK: - PROPERTIES
    @Published var selectedDate: Date = Date()
    @Published var dreamText = ""
    @Published var selectedMood: Mood? = .calm
    @Published var isButtonDisabled: Bool = true
    @Published var isRecording: Bool = false
    @Published var showPermissionAlert: Bool = false
    @Published var permissionAlertMessage: String = ""
    @Published var interpretationModel: DreamInterpretationFullModel?
    
    // MARK: - Dependencies
    private let speechRecognizer: SpeechRecognizing = SpeechRecognizerManager.shared
    private let dreamManager = DreamManager.shared
    private let openAIManager = OpenAIManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.selectedMood = Mood.allCases.randomElement()
        subscribers()
    }

    // MARK: - Methods
    func toggleRecording() async {
        if isRecording {
            speechRecognizer.stopRecording()
            await MainActor.run {
                isRecording = false
            }
        } else {
            let hasPermission = await checkAndRequestMicrophonePermission()
            if hasPermission {
                do {
                    try await speechRecognizer.startRecording()
                    await MainActor.run {
                        isRecording = speechRecognizer.isRecording
                        
                        // If there was an error, show the alert
                        if let errorMessage = speechRecognizer.errorMessage {
                            permissionAlertMessage = errorMessage
                            showPermissionAlert = true
                        }
                    }
                } catch {
                    // Handle start recording error
                }
            } else {
                permissionAlertMessage = "Microphone permission is required to record your dream."
                showPermissionAlert = true
            }
        }
    }
    
    private func checkAndRequestMicrophonePermission() async -> Bool {
        let status = AVAudioSession.sharedInstance().recordPermission
        if status == .granted {
            return true
        } else if status == .undetermined {
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        } else {
            return false
        }
    }
    
    func updateDreamText() {
        // Update the dream text with the transcribed text
        if !speechRecognizer.transcribedText.isEmpty {
            // If there's existing text, append with a space
            if !dreamText.isEmpty {
                let newText = dreamText + " " + speechRecognizer.transcribedText
                DispatchQueue.main.async {
                    self.dreamText = newText
                }
            } else {
                DispatchQueue.main.async {
                    self.dreamText = self.speechRecognizer.transcribedText
                }
            }
            
            // Reset the transcribed text
            speechRecognizer.reset()
        }
    }

    func generateDream() async -> (UUID, DreamInterpretationFullModel?) {
        let newDream = Dream(
            emoji: generateRandomEmoji(),
            emojiBackground: generateRandomColor(),
            title: String(dreamText.prefix(30)),
            tags: generateRandomTags(),
            date: selectedDate
        )
        dreamManager.addDream(newDream)
        
        do {
            let interpretation = try await openAIManager.getDreamInterpretation(
                dreamText: dreamText,
                mood: selectedMood?.rawValue,
                tags: []
            )
            self.interpretationModel = interpretation
            return (newDream.id, interpretation)
        } catch {
            print("Failed to get interpretation: \(error)")
            // Handle error appropriately
            return (newDream.id, nil)
        }
    }
    
    private func generateRandomEmoji() -> String {
        let emojis = ["😴", "🌙", "✨", "🌟", "💫", "🌈", "☁️", "🦋", "🎭", "🎪"]
        return emojis.randomElement() ?? "😴"
    }
    
    private func generateRandomColor() -> Color {
        let colors: [Color] = [.appPurple, .appBlue, .appGreen, .appOrange, .appRed]
        return colors.randomElement() ?? .appPurple
    }
    
    private func generateRandomTags() -> [Tags] {
        let allTags = Tags.allCases
        let numberOfTags = Int.random(in: 1...3)
        return Array(allTags.shuffled().prefix(numberOfTags))
    }

    private func subscribers() {
        Publishers.CombineLatest3($selectedDate, $dreamText, $selectedMood)
            .map { date, text, mood in
                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || mood == nil
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isButtonDisabled, on: self)
            .store(in: &cancellables)
        
        // Subscribe to speech recognizer's transcribed text
        NotificationCenter.default.publisher(for: .init("SpeechRecognizerDidUpdateText"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateDreamText()
            }
            .store(in: &cancellables)
    }
}
