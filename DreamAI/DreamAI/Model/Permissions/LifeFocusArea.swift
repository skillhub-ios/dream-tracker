//
//  LifeFocusArea.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum LifeFocusArea: CaseIterable, Identifiable, Hashable {
    case loveAndRelationships
    case careerGrowth
    case mentalHealth         
    case spirituality
    case pastTrauma
    case creativity
    case personalGrowth
    
    var id: Self { self }

    var displayName: LocalizedStringKey {
        switch self {
        case .loveAndRelationships: return "love_and_relationships"
        case .careerGrowth:         return "career_growth"
        case .mentalHealth:         return "mental_health"
        case .spirituality:         return "spirituality"
        case .pastTrauma:           return "past_trauma"
        case .creativity:           return "creativity"
        case .personalGrowth:       return "personal_growth"
        }
    }
}

