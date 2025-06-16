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
    @Published var isSubscribed: Bool = UserManager.shared.isSubscribed
    @Published var subscriptionPlan: String = "Monthly" // Placeholder
    @Published var subscriptionExpiry: String = "18.07.2024" // Placeholder
    
    // Settings
    @Published var isICloudEnabled: Bool = false
    @Published var isExportImportEnabled: Bool = false
    @Published var selectedLanguage: String = "English"
    @Published var isFaceIDEnabled: Bool = false
    @Published var areNotificationsEnabled: Bool = false
    @Published var bedtime: String = "8:00 AM"
    @Published var wakeup: String = "8:00 AM"
    
    // Feedback
    func writeFeedback() {
        // Navigation or action for feedback
    }
    
    // Exit
    func exitProfile() {
        // Handle exit logic
    }
} 