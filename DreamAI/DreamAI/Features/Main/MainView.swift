//
//  MainView.swift
//  DreamAI
//
//  Created by Shaxzod on 10/06/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @StateObject private var biometricManager = BiometricManager.shared
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @State private var showProfileView = false
    @State private var showBiometricAlert = false
    @State private var isBlured: Bool = false
    
    var body: some View {
        Group {
            if biometricManager.isFaceIDEnabled && !biometricManager.isAuthenticated {
                // Show authentication screen
                BiometricAuthView()
            } else {
                // Show main content
                mainContentView
            }
        }
        .alert("Authentication Error", isPresented: $showBiometricAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(biometricManager.errorMessage ?? "Authentication failed")
        }
        .onReceive(biometricManager.$errorMessage) { errorMessage in
            if errorMessage != nil {
                showBiometricAlert = true
            }
        }
    }
    
    private var mainContentView: some View {
        NavigationStack {
            ZStack {
                lineGradient
                
                VStack {
                    VStack(spacing: 0) {
                        Text("Good morning!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Ready to log a dream?")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .padding(.top, 10)
                        
                        VStack {
                            if let lastDream = viewModel.lastDream {
                                lastDreamView(lastDream: lastDream)
                            } else {
                                noDreamsView
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    
                    Color.clear
                        .frame(height: SCREEN_HEIGHT * 0.7)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showProfileView.toggle()
                    } label: {
                        Image(.profileButton)
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if subscriptionViewModel.isSubscribed {
                            withAnimation {
                                isBlured.toggle()
                            }
                        } else {
                            subscriptionViewModel.showPaywall()
                        }
                    } label: {
                        Image(systemName: isBlured ? "eye" : "eye.slash")
                            .resizable()
                            .frame(width: 28, height: 24)
                            .foregroundStyle(.white)
                    }
                }
            }
            .sheet(isPresented: .constant(true)) {
                MainFloatingPanelView(isBlured: $isBlured)
                    .presentationDetents([.fraction(0.7), .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(.ultraThickMaterial)
                    .presentationBackgroundInteraction(.enabled)
                    .interactiveDismissDisabled()
                    .environmentObject(viewModel)
                    .sheet(isPresented: $showProfileView) {
                        NavigationStack {
                            ProfileView()
                                .presentationDetents([.large])
                        }
                    }
            }
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

// MARK: - Biometric Authentication View
struct BiometricAuthView: View {
    @StateObject private var biometricManager = BiometricManager.shared
    @State private var isAuthenticating = false
    
    var body: some View {
        ZStack {
            // Background gradient
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

// Mark: private UI

private extension MainView {
    var lineGradient: some View {
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
    }
    
    func lastDreamView(lastDream dream: Dream) -> some View {
        HStack(spacing: 12) {
            Text(dream.emoji)
                .frame(width: 24, height: 24)
                .padding(5)
                .background(Color.appPurpleDarkBackground)
                .clipShape(Circle())
            
            Text(dream.date.formatted())
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.appPurpleDark.opacity(0.5))
        .clipShape(Capsule())
        .padding(.top)
    }
    
    var noDreamsView: some View {
        HStack(spacing: 12) {
            Text("😞")
                .frame(width: 24, height: 24)
                .padding(5)
                .background(Color.appPurpleDarkBackground)
                .clipShape(Circle())
            
            Text("No dreams yet")
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.appPurpleDark.opacity(0.5))
        .clipShape(Capsule())
        .padding(.top)
    }
}

extension Date {
    /// from Date  to -> 2.07.2023 • 05:20
    func formatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy • HH:mm"
        return dateFormatter.string(from: self)
    }
}

#Preview {
    NavigationStack{
        MainView()
    }
    .colorScheme(.dark)
}
