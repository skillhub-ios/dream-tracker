//
//  PermissionsSettingsViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI
import Combine

final class PermissionsSettingsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let languageManager: LanguageManaging = LanguageManager.shared
    
    // MARK: - Published Properties
    @Published var remindersEnabled: Bool = true
    @Published var bedtime: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    @Published var wakeup: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    @Published var faceIDEnabled: Bool = true
    @Published var selectedLanguage: Language? = .english
    
    // MARK: - Properties
    let allLanguages = Language.allCases
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.selectedLanguage = languageManager.currentLanguage
        
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Observe language changes from the manager
        $selectedLanguage
            .dropFirst()
            .compactMap { $0 }
            .sink { [weak self] newLanguage in
                self?.languageManager.setLanguage(newLanguage)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func updateLanguage(_ language: Language) {
        selectedLanguage = language
    }
}
