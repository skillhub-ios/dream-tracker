//
//  DreamAIApp.swift
//  DreamAI
//
//  Created by Shaxzod on 07/06/25.
//

import SwiftUI

@main
struct DreamAIApp: App {

    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated || authManager.isDebugMode {
                MainView()
            } else {
                IntroView()
            }
        }
    }
}
