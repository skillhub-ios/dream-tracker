//
//  ProfileViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    // Subscription
    @Published var isSubscribed: Bool = true// UserManager.shared.isSubscribed
    @Published var subscriptionPlan: String = "Monthly" // Placeholder
    @Published var subscriptionExpiry: String = "18.07.2024" // Placeholder
    
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
    private var cancellables = Set<AnyCancellable>()
    
    init(authManager: AuthManaging = AuthManager.shared) {
        self.authManager = authManager
        self.isICloudEnabled = authManager.isSyncingWithiCloud
        
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
    
    func resetSyncStatusAlert() {
        authManager.showiCloudStatusAlert = false
    }
    
    // Exit
    func exitProfile() {
        // Handle exit logic
    }
} 
