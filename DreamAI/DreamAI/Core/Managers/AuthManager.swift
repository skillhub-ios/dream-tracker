//
//  AuthManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Supabase
import AuthenticationServices
import GoogleSignIn
import UIKit
import CloudKit
import SwiftUI

protocol AuthManaging {
    var isAuthenticated: Bool { get }
    var hasCompletedPermissions: Bool { get }
    var user: User? { get }
    var showiCloudSignInAlert: Bool { get set }
    var isSyncingWithiCloud: Bool { get set }
    var isSyncingWithiCloudInProgress: Bool { get }
    var showiCloudStatusAlert: Bool { get set }
    var iCloudStatusMessage: String { get set }
    func attemptToEnableiCloudSync()
    func signInWithGoogle(presentingViewController: UIViewController) async throws
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws
    func signOut() async throws
    func markPermissionsCompleted()
}

final class AuthManager: ObservableObject, AuthManaging {
    // MARK: - Singleton
    static let shared = AuthManager()
    private let client = SupabaseService.shared.client
    let analitics = DIContainer.analyticsManager
    
    // MARK: - Debug Mode
#if DEBUG
    let isDebugMode = true
#else
    let isDebugMode = false
#endif
    
    // MARK: - AppStorage Properties for Persistence
    @AppStorage("user_is_authenticated") private var storedIsAuthenticated: Bool = false
    @AppStorage("user_has_completed_permissions") private var storedHasCompletedPermissions: Bool = false
    
    // MARK: - Published Properties
    @Published private(set) var user: User?
    @Published var isAuthenticated: Bool = false
    @Published var hasCompletedPermissions: Bool = false
    @Published var isLoading: Bool = true
    @Published var showiCloudSignInAlert = false
    @Published var isSyncingWithiCloud: Bool = false
    @Published var isSyncingWithiCloudInProgress = false
    @Published var showiCloudStatusAlert = false
    @Published var iCloudStatusMessage = ""
    
    private let userDefaults = UserDefaults.standard
    private let permissionsCompletedKey = "user_has_completed_permissions"
    
    private init() {
        // Initialize with stored values to prevent glitching
        self.isAuthenticated = storedIsAuthenticated
        self.hasCompletedPermissions = storedHasCompletedPermissions
        
        print("🔐 AuthManager initialized - stored auth: \(storedIsAuthenticated), stored permissions: \(storedHasCompletedPermissions)")
        
        // Start session refresh
        Task { await refreshSession() }
    }
    
    func refreshSession() async {
        await MainActor.run {
            isLoading = true
        }
        
        print("🔄 Refreshing session...")
        
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.user = session.user
                let newAuthState = !session.user.isAnonymous
                self.isAuthenticated = newAuthState
                self.storedIsAuthenticated = newAuthState
                self.isLoading = false
                print("✅ Session refreshed - authenticated: \(newAuthState)")
            }
        } catch {
            print("❌ Session refresh failed: \(error.localizedDescription)")
            // If in debug mode and not authenticated, try to sign in anonymously
            if isDebugMode && !isAuthenticated {
                await signInAnonymously()
            } else {
                await MainActor.run {
                    self.user = nil
                    self.isAuthenticated = false
                    self.storedIsAuthenticated = false
                    self.isLoading = false
                    print("❌ Authentication failed - user not authenticated")
                }
            }
        }
    }
    
    // MARK: - Debug Authentication
    private func signInAnonymously() async {
        do {
            try await client.auth.signInAnonymously()
            let session = try await client.auth.session
            await MainActor.run {
                self.user = session.user
                self.isAuthenticated = true
                self.storedIsAuthenticated = true
                self.isLoading = false
            }
            print("DEBUG: Successfully signed in anonymously")
        } catch {
            print("DEBUG: Failed to sign in anonymously: \(error.localizedDescription)")
            await MainActor.run {
                self.user = nil
                self.isAuthenticated = false
                self.storedIsAuthenticated = false
                self.isLoading = false
            }
        }
    }
    
    func signInWithGoogle(presentingViewController: UIViewController) async throws {
        // Get the Google Sign-In result
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)
        
        // Extract the idToken
        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token is missing"])
        }
        
        // Sign in with Supabase using the idToken
        try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken
            )
        )
        
        // Refresh the session to update the user state
        await refreshSession()
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws {
        guard let idToken = credential.identityToken,
              let tokenString = String(data: idToken, encoding: .utf8) else {
            throw NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID token"])
        }
        
        try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .apple,
                idToken: tokenString
            )
        )
        
        await refreshSession()
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
        await refreshSession()
        clearUserDefaults()
        
        // Clear all user data on main thread
        await MainActor.run {
            isAuthenticated = false
            hasCompletedPermissions = false
            storedIsAuthenticated = false
            storedHasCompletedPermissions = false
            user = nil
        }
        
        // Clear all manager data
            UserManager.shared.clearUserData()
            await BiometricManager.shared.clearUserData()
            LanguageManager.shared.clearUserData()
    }
    
    func markPermissionsCompleted() {
        hasCompletedPermissions = true
        userDefaults.set(true, forKey: permissionsCompletedKey)
    }
    
    func attemptToEnableiCloudSync() {
        isSyncingWithiCloudInProgress = true
        CKContainer(identifier: "iCloud.com.get.DreamAI").accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSyncingWithiCloudInProgress = false
                
                if let error = error {
                    print("Error checking iCloud status: \(error.localizedDescription)")
                    self.isSyncingWithiCloud = false
                    self.iCloudStatusMessage = "Error checking iCloud status: \(error.localizedDescription)"
                    self.showiCloudStatusAlert = true
                    return
                }
                
                switch status {
                case .available:
                    print("iCloud is available.")
                    self.isSyncingWithiCloud = true
                    self.iCloudStatusMessage = "iCloud sync has been enabled successfully."
                    self.showiCloudStatusAlert = true
                case .noAccount:
                    print("No iCloud account found.")
                    self.showiCloudSignInAlert = true
                    self.isSyncingWithiCloud = false
                case .restricted:
                    print("iCloud access is restricted.")
                    self.isSyncingWithiCloud = false
                    self.iCloudStatusMessage = "iCloud access is restricted by your device settings."
                    self.showiCloudStatusAlert = true
                case .couldNotDetermine:
                    print("Could not determine iCloud account status.")
                    self.isSyncingWithiCloud = false
                    self.iCloudStatusMessage = "Could not determine iCloud account status. Please try again."
                    self.showiCloudStatusAlert = true
                @unknown default:
                    self.isSyncingWithiCloud = false
                }
            }
        }
    }
    
    func clearUserDefaults() {
        // Clear all stored authentication data
        DispatchQueue.main.async { [weak self] in
            self?.storedIsAuthenticated = false
            self?.storedHasCompletedPermissions = false
        }
    }
}
