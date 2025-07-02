//
//  UserManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine

final class UserManager: ObservableObject {
    // MARK: - Singleton
    static let shared = UserManager()
    
    // MARK: - Properties
    @Published private(set) var isSubscribed: Bool = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let subscriptionKey = "user_is_subscribed"
    
    // MARK: - Initialization
    private init() {
        // Load subscription status from UserDefaults
//        isSubscribed = userDefaults.bool(forKey: subscriptionKey) TODO: UNCOMMIT
        
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
//        self.isSubscribed = isSubscribed
//        userDefaults.set(isSubscribed, forKey: subscriptionKey)
    }
} 
