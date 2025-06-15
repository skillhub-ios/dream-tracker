//
//  DreamInterpretationLiteModel.swift
//  DreamAI
//
//  Created by Shaxzod on 14/06/25.
//

import Foundation

struct DreamInterpretationLiteModel: Codable {
    let hasSubscription: Bool
    let dreamTitle: String
    let dreamSummary: String
    let limitedMessage: String
}

// MARK: - Mock Data
let dreamInterpretationLiteModel = DreamInterpretationLiteModel(
    hasSubscription: false,
    dreamTitle: "The Mountain of Fear",
    dreamSummary: "You dreamed of wandering alone through a misty forest, feeling lost and uncertain. A voice was calling you from the distance, but you couldn't respond",
    limitedMessage: "You've reached the limit of your free interpretation. Upgrade to access the full analysis and insights."
)