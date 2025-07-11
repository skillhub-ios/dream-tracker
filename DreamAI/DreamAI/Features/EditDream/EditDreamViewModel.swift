//
// DreamEditViewModel.swift
//
// Created by Cesare on 04.07.2025 on Earth.
// 


import Foundation

final class EditDreamViewModel: ObservableObject {
    @Published var dream: Dream
    @Published var mood: Mood?
    
    let analitics = DIContainer.analyticsManager
    
    init(dream: Dream) {
        self.dream = dream
//        self.mood = Mood(rawValue: dream.emoji)
    }
    
    func saveDream() {
        dream.updateEmoji(mood?.emoji)
        dreamChanged(dream)
    }
    
    private func dreamChanged(_ dream: Dream) {
        NotificationCenter.default.post(
            name: Notification.Name(PublisherKey.changeDream.rawValue),
            object: nil,
            userInfo: ["value": dream]
        )
    }
}
