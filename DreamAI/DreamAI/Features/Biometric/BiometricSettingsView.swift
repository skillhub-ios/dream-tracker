//
// BiometricSettingsView.swift
//
// Created by Cesare on 24.07.2025 on Earth.
// 


import SwiftUI

struct BiometricSettingsView: View {
    @EnvironmentObject private var biometricManager: BiometricManagerNew
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
            biometricToggleRow
            .alert("error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
    }
    
    private var biometricToggleRow: some View {
        HStack {
            Text(biometricManager.getAvailableBiometricType().description)
                .font(.body)
                .foregroundStyle(.white)
            Spacer()
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Toggle("", isOn: Binding(
                    get: { biometricManager.isBiometricEnabled },
                    set: { newValue in
                        handleBiometricToggle(newValue)
                    }
                ))
                .disabled(!biometricManager.isBiometricAvailable())
            }
        }
    }
    
    private func handleBiometricToggle(_ newValue: Bool) {
        if newValue {
            // Пользователь хочет включить биометрию
            enableBiometric()
        } else {
            // Пользователь хочет отключить биометрию
            biometricManager.disableBiometric()
        }
    }
    
    private func enableBiometric() {
        guard biometricManager.isBiometricAvailable() else {
            showError("Biometric authentication is not available on this device")
            return
        }
        
        isLoading = true
        
        Task {
            let result = await biometricManager.requestBiometricPermission(
                reason: "Verify your identity to activate biometric authentication"
            )
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    // Биометрия успешно активирована
                    print("Biometrics activated successfully")
                    
                case .failure(let error):
                    // Показываем ошибку пользователю
                    showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

#Preview {
    BiometricSettingsView()
        .environmentObject(BiometricManagerNew())
}
