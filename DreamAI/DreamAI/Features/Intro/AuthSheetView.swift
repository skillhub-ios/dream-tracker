//
//  AuthSheetView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

enum AuthSheetMode {
    case signup, login
    var title: String {
        switch self {
        case .signup: return "Sign up"
        case .login: return "Log In"
        }
    }
    var appleButtonText: String {
        switch self {
        case .signup: return "Sign Up with Apple"
        case .login: return "Log In with Apple"
        }
    }
    var googleButtonText: String {
        switch self {
        case .signup: return "Sign Up with Google"
        case .login: return "Log In with Google"
        }
    }
}

struct AuthSheetView: View {
    let mode: AuthSheetMode
    var body: some View {
        VStack(spacing: 24) {
            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(Color.gray.opacity(0.4))
                .padding(.top, 8)
            Text(mode.title)
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.top, 8)
            VStack(spacing: 12) {
                AuthButton(
                    icon: Image(systemName: "apple.logo"),
                    text: mode.appleButtonText,
                    background: .black,
                    foreground: .white
                ) {}
                AuthButton(
                    icon: Image("google-icon"),
                    text: mode.googleButtonText,
                    background: Color.white.opacity(0.04),
                    foreground: .white
                ) {}
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .padding(.bottom, 32)
        .background(
            Color(Color.appGray3).opacity(0.18)
                .ignoresSafeArea()
        )
    }
}

struct AuthButton: View {
    let icon: Image
    let text: String
    let background: Color
    let foreground: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                Text(text)
                    .font(.headline)
            }
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .cornerRadius(10)
        }
    }
}

#Preview {
    Group {
        AuthSheetView(mode: .signup)
            .preferredColorScheme(.dark)
        AuthSheetView(mode: .login)
            .preferredColorScheme(.dark)
    }
} 
