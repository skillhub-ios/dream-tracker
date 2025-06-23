//
//  BiometricManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import LocalAuthentication
import SwiftUI

@MainActor
class BiometricManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = BiometricManager()
    
    // MARK: - Published Properties
    @Published var isFaceIDEnabled: Bool = false
    @Published var isAuthenticated: Bool = false
    @Published var biometricType: LABiometryType = .none
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let faceIDEnabledKey = "face_id_enabled"
    private let context = LAContext()
    
    // MARK: - Initialization
    private init() {
        loadFaceIDSetting()
        checkBiometricAvailability()
    }
    
    // MARK: - Public Methods
    
    /// Check if biometric authentication is available on the device
    func checkBiometricAvailability() {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        } else {
            biometricType = .none
            if let error = error {
                print("Biometric authentication not available: \(error.localizedDescription)")
            }
        }
    }
    
    /// Authenticate user with biometrics
    func authenticate() async -> Bool {
        guard isFaceIDEnabled else {
            // If Face ID is disabled, allow access
            isAuthenticated = true
            return true
        }
        
        guard biometricType != .none else {
            errorMessage = "Biometric authentication is not available on this device"
            return false
        }
        
        let reason = "Authenticate to access your dreams"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            isAuthenticated = success
            return success
        } catch {
            await handleAuthenticationError(error)
            return false
        }
    }
    
    /// Toggle Face ID setting
    func toggleFaceID(_ enabled: Bool) {
        isFaceIDEnabled = enabled
        saveFaceIDSetting()
        
        if !enabled {
            // If Face ID is disabled, reset authentication state
            isAuthenticated = false
        }
    }
    
    /// Reset authentication state (call when app goes to background)
    func resetAuthentication() {
        isAuthenticated = false
    }
    
    /// Get biometric type description
    var biometricTypeDescription: String {
        switch biometricType {
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .none:
            return "None"
        @unknown default:
            return "Unknown"
        }
    }
    
    /// Check if biometric authentication is supported
    var isBiometricSupported: Bool {
        return biometricType != .none
    }
    
    // MARK: - Private Methods
    
    private func loadFaceIDSetting() {
        isFaceIDEnabled = userDefaults.bool(forKey: faceIDEnabledKey)
    }
    
    private func saveFaceIDSetting() {
        userDefaults.set(isFaceIDEnabled, forKey: faceIDEnabledKey)
    }
    
    private func handleAuthenticationError(_ error: Error) async {
        let authError = error as? LAError
        
        switch authError?.code {
        case .userCancel:
            errorMessage = "Authentication was cancelled"
        case .userFallback:
            errorMessage = "User chose to use passcode"
        case .biometryNotAvailable:
            errorMessage = "Biometric authentication is not available"
        case .biometryNotEnrolled:
            errorMessage = "No biometric authentication is enrolled"
        case .biometryLockout:
            errorMessage = "Biometric authentication is locked out"
        case .invalidContext:
            errorMessage = "Invalid authentication context"
        case .notInteractive:
            errorMessage = "Authentication requires user interaction"
        case .passcodeNotSet:
            errorMessage = "Passcode is not set on device"
        case .systemCancel:
            errorMessage = "Authentication was cancelled by system"
        case .appCancel:
            errorMessage = "Authentication was cancelled by app"
        default:
            errorMessage = "Authentication failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Biometric Authentication Error
enum BiometricError: LocalizedError {
    case notAvailable
    case notEnrolled
    case lockedOut
    case cancelled
    case failed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available"
        case .notEnrolled:
            return "No biometric authentication is enrolled"
        case .lockedOut:
            return "Biometric authentication is locked out"
        case .cancelled:
            return "Authentication was cancelled"
        case .failed:
            return "Authentication failed"
        }
    }
} 