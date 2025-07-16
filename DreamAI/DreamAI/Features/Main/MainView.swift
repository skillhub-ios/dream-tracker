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
    @State private var isAuthenticating = false
    
    var body: some View {
        Group {
            if biometricManager.isFaceIDEnabled && !biometricManager.isAuthenticated {
                BiometricAuthView()
            } else {
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
                        Text(getGreetingText())
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("readyToLog?")
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
                                if isBlured {
                                    viewModel.analitics.log(
                                        .premiumFeatureUsed(
                                            feature: PremiumFeature.interpretDream,
                                            screen: ScreenName.main))
                                }
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
        .logScreenView(ScreenName.main)
    }
    
    private func getGreetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12:
            return String(localized: "goodMorning")
        case 12..<17:
            return String(localized: "goodAfternoon")
        case 17..<22:
            return String(localized: "goodEvening")
        default:
            return String(localized: "goodNight")
        }
    }
}

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
            Text(dream.date.dateTimeWithSeparator)
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

#Preview {
    NavigationStack{
        MainView()
            .environmentObject(SubscriptionViewModel())
    }
    .colorScheme(.dark)
}
