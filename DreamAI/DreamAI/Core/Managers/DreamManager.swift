//
//  DreamManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import Combine

@MainActor
class DreamManager: ObservableObject {
    
    // MARK: - Properties
    @Published var dreams: [Dream] = []
    
    // MARK: - Singleton
    static let shared = DreamManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadMockDreams()
    }
    
    // MARK: - Public Methods
    
    func addDream(_ dream: Dream) {
        dreams.insert(dream, at: 0)
        objectWillChange.send()
    }
    
    func updateDreamStatus(dreamId: UUID, status: RequestStatus) {
        if let index = dreams.firstIndex(where: { $0.id == dreamId }) {
            dreams[index].requestStatus = status
            objectWillChange.send()
        }
    }
    
    func startDreamInterpretation(dreamId: UUID) {
        updateDreamStatus(dreamId: dreamId, status: .loading(progress: 0.0))
        
        // Simulate API call with progress updates
        Task {
            await simulateDreamInterpretationRequest(dreamId: dreamId)
        }
    }
    
    func deleteDreams(ids: [UUID]) {
        dreams.removeAll { ids.contains($0.id) }
        objectWillChange.send()
    }
    
    func getDream(by id: UUID) -> Dream? {
        return dreams.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    private func simulateDreamInterpretationRequest(dreamId: UUID) async {
        let progressSteps: [Double] = [0.2, 0.4, 0.6, 0.8, 1.0]
        
        for progress in progressSteps {
            try? await Task.sleep(for: .seconds(1.0))
            
            await MainActor.run {
                updateDreamStatus(dreamId: dreamId, status: .loading(progress: progress))
            }
        }
        
        // Simulate random success or error
        let isSuccess = Bool.random()
        
        await MainActor.run {
            updateDreamStatus(dreamId: dreamId, status: isSuccess ? .success : .error)
        }
        
        // If success, update the dream with interpretation data
        if isSuccess {
            await updateDreamWithInterpretation(dreamId: dreamId)
        }
    }
    
    private func updateDreamWithInterpretation(dreamId: UUID) async {
        // Here you would typically update the dream with actual interpretation data
        // For now, we'll just mark it as successful
        print("Dream interpretation completed for dream: \(dreamId)")
    }
    
    private func loadMockDreams() {
        dreams = [
            Dream(emoji: "😰", emojiBackground: .appGreen, title: "Falling from a great height", tags: [.nightmare, .epicDream], date: Date().addingTimeInterval(-86400)),
            Dream(emoji: "🏃‍♂️", emojiBackground: .appBlue, title: "Running but can't escape", tags: [.nightmare, .epicDream], date: Date().addingTimeInterval(-172800)),
            Dream(emoji: "🌊", emojiBackground: .appPurple, title: "Drowning in the ocean", tags: [.nightmare, .propheticDream], date: Date().addingTimeInterval(-259200)),
            Dream(emoji: "✈️", emojiBackground: .appOrange, title: "Flying over the mountains", tags: [.lucidDream, .epicDream], date: Date().addingTimeInterval(-345600)),
            Dream(emoji: "🏠", emojiBackground: .appRed, title: "Lost in a house", tags: [.nightmare, .continuousDream], date: Date().addingTimeInterval(-432000))
        ]
    }
} 