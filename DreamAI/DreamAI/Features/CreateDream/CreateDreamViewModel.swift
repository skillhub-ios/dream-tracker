//
//  CreateDreamViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI
import Combine

class CreateDreamViewModel: ObservableObject {
    
    // MARK: - PROPERTIES
    @Published var selectedDate: Date = Date()
    @Published var dreamText = ""
    @Published var selectedMood: Mood? = .calm
    @Published var isButtonDisabled: Bool = true
    @Published var isRecording: Bool = false
    @Published var showPermissionAlert: Bool = false
    @Published var permissionAlertMessage: String = ""
    
    // MARK: - Dependencies
    private let speechRecognizer: SpeechRecognizing = SpeechRecognizerManager.shared
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
            await startRecording()
        }
    }
    
    private func startRecording() async {
        await speechRecognizer.startRecording()
        
        // Update UI state based on speech recognizer state
        await MainActor.run {
            isRecording = speechRecognizer.isRecording
            
            // If there was an error, show the alert
            if let errorMessage = speechRecognizer.errorMessage {
                permissionAlertMessage = errorMessage
                showPermissionAlert = true
            }
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
