//
//  ProfileViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    // Settings
    @Published var isICloudEnabled: Bool
    @Published var showiCloudSignInAlert: Bool = false
    @Published var isICloudToggleLoading: Bool = false
    @Published var showiCloudStatusAlert: Bool = false
    @Published var iCloudStatusMessage: String = ""
    @Published var selectedLanguage: String = "English"
    @Published var isFaceIDEnabled: Bool = false
    @Published var areNotificationsEnabled: Bool = false
    @Published var bedtime: String = "8:00 AM"
    @Published var wakeup: String = "8:00 AM"
    
    private var authManager: AuthManaging
    private var biometricManager: BiometricManager
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManaging = AuthManager.shared, biometricManager: BiometricManager = BiometricManager.shared) {
        self.authManager = authManager
        self.biometricManager = biometricManager
        self.isICloudEnabled = authManager.isSyncingWithiCloud
        self.isFaceIDEnabled = biometricManager.isFaceIDEnabled
        
        setupBindings()
    }
    
    private func setupBindings() {
        // iCloud bindings
        if let authManager = authManager as? AuthManager {
            authManager.objectWillChange
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.isICloudEnabled = authManager.isSyncingWithiCloud
                    self?.showiCloudSignInAlert = authManager.showiCloudSignInAlert
                    self?.isICloudToggleLoading = authManager.isSyncingWithiCloudInProgress
                    self?.showiCloudStatusAlert = authManager.showiCloudStatusAlert
                    self?.iCloudStatusMessage = authManager.iCloudStatusMessage
                }
                .store(in: &cancellables)
        }
        
        // Face ID bindings
        biometricManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.isFaceIDEnabled = self?.biometricManager.isFaceIDEnabled ?? false
            }
            .store(in: &cancellables)
    }
    
    // Feedback
    func writeFeedback() {
        // Navigation or action for feedback
    }
    
    func userTogglediCloud(to newValue: Bool) {
        if newValue {
            authManager.attemptToEnableiCloudSync()
        } else {
            authManager.isSyncingWithiCloud = false
        }
    }
    
    func userToggledFaceID(to newValue: Bool) {
        biometricManager.toggleFaceID(newValue)
    }
    
    func resetSyncStatusAlert() {
        authManager.showiCloudStatusAlert = false
    }
    
    // Exit
    func exitProfile() {
        // Handle exit logic
    }
} 
