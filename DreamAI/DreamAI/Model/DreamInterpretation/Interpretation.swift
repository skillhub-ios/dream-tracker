//
//  Interpretation.swift
//  DreamAI
//
//  Created by Shaxzod on 14/06/25.
//
import Foundation

struct Interpretation: Codable {
    let dreamTitle: String
    let dreamSummary: String
    let fullInterpretation: String
    let moodInsights: [MoodInsight]
    let symbolism: [SymbolMeaning]
    let reflectionPrompts: [String]
    let quote: Quote
    var dreamParentId: UUID?
    let tags: [String]
    
    mutating func setDreamParentId(_ id: UUID) {
        self.dreamParentId = id
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
let dreamInterpretationFullModel = Interpretation(
    dreamTitle: "The Mountain of Fear",
    dreamSummary: "You dreamed of wandering alone through a misty forest, feeling lost and uncertain. A voice was calling you from the distance, but you couldn't respond",
    fullInterpretation: "This dream suggests you're navigating uncertainty in waking life. The forest may symbolize confusion or feeling lost in current decisions, while the distant voice reflects an inner guidance you're not yet ready to hear. Your subconscious might be urging you to slow down and reconnect with your intuition.",
    moodInsights: [
        MoodInsight(emoji: "😶‍🌫️", label: "Confusion", score: 0.7),
        MoodInsight(emoji: "😳", label: "Anxiety", score: 0.4),
        MoodInsight(emoji: "🥲", label: "Sadness", score: 0.2)
    ],
    symbolism: [
        SymbolMeaning(icon: "🐍", meaning: "Hidden fears"),
        SymbolMeaning(icon: "🪞", meaning: "Self-reflection"),
        SymbolMeaning(icon: "🚪", meaning: "Opportunity")
    ],
    reflectionPrompts: [
        "What did you feel in the dream?",
        "What did you see in the dream?",
        "What did you hear in the dream?"
    ],
    quote: Quote(text: "The interpretation of dreams is the royal road to the unconscious.", author: "Sigmund Freud"),
    tags: ["Sometag", "Anothertag"]
)

// MARK: Core Data Support

extension Interpretation {
    init?(from entity: InterpretationEntity) {
        guard let moodInsightsData = entity.moodInsights,
              let symbolismData = entity.symbolism,
              let quoteData = entity.quote else {
            return nil
        }

        let decoder = JSONDecoder()

        guard let moodInsights = try? decoder.decode([MoodInsight].self, from: moodInsightsData),
              let symbolism = try? decoder.decode([SymbolMeaning].self, from: symbolismData),
              let quote = try? decoder.decode(Quote.self, from: quoteData) else {
            return nil
        }

        self.init(
            dreamTitle: entity.dreamTitle ?? "",
            dreamSummary: entity.dreamSummary ?? "",
            fullInterpretation: entity.fullInterpretation ?? "",
            moodInsights: moodInsights,
            symbolism: symbolism,
            reflectionPrompts: entity.reflectionPrompts?.split(separator: ",").compactMap { String($0) } ?? [],
            quote: quote,
            dreamParentId: entity.dreamParentId,
            tags: []
        )
    }
}
