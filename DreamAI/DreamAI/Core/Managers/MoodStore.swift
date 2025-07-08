//
// MoodStore.swift
//
// Created by Cesare on 08.07.2025 on Earth.
// 


import Foundation

final class MoodStore {
    
    // MARK: - Public Properties
    
    @Published var moods: [Mood] = []
    
    // MARK: - Private Properties

    // MARK: - Lifecycle

    init() {
        loadMoods()
    }
    // MARK: - Public Functions

    func addMood(_ mood: Mood) {
        moods.append(mood)
    }
    
    // MARK: - Private Functions
    
    private func loadMoods() {
        moods = loadDefaultMoods()
        moods.append(contentsOf: loadCustomMoods())
    }
    
    private func loadDefaultMoods() -> [Mood] {
        Mood.predefined
    }
    
    private func loadCustomMoods() -> [Mood] {
        []
    }
}
