//
//  DreamInterpretationFullModel.swift
//  DreamAI
//
//  Created by Shaxzod on 14/06/25.
//
import Foundation

struct DreamInterpretationFullModel: Codable {
    let hasSubscription: Bool?
    let dreamEmoji: String
    let dreamTitle: String
    let dreamSummary: String
    let fullInterpretation: String
    let moodInsights: [MoodInsight]
    let symbolism: [SymbolMeaning]
    let reflectionPrompts: [String]
    let quote: Quote
    
    // Computed property to provide default value
    var hasSubscriptionValue: Bool {
        return hasSubscription ?? false
    }
}

struct MoodInsight: Codable {
    let emoji: String
    let label: String
    let score: Double
}

struct SymbolMeaning: Codable {
    let icon: String
    let meaning: String
}

struct Quote: Codable {
    let text: String
    let author: String
}

//MARK: - Mock Data
let dreamInterpretationFullModel = DreamInterpretationFullModel(
    hasSubscription: false,
    dreamEmoji: "😶‍🌫️",
    dreamTitle: "The Mountain of Fear",
    dreamSummary: "You dreamed of wandering alone through a misty forest, feeling lost and uncertain. A voice was calling you from the distance, but you couldn't respond",
    fullInterpretation: "This dream suggests you're navigating uncertainty in waking life. The forest may symbolize confusion or feeling lost in current decisions, while the distant voice reflects an inner guidance you're not yet ready to hear. Your subconscious might be urging you to slow down and reconnect with your intuition.",
    moodInsights: [
        MoodInsight(emoji: "😶‍🌫️", label: "Confusion", score: 0.7),
        MoodInsight(emoji: "😳", label: "Anxiety", score: 0.4),
        MoodInsight(emoji: "🥲", label: "Sadness", score: 0.2)
    ],
    symbolism: [
        SymbolMeaning(icon: "🌲", meaning: "Hidden fears"),
        SymbolMeaning(icon: "🪞", meaning: "Self-reflection"),
        SymbolMeaning(icon: "🚪", meaning: "Opportunity")
    ],
    reflectionPrompts: [
        "What did you feel in the dream?\n",
        "What did you see in the dream?\n",
        "What did you hear in the dream?\n"
    ],
    quote: Quote(text: "The interpretation of dreams is the royal road to the unconscious.", author: "Sigmund Freud")
)
