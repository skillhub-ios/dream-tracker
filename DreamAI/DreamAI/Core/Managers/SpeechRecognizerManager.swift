//
//  SpeechRecognizerManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Speech
import AVFoundation
import Combine

protocol SpeechRecognizing {
    var isRecording: Bool { get }
    var transcribedText: String { get }
    var errorMessage: String? { get }
    
    func requestPermissions() async -> Bool
    func startRecording() async
    func stopRecording()
    func reset()
}

final class SpeechRecognizerManager: ObservableObject, SpeechRecognizing {
    // MARK: - Singleton
    static let shared = SpeechRecognizerManager()
    
    // MARK: - Published Properties
    @Published private(set) var isRecording: Bool = false
    @Published private(set) var transcribedText: String = "" {
        didSet {
            if !transcribedText.isEmpty {
                NotificationCenter.default.post(name: .speechRecognizerDidUpdateText, object: nil)
            }
        }
    }
    @Published private(set) var errorMessage: String? = nil
    
    // MARK: - Private Properties
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        setupSpeechRecognizer()
    }
    
    // MARK: - Private Methods
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        // Check if speech recognition is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is not available on this device"
            return
        }
    }
    
    // MARK: - Public Methods
    func requestPermissions() async -> Bool {
        // Request speech recognition authorization
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        // Request microphone authorization
        let microphoneStatus = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        
        // Check if both permissions are granted
        let speechAuthorized = speechStatus == .authorized
        let microphoneAuthorized = microphoneStatus
        
        if !speechAuthorized {
            errorMessage = "Speech recognition permission not granted"
        }
        
        if !microphoneAuthorized {
            errorMessage = "Microphone permission not granted"
        }
        
        return speechAuthorized && microphoneAuthorized
    }
    
    func startRecording() async {
        // Reset any previous state
        reset()
        
        // Check permissions
        let permissionsGranted = await requestPermissions()
        guard permissionsGranted else { return }
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to set up audio session: \(error.localizedDescription)"
            return
        }
        
        // Create and configure the speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create speech recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Start the recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Recognition error: \(error.localizedDescription)"
                self.stopRecording()
                return
            }
            
            if let result = result {
                self.transcribedText = result.bestTranscription.formattedString
            }
        }
        
        // Configure the audio engine
        let inputNode = audioEngine.inputNode
        
        // Use a standard audio format that's compatible with speech recognition
        let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        
        guard let recordingFormat = recordingFormat else {
            errorMessage = "Failed to create audio format"
            stopRecording()
            return
        }
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start the audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            stopRecording()
        }
    }
    
    func stopRecording() {
        // Stop the audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End the recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        // Cancel the recognition task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isRecording = false
    }
    
    func reset() {
        stopRecording()
        transcribedText = ""
        errorMessage = nil
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let speechRecognizerDidUpdateText = Notification.Name("SpeechRecognizerDidUpdateText")
} 