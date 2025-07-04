//
//  UserManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine
import SwiftUI

final class UserManager: ObservableObject {
    // MARK: - Singleton
    static let shared = UserManager()
    
    // MARK: - AppStorage Properties for Persistence
    @AppStorage("user_is_subscribed") private var storedIsSubscribed: Bool = false
    
    // MARK: - Published Properties
    @Published private(set) var isSubscribed: Bool = false
    
    // MARK: - Initialization
    private init() {
        // Initialize with stored value
        self.isSubscribed = storedIsSubscribed
        
        // In a real app, you would check with a backend service
        // For now, we'll just use the stored value
    }
    
    // MARK: - Public Methods
    
    /// Checks the subscription status with the backend service
    func checkSubscriptionStatus() async {
        // In a real app, this would make an API call to verify subscription
        // For now, we'll just use the stored value
        // This is a placeholder for future implementation
    }
    
    /// Updates the subscription status
    /// - Parameter isSubscribed: The new subscription status
    func updateSubscriptionStatus(isSubscribed: Bool) {
        self.isSubscribed = isSubscribed
        self.storedIsSubscribed = isSubscribed
    }
    
    /// Clears all user data (called on sign out)
    func clearUserData() {
        isSubscribed = false
        storedIsSubscribed = false
    }
} 
