//
//  AgeRange.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum AgeRange: String, CaseIterable, Identifiable, Hashable {
    case notToSay = "Not to say"
    case under18 = "Under 18"
    case age18_24 = "18–24"
    case age25_34 = "25–34"
    case age35_44 = "35–44"
    case age45_54 = "45–54"
    case age55_64 = "55–64"
    case age65plus = "65+"
    
    var id: String { rawValue }
    var displayTitle: LocalizedStringKey {
        switch self {
        case .notToSay: "notToSay"
        case .under18: "under18"
        case .age18_24: "18–24"
        case .age25_34: "25–34"
        case .age35_44: "35–44"
        case .age45_54: "45–54"
        case .age55_64: "55–64"
        case .age65plus: "65+"
        }
    }
}
