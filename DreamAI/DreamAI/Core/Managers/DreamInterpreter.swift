//
//  DreamInterpreter.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation

class DreamInterpreter {
    private let openAIManager = OpenAIManager.shared
    
    func interpretDream(dreamText: String, mood: String?, tags: [String]) async throws -> Interpretation {
        // Validate input
        guard !dreamText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw DreamInterpreterError.emptyDreamText
        }
        
        // Clean and prepare the dream text
        let cleanedDreamText = cleanDreamText(dreamText)
        
        // Get interpretation from OpenAI
        do {
            let interpretation = try await openAIManager.getDreamInterpretation(
                dreamText: cleanedDreamText,
                mood: mood,
                tags: tags
            )
            
            // Validate the interpretation
            return validateAndEnhanceInterpretation(interpretation, originalText: cleanedDreamText)
            
        } catch {
            throw DreamInterpreterError.openAIError(error)
        }
    }
    
    private func cleanDreamText(_ text: String) -> String {
        // Remove extra whitespace and normalize
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Ensure the text is not too short
        if cleaned.count < 10 {
            return "I had a dream about \(cleaned)"
        }
        
        return cleaned
    }
    
    private func validateAndEnhanceInterpretation(_ interpretation: Interpretation, originalText: String) -> Interpretation {
        // Ensure all required fields are present and valid
        var enhancedInterpretation = interpretation
        
        // Validate dream title
        if enhancedInterpretation.dreamTitle.isEmpty || enhancedInterpretation.dreamTitle.count < 3 {
            enhancedInterpretation = Interpretation(
                dreamTitle: generateDreamTitle(from: originalText),
                dreamSummary: enhancedInterpretation.dreamSummary,
                fullInterpretation: enhancedInterpretation.fullInterpretation,
                moodInsights: enhancedInterpretation.moodInsights,
                symbolism: enhancedInterpretation.symbolism,
                reflectionPrompts: enhancedInterpretation.reflectionPrompts,
                quote: enhancedInterpretation.quote,
                tags: enhancedInterpretation.tags
            )
        }
        
        // Validate mood insights
        if enhancedInterpretation.moodInsights.isEmpty {
            enhancedInterpretation = Interpretation(
                dreamTitle: enhancedInterpretation.dreamTitle,
                dreamSummary: enhancedInterpretation.dreamSummary,
                fullInterpretation: enhancedInterpretation.fullInterpretation,
                moodInsights: generateDefaultMoodInsights(),
                symbolism: enhancedInterpretation.symbolism,
                reflectionPrompts: enhancedInterpretation.reflectionPrompts,
                quote: enhancedInterpretation.quote,
                tags: enhancedInterpretation.tags
            )
        }
        
        // Validate symbolism
        if enhancedInterpretation.symbolism.isEmpty {
            enhancedInterpretation = Interpretation(
                dreamTitle: enhancedInterpretation.dreamTitle,
                dreamSummary: enhancedInterpretation.dreamSummary,
                fullInterpretation: enhancedInterpretation.fullInterpretation,
                moodInsights: enhancedInterpretation.moodInsights,
                symbolism: generateDefaultSymbolism(),
                reflectionPrompts: enhancedInterpretation.reflectionPrompts,
                quote: enhancedInterpretation.quote,
                tags: enhancedInterpretation.tags
            )
        }
        
        // Validate reflection prompts
        if enhancedInterpretation.reflectionPrompts.isEmpty {
            enhancedInterpretation = Interpretation(
                dreamTitle: enhancedInterpretation.dreamTitle,
                dreamSummary: enhancedInterpretation.dreamSummary,
                fullInterpretation: enhancedInterpretation.fullInterpretation,
                moodInsights: enhancedInterpretation.moodInsights,
                symbolism: enhancedInterpretation.symbolism,
                reflectionPrompts: generateDefaultReflectionPrompts(),
                quote: enhancedInterpretation.quote,
                tags: enhancedInterpretation.tags
            )
        }
        
        return enhancedInterpretation
    }
    
    private func generateDreamTitle(from text: String) -> String {
        let words = text.components(separatedBy: .whitespaces)
        if let firstWord = words.first, firstWord.count > 2 {
            return "The \(firstWord.capitalized) Dream"
        }
        return "Dream Interpretation"
    }
    
    private func generateDefaultMoodInsights() -> [MoodInsight] {
        return [
            MoodInsight(emoji: "🤔", label: "Curiosity", score: 0.5),
            MoodInsight(emoji: "😌", label: "Calm", score: 0.3),
            MoodInsight(emoji: "✨", label: "Wonder", score: 0.4)
        ]
    }
    
    private func generateDefaultSymbolism() -> [SymbolMeaning] {
        return [
            SymbolMeaning(icon: "🔮", meaning: "Mystery and the unknown"),
            SymbolMeaning(icon: "💭", meaning: "Self-reflection and introspection"),
            SymbolMeaning(icon: "🌟", meaning: "Hope and inspiration")
        ]
    }
    
    private func generateDefaultReflectionPrompts() -> [String] {
        return [
            "What emotions did you feel during this dream?",
            "What symbols or images stood out to you?",
            "How does this dream relate to your current life situation?",
            "What message might your subconscious be trying to convey?"
        ]
    }
}

// MARK: - Error Types
enum DreamInterpreterError: LocalizedError {
    case emptyDreamText
    case openAIError(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .emptyDreamText:
            return "Dream text cannot be empty"
        case .openAIError(let error):
            return "OpenAI API error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from dream interpretation service"
        }
    }
} 
