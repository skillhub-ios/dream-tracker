//
//  PermissionsSettingsViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PermissionsSettingsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let languageManager: LanguageManaging = LanguageManager.shared
    private let biometricManager: BiometricManager = BiometricManager.shared
    private let pushNotificationManager: PushNotificationManager = PushNotificationManager.shared
    
    // MARK: - Published Properties
    @Published var remindersEnabled: Bool = false
    @Published var bedtime: Date = DateComponents(calendar: .current, hour: 20, minute: 0).date ?? Date()
    @Published var wakeup: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    @Published var faceIDEnabled: Bool = false
    @Published var selectedLanguage: Language? = .english
    
    // MARK: - Properties
    let allLanguages = Language.allCases
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        self.selectedLanguage = languageManager.currentLanguage
        self.faceIDEnabled = biometricManager.isFaceIDEnabled
        
        setupBindings()
        initializeNotificationStatus()
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
        
        // Observe Face ID changes from the biometric manager
        biometricManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.faceIDEnabled = self?.biometricManager.isFaceIDEnabled ?? false
            }
            .store(in: &cancellables)
    }
    
    private func initializeNotificationStatus() {
        Task {
            let isEnabled = await pushNotificationManager.areNotificationsEnabled()
            await MainActor.run {
                self.remindersEnabled = isEnabled
            }
        }
    }
    
    // MARK: - Public Methods
    func updateLanguage(_ language: Language) {
        selectedLanguage = language
    }
    
    func toggleFaceID(_ enabled: Bool) {
        biometricManager.toggleFaceID(enabled)
    }
}
