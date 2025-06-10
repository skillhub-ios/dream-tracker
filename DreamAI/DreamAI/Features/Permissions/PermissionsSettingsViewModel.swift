//
//  PermissionsSettingsViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI

final class PermissionsSettingsViewModel: ObservableObject {
    @Published var remindersEnabled: Bool = true
    @Published var bedtime: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    @Published var wakeup: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    @Published var faceIDEnabled: Bool = true
    @Published var selectedLanguage: AppLanguage = .english
    
    let allLanguages = AppLanguage.allCases
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "English"
    case spanish = "Spanish"
    case french = "French"
    case german = "German"
    case uzbek = "Uzbek"
    case russian = "Russian"
    case turkish = "Turkish"
    
    var id: String { rawValue }
    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .spanish: return "🇪🇸"
        case .french: return "🇫🇷"
        case .german: return "🇩🇪"
        case .uzbek: return "🇺🇿"
        case .russian: return "🇷🇺"
        case .turkish: return "🇹��"
        }
    }
} 