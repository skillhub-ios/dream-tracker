//
// AppLanguageManager.swift
//
// Created by Cesare on 15.07.2025 on Earth.
//

import SwiftUI

protocol AppLanguageManagerProtocol {
    func openSystemLanguageSettings()
    var currentLanguageCode: String { get }
    var currentLanguageFlag: String { get }
}

final class AppLanguageManager: AppLanguageManagerProtocol {
    
    func openSystemLanguageSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    var currentLanguageCode: String {
        guard let fullCode = Locale.preferredLanguages.first else { return "en" }
        return String(fullCode.prefix(2))
    }
    
    var currentLanguageDisplayName: String {
        Locale.current.localizedString(forLanguageCode: currentLanguageCode) ?? currentLanguageCode
    }
    
    var currentLanguageFlag: String {
            // Специальный случай для английского - всегда флаг США
            if currentLanguageCode == "en" {
                return "🇺🇸"
            }
            
            // Получаем полный код локали (например, "ru_RU", "de_DE")
            guard let fullLocaleCode = Locale.preferredLanguages.first else {
                return "🇺🇸" // fallback для английского
            }
            
            // Извлекаем код региона из локали
            let locale = Locale(identifier: fullLocaleCode)
            guard let regionCode = locale.regionCode else {
                return "🏳️" // флаг по умолчанию если регион не определен
            }
            
            // Конвертируем код региона в эмодзи флага
            return flagEmoji(for: regionCode)
        }
    
    private func flagEmoji(for regionCode: String) -> String {
            // Конвертируем ISO код страны в эмодзи флага
            let base: UInt32 = 127397
            var flagString = ""
            
            for character in regionCode.uppercased() {
                if let scalar = character.unicodeScalars.first {
                    let flagScalar = UnicodeScalar(base + scalar.value)!
                    flagString += String(flagScalar)
                }
            }
            
            return flagString.isEmpty ? "🏳️" : flagString
        }
}

private struct AppLanguageManagerKey: EnvironmentKey {
    static let defaultValue: AppLanguageManager = AppLanguageManager()
}

extension EnvironmentValues {
    var languageManager: AppLanguageManager {
        get { self[AppLanguageManagerKey.self] }
        set { self[AppLanguageManagerKey.self] = newValue }
    }
}
