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

protocol AuthManaging {
    var isAuthenticated: Bool { get }
    var user: User? { get }
    func signInWithGoogle(presentingViewController: UIViewController) async throws
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws
    func signOut() async throws
}

final class AuthManager: ObservableObject, AuthManaging {
    // MARK: - Singleton
    static let shared = AuthManager()
    private let client = SupabaseService.shared.client
    
    // MARK: - Debug Mode
    #if DEBUG
    let isDebugMode = true
    #else
    let isDebugMode = false
    #endif
    
    @Published private(set) var user: User?
    @Published var isAuthenticated: Bool = false

    private init() {
        Task { await refreshSession() }
    }
    
    func refreshSession() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.user = session.user
                self.isAuthenticated = !session.user.isAnonymous
            }
        } catch {
            // If in debug mode and not authenticated, try to sign in anonymously
            if isDebugMode && !isAuthenticated {
                await signInAnonymously()
            } else {
                await MainActor.run {
                    self.user = nil
                    self.isAuthenticated = false
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
            }
            print("DEBUG: Successfully signed in anonymously")
        } catch {
            print("DEBUG: Failed to sign in anonymously: \(error.localizedDescription)")
            await MainActor.run {
                self.user = nil
                self.isAuthenticated = false
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
    }
}
