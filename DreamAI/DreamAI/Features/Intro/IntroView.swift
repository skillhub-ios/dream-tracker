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
    @Environment(\.deviceFamily) var deviceFamily
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                IntroBottomCard(showAuthSheet: $showAuthSheet, authMode: $authMode)
            }
            .animatedGradientBackground()
            .sheet(isPresented: $showAuthSheet) {
                AuthSheetView(mode: authMode)
                    .presentationDetents([.fraction(sheetHeight())])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func sheetHeight() -> CGFloat {
        switch deviceFamily {
        case .pad: 0.35
        case .phone: 0.28
        }
    }
}

struct IntroBottomCard: View {
    @Binding var showAuthSheet: Bool
    @Binding var authMode: AuthSheetMode
    @Environment(\.deviceFamily) var deviceFamily
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 8) {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    Text("Uncover Your Dreams with AI")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                Text("Explore your subconscious, one dream at a time.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            DButton(title: "Get Started") {
                authMode = .signup
                showAuthSheet = true
            }
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
        .padding([.horizontal, .bottom], contentPadding())
    }
    
    private func contentPadding() -> CGFloat {
        switch deviceFamily {
        case .pad: 16
        case .phone: 8
        }
    }
}

#Preview {
    IntroView()
        .preferredColorScheme(.dark)
}
