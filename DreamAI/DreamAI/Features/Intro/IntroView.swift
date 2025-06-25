//
//  IntroView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct IntroView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var animateGradient = false
    @State private var showAuthSheet = false
    @State private var authMode: AuthSheetMode = .login
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppGradients.purpleToBlack
                .edgesIgnoringSafeArea(.all)
            IntroBottomCard(showAuthSheet: $showAuthSheet, authMode: $authMode)
                .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showAuthSheet) {
            AuthSheetView(mode: authMode)
                .presentationDetents([.fraction(0.28)])
                .presentationDragIndicator(.visible)
        }
        .navigationDestination(isPresented: $authManager.isAuthenticated) {
            PermissionContainerView()
        }
    }
}

struct IntroBottomCard: View {
    @Binding var showAuthSheet: Bool
    @Binding var authMode: AuthSheetMode
    
    var body: some View {
        VStack(spacing: 24) {
            titleView
            buttonWithFooterView
        }
    }
}

private extension IntroBottomCard {
    var titleView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("🌙 Uncover Your Dreams with AI")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Explore your subconscious, one dream at a time.")
                .font(.body)
                .foregroundColor(.gray)
        }
        .multilineTextAlignment(.leading)
    }
    
    var buttonWithFooterView: some View {
        VStack(spacing: 12) {
            Button {
                authMode = .signup
                showAuthSheet = true
            } label: {
                Text("Get Started")
            }
            .buttonStyle(PrimaryButtonStyle())
            HStack(spacing: 4) {
                Text("Do you already have an account?")
                    .foregroundColor(.white)
                    .font(.footnote)
                Button(action: {
                    authMode = .login
                    showAuthSheet = true
                }) {
                    Text("Log in")
                        .underline()
                        .foregroundColor(.white)
                        .font(.footnote.bold())
                }
            }
        }
    }
}

#Preview {
    IntroView()
        .preferredColorScheme(.dark)
}
