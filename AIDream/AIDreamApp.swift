//
//  AIDreamApp.swift
//  AIDream
//
//  Created by Александра Тажибай on 28.05.2025.
//

import SwiftUI

@main
struct AIDreamApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var supabaseService = SupabaseService()
    @StateObject private var superwallService = SuperwallService()
    @StateObject private var appState = AppState()
    @StateObject private var subscriptionManager = SubscriptionManager()
    @StateObject private var lockVM = FaceIDLockViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    init() {
           StringArrayTransformer.register()
        }
    var body: some Scene {
        WindowGroup {
            if !hasCompletedOnboarding {
                       OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                   } else {
            if lockVM.isUnlocked {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(supabaseService)
                    .environmentObject(superwallService)
                    .environmentObject(appState)
                    .environmentObject(subscriptionManager)
                    .onAppear {
                        Task {
                            await subscriptionManager.updateSubscriptionStatus()
                            await supabaseService.initializeClient()// 👈 добавь это
                           }
                    }
            } else {
                Text("App is locked. Please authenticate.")
                    .onAppear { lockVM.unlockIfNeeded() }
            }
        }
 //                   let mockInterpretation = DreamInterpretation(
//                       summary: "You dreamed of wandering alone through a misty forest, feeling lost and uncertain. A voice was calling you from the distance, but you couldn't respond",
//                       symbols: [
//                           .init(symbol: "🐍", meaning: "Трансформация"),
//                           .init(symbol: "🌊", meaning: "Эмоции")
//                       ],
//                       emotionalAnalysis: "Вы ощущаете внутренние перемены.",
//                       recommendations: ["Обратите внимание на чувства", "Запишите сон"],
//                       tags: ["вода", "змея", "перемены"]
//                   )
//                   
//                   let viewModel = DreamCreationViewModel()
//
//                   DreamInterpretationScreen(
//                       interpretation: mockInterpretation,
//                       onDone: {}, // можно обновить позже
//                       viewModel: viewModel
//                   )
               }
    }
}
//ContentView()
//    .environment(\.managedObjectContext, persistenceController.container.viewContext)
//    .environmentObject(supabaseService)
//    .environmentObject(superwallService)
//    .environmentObject(appState)
//    .environmentObject(subscriptionManager)
// MARK: - App State
class AppState: ObservableObject {
    @Published var isDarkMode: Bool = false
    @Published var selectedLanguage: Language = .english
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    
    // Add more app-wide state properties here
}

// MARK: - Language
enum Language: String, Codable {
    case english = "English"
    case russian = "Русский"
}

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var displayName: String?
    var subscriptionStatus: SubscriptionStatus
    var settings: AppUserSettings
}

// MARK: - User Settings
struct AppUserSettings: Codable {
    var isDarkMode: Bool
    var language: Language
    var notificationsEnabled: Bool
    var sleepTime: Date
    var wakeTime: Date
    var useFaceID: Bool
}

// MARK: - Subscription Status
enum SubscriptionStatus: String, Codable {
    case free
    case premium
    case trial
}
