//
// MoodCreator.swift
//
// Created by Cesare on 08.07.2025 on Earth.
// 


import Foundation
import Combine

final class MoodsViewModel: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var moodCreationMode: Bool = false
    @Published var creatingMoodEmoji: String = ""
    @Published var creatingMoodTitle: String = ""
    @Published var showMoodTitleAlert: Bool = false
    
    private let moodStore = DIContainer.moodStore
    
    init() {
        addSubscriptions()
    }
    
    private func addSubscriptions() {
        moodStore.$moods
            .dropIfEmpty()
            .receive(on: DispatchQueue.main)
            .assign(to: &$moods)
    }
    
    func createMood() -> Mood? {
        guard !creatingMoodTitle.isEmpty else {
            showMoodTitleAlert = true
            return nil
        }
        let emoji = creatingMoodEmoji.isEmpty ? "💤" : creatingMoodEmoji
        let newMood = Mood(
            title: creatingMoodTitle,
            emoji: emoji)
                
        disableAndRestoreMoodCreation()
        moodStore.addMood(newMood)
        return newMood
    }
    
    func disableAndRestoreMoodCreation() {
        moodCreationMode = false
        creatingMoodEmoji = ""
        creatingMoodTitle = ""
        showMoodTitleAlert = false
    }
    
}
