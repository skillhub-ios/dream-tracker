//
//  DreamInterpretationViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct FeelingProgress: Hashable {
    let emoji: String
    let progress: Double
}

struct DreamTag: Hashable {
    let icon: String
    let title: String
}

struct DreamType: Hashable {
    let icon: String
    let title: String
}

struct ResonanceOption: Hashable {
    let emoji: String
    let title: String
}

class DreamInterpretationViewModel: ObservableObject {
    // MARK: - Mock Data
    let title = "The Mountain of Fear"
    let dreamDescription = "You dreamed of wandering alone through a misty forest, feeling lost and uncertain. A voice was calling you from the distance, but you couldn't respond"
    let feelingProgress: [FeelingProgress] = [
        .init(emoji: "😶‍🌫️", progress: 0.7),
        .init(emoji: "😳", progress: 0.4),
        .init(emoji: "🥲", progress: 0.2)
    ]
    let tags: [DreamTag] = [
        .init(icon: "🐍", title: "Hidden fears"),
        .init(icon: "🪞", title: "Self-reflection"),
        .init(icon: "🚪", title: "Opportunity")
    ]
    let dreamTypes: [DreamType] = [
        .init(icon: "sun.max", title: "Daydream"),
        .init(icon: "globe", title: "Epic Dream"),
        .init(icon: "repeat", title: "Continuous Dream")
    ]
    let interpretation = "This dream suggests you're navigating uncertainty in waking life. The forest may symbolize confusion or feeling lost in current decisions, while the distant voice reflects an inner guidance you're not yet ready to hear. Your subconscious might be urging you to slow down and reconnect with your intuition."
    let realReflections = "This dream suggests you're navigating uncertainty in waking life. The forest may symbolize confusion or feeling lost in current decisions, while the distant voice reflects an inner guidance you're not yet ready to hear. Your subconscious might be urging you to slow down and reconnect with your intuition."
    let quote = "The interpretation of dreams is the royal road to the unconscious."
    let resonanceOptions: [ResonanceOption] = [
        .init(emoji: "🥲", title: "Yes"),
        .init(emoji: "😐", title: "A bit"),
        .init(emoji: "😶‍🌫️", title: "Not really")
    ]
} 