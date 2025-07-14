//
// BiometricAuthView.swift
//
// Created by Cesare on 14.07.2025 on Earth.
// 

import SwiftUI

struct BiometricAuthView: View {
    @StateObject private var biometricManager = BiometricManager.shared
    @State private var isAuthenticating = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color(.sRGB, red: 38/255, green: 18/255, blue: 44/255, opacity: 1),
                        Color.black
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(.xMarkCircled)
                            .resizable()
                            .frame(width: 24 ,height: 24)
                    }
                    .padding()
                }
                Spacer()
                
                // Icon
                Image(systemName: biometricManager.biometricType == .faceID ? "faceid" : "touchid")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // Title
                Text("Authentication Required")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Description
                Text("Please authenticate to access your dreams")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Authenticate button
                Button(action: {
                    authenticate()
                }) {
                    HStack {
                        if isAuthenticating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: biometricManager.biometricType == .faceID ? "faceid" : "touchid")
                        }
                        Text("Authenticate")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.appPurple)
                    .cornerRadius(25)
                }
                .disabled(isAuthenticating)
                
                Spacer()
            }
        }
        .onAppear {
            // Auto-authenticate when view appears
            authenticate()
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        
        Task {
            let success = await biometricManager.authenticate()
            
            await MainActor.run {
                isAuthenticating = false
                if !success {
                    // Error will be shown via alert in MainView
                }
            }
        }
    }
}
