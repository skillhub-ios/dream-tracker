//
// AppLanguageManager.swift
//
// Created by Cesare on 15.07.2025 on Earth.
//

import SwiftUI

protocol AppLanguageManagerProtocol {
    func openSystemLanguageSettings()
    var currentLanguageCode: String { get }
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
