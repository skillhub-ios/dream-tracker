//
//  LanguageManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI
import Combine

protocol LanguageManaging {
    var currentLanguage: Language { get }
    var isLanguageChanged: Bool { get }
    func setLanguage(_ language: Language)
    func resetLanguage()
    func clearUserData()
}

final class LanguageManager: ObservableObject, LanguageManaging {
    // MARK: - Singleton
    static let shared = LanguageManager()
    
    // MARK: - Published Properties
    @Published private(set) var currentLanguage: Language
    @Published private(set) var isLanguageChanged: Bool = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let languageKey = "app_language"
    
    // MARK: - Initialization
    private init() {
        // Load saved language or use default
        if let savedLanguageRawValue = userDefaults.string(forKey: languageKey),
           let savedLanguage = Language(rawValue: savedLanguageRawValue) {
            self.currentLanguage = savedLanguage
        } else {
            // Default to system language or English
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            let languageCode = preferredLanguage.prefix(2).lowercased()
            
            // Find matching language or default to English
            self.currentLanguage = Language.allCases.first { $0.id == languageCode } ?? .english
        }
    }
    
    // MARK: - Public Methods
    func setLanguage(_ language: Language) {
        guard language != currentLanguage else { return }
        
        currentLanguage = language
        isLanguageChanged = true
        
        // Save to UserDefaults
        userDefaults.set(language.rawValue, forKey: languageKey)
        
        // Post notification for language change
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }
    
    func resetLanguage() {
        isLanguageChanged = false
    }
    
    /// Clear user-specific language data (call on sign out)
    func clearUserData() {
        // Note: Language preference is typically device-wide, not user-specific
        // But we can reset the language change flag
        isLanguageChanged = false
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let languageDidChange = Notification.Name("languageDidChange")
}

// MARK: - View Extension
extension View {
    func localizedString(_ key: String) -> String {
        // In a real app, you would use a localization system like NSLocalizedString
        // For now, we'll just return the key
        return key
    }
} 