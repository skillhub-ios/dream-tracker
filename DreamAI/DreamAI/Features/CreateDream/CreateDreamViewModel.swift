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
    @Published var selectedMood: Mood?
    @Published var isButtonDisabled: Bool = true
    @Published var isRecording: Bool = false
    @Published var showPermissionAlert: Bool = false
    @Published var permissionAlertMessage: String = ""
    @Published var interpretationModel: Interpretation?
    @Published var currentDream: Dream?
    @Published var buttonState: DButtonState = .normal
    
    // Track text that existed before recording started
    private var textBeforeRecording: String = ""
    
    // MARK: - Dependencies
    private let speechRecognizer: SpeechRecognizing = SpeechRecognizerManager.shared
    private let dreamInterpreter = DIContainer.dreamInterpreter
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribers()
    }
    
    // MARK: - Methods
        
    func toggleRecording() async {
        print("🔊 ViewModel: toggleRecording called, isRecording: \(isRecording)")
        if isRecording {
            speechRecognizer.stopRecording()
            await MainActor.run {
                isRecording = false
                print("🔊 ViewModel: Recording stopped, calling finalizeTranscription")
                // Finalize the transcription when recording stops
                finalizeTranscription()
            }
        } else {
            await startRecording()
        }
    }
    
    private func startRecording() async {
        print("🔊 ViewModel: startRecording called")
        
        // Save the current text before recording starts
        textBeforeRecording = dreamText
        
        await speechRecognizer.startRecording()
        
        // Update UI state based on speech recognizer state
        await MainActor.run {
            isRecording = speechRecognizer.isRecording
            print("🔊 ViewModel: isRecording set to \(isRecording)")
            
            // If there was an error, show the alert
            if let errorMessage = speechRecognizer.errorMessage {
                print("🔊 ViewModel: Error message - \(errorMessage)")
                permissionAlertMessage = errorMessage
                showPermissionAlert = true
            }
        }
    }
    
    func finalizeTranscription() {
        // This method should be called when recording stops to get the final transcription
        let transcribedText = speechRecognizer.transcribedText
        print("🔊 Finalizing transcription: '\(transcribedText)'")
        
        if !transcribedText.isEmpty {
            // Since we're showing real-time updates, the dreamText should already contain
            // the transcribed text. We only need to append if there was existing text
            // before this recording session started.
            
            // For now, just clear the transcribed text since the UI is already updated
            print("🔊 Transcription finalized, UI already updated")
        }
        
        // Clear the transcribed text after finalizing
        speechRecognizer.clearTranscribedText()
    }
    
    private func updateTextInRealTime() {
        // Update the UI text in real-time as speech is recognized
        let transcribedText = speechRecognizer.transcribedText
        print("🔊 Real-time update: '\(transcribedText)'")
        
        if !transcribedText.isEmpty {
            // Combine the text that existed before recording with the new transcribed text
            let newText: String
            if !textBeforeRecording.isEmpty {
                newText = textBeforeRecording + " " + transcribedText
            } else {
                newText = transcribedText
            }
            
            print("🔊 Updating UI text to: '\(newText)'")
            DispatchQueue.main.async {
                self.dreamText = newText
            }
        }
    }
    
    func createDream() {
        let newDream = Dream(
            emoji: generateRandomEmoji(),
            emojiBackground: generateRandomColor(),
            title: String(dreamText.prefix(30)),
            tags: [],
            date: selectedDate,
            description: dreamText
        )
        addDream(newDream)
        currentDream = newDream
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
                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.isButtonDisabled, on: self)
            .store(in: &cancellables)
        
        UserManager.shared.$isSubscribed
            .receive(on: DispatchQueue.main)
            .map { isSubscribed in
                return isSubscribed ? .normal : .locked
            }
            .assign(to: \.buttonState, on: self)
            .store(in: &cancellables)
        
        // Subscribe to speech recognizer updates to show text in real-time
        NotificationCenter.default.publisher(for: .speechRecognizerDidUpdateText)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🔊 ViewModel: Received speechRecognizerDidUpdateText notification")
                self?.updateTextInRealTime()
            }
            .store(in: &cancellables)
    }
    
    private func addDream(_ dream: Dream) {
        NotificationCenter.default.post(
            name: Notification.Name(PublisherKey.addDream.rawValue),
            object: nil,
            userInfo: ["value": dream]
        )
    }
}
