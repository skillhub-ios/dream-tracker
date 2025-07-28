//
//  ResonanceOption.swift
//  DreamAI
//
//  Created by Shaxzod on 15/06/25.
//

import SwiftUI

enum ResonanceOption: String, CaseIterable, Identifiable {
    case yes
    case aBit
    case notReally
    
    var id: String { rawValue }
    
    var title: LocalizedStringKey {
        switch self {
        case .yes: return "yes"
        case .aBit: return "a_bit"
        case .notReally: return "not_really"
        }
    }
    
    var emoji: String {
        switch self {
        case .yes: return "🥲"
        case .aBit: return "😐"
        case .notReally: return "😶‍🌫️"
        }
    }
}

