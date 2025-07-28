//
// IntroScreenView.swift
//
// Created by Cesare on 21.07.2025 on Earth.
//


import SwiftUI

struct IntroScreenView: View {
    
    @EnvironmentObject private var onboardingViewModel: OnboardingFlowViewModel
    @EnvironmentObject private var authManager: AuthManager
    @State private var showAuthSheet = false
    @Environment(\.deviceFamily) private var deviceFamily
    @Environment(\.languageManager) private var languageManager
    
    var body: some View {
        VStack(spacing: 24) {
            titleView
            bottonSection
           
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.horizontal, 16)
        .animatedGradientBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    languageManager.openSystemLanguageSettings()
                } label: {
                    changeLanguageButton
                }
            }
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthSheetView(mode: .login, isSkipAllowed: false)
                .presentationDetents([.fraction(sheetHeight())])
                .presentationDragIndicator(.visible)
        }
    }
}

private extension IntroScreenView {
    var titleView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("introScreenTitle")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("introScreenSubtitle")
                .font(.body)
                .foregroundStyle(Color.appPurpleLight.opacity(0.6))
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var bottonSection: some View {
        VStack(spacing: 12) {
            Button {
                onboardingViewModel.path.append(.onboarding)
            } label: {
                Text("getStarted")
            }
            .buttonStyle(IntroStyle())
            if !authManager.isAuthenticated {
                HStack {
                    Text("alreadyHaveAccount?")
                        .font(.footnote)
                        .foregroundStyle(.white)
                    Button {
                        showAuthSheet = true
                    } label: {
                        Text("logIn")
                    }
                    .buttonStyle(UnderlineWhiteStyle())
                }
            }
        }
    }
    
    var changeLanguageButton: some View {
        Button {
            languageManager.openSystemLanguageSettings()
        } label: {
            HStack(spacing: 12) {
                Text(languageManager.currentLanguageFlag)
                    .font(.title2)
                Text(languageManager.currentLanguageCode.uppercased())
                    .font(.body)
                    .foregroundStyle(.white)
                Image(systemName: "chevron.down")
                    .resizable()
                    .frame(width: 10, height: 6)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.appPurpleDarkBackground.opacity(0.75))
            }
        }
        .buttonStyle(SmoothPressButtonStyle())
    }
    
    func sheetHeight() -> CGFloat {
        switch deviceFamily {
        case .pad: 0.4
        case .phone: 0.3
        }
    }
}

#Preview {
    NavigationStack {
        IntroScreenView()
            .environmentObject(OnboardingFlowViewModel())
            .environmentObject(AuthManager.shared)
    }
}
