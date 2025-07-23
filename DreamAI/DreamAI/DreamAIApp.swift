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
            OnboardingFlowView()
//            Group {
//                if authManager.isLoading {
//                    // Show loading screen while checking authentication status
//                    LoadingView()
//                } else if authManager.isAuthenticated {
//                    if authManager.hasCompletedPermissions {
//                        MainView()
//                            .environmentObject(subscriptionViewModel)
//                    } else {
//                        NavigationStack {
//                            PermissionContainerView()
//                        }
//                    }
//                } else {
//                    NavigationStack {
//                        IntroView()
//                    }
//                }
//            }
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(.sRGB, red: 38/255, green: 18/255, blue: 44/255, opacity: 1),
                        Color.black
                    ]
                ),
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
            
            VStack(spacing: 20) {
                // App icon or logo
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                // Loading text
                Text("DreamAI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
        }
    }
}
