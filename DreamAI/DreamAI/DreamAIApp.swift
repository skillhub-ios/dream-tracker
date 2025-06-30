//
//  DreamAIApp.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//

import SwiftUI

@main
struct DreamAIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var pushNotificationManager = PushNotificationManager.shared
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                PermissionsSettingsUI()
            }
//            if authManager.isAuthenticated {
//                if authManager.hasCompletedPermissions {
//                    MainView()
//                        .environmentObject(subscriptionViewModel)
//                        .fullScreenCover(isPresented: $subscriptionViewModel.paywallIsPresent) {
//                            PaywallView()
//                        }
//                } else {
//                    NavigationStack {
//                        PermissionContainerView()
//                    }
//                }
//            } else {
//                NavigationStack {
//                    IntroView()
//                }
//            }
        }
    }
}
