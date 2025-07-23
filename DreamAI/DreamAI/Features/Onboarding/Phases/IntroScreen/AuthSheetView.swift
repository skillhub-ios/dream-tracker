//
//  AuthSheetView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import AuthenticationServices

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
    @StateObject private var authManager = AuthManager.shared
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) private var dismiss
    @State private var bridge = BridgeVCView()
    var isSkipAllowed: Bool = false
    var onSkipAction: (() -> Void)?
    
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
                // Native Apple Sign In Button
                SignInWithAppleButton(mode == .signup ? .signIn : .signUp) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    Task {
                        isLoading = true
                        do {
                            switch result {
                            case .success(let authorization):
                                guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                                    throw NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Apple ID credential"])
                                }
                                
                                try await authManager.signInWithApple(credential: appleIDCredential)
                                dismiss()
                                
                            case .failure(let error):
                                print("Apple Sign In failed: \(error.localizedDescription)")
                                errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
                                showError = true
                            }
                        } catch {
                            print("Error during Apple Sign In: \(error.localizedDescription)")
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                        isLoading = false
                    }
                }
                .frame(height: 50)
                .cornerRadius(10)
                .padding(.horizontal, 0)
                
                AuthButton(
                    icon: Image("google-icon"),
                    text: mode.googleButtonText,
                    background: Color.gray.opacity(0.04),
                    foreground: .white,
                    isLoading: isLoading
                ) {
                    Task {
                        await signInWithGoogle()
                    }
                }
                
                Button {
                    
                } label: {
                    Text("skip")
                }
                .buttonStyle(SkipStyle())
            }
            .padding(.horizontal, 16)
            Spacer()
        }
        .padding(.bottom, 32)
        .background(
            Color(Color.black).opacity(0.18)
                .ignoresSafeArea()
        )
        .alert("Authentication Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .background(bridge.frame(width: 0, height: 0))
        .preferredColorScheme(.dark)
        .logScreenView(ScreenName.login)
    }
    
    private func signInWithGoogle() async {
        isLoading = true
        do {
            try await authManager.signInWithGoogle(presentingViewController: bridge.vc)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

// Bridge view controller for Google Sign-In
struct BridgeVCView: UIViewControllerRepresentable {
    let vc = UIViewController()
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No updates needed
    }
}

struct AuthButton: View {
    let icon: Image
    let text: String
    let background: Color
    let foreground: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foreground))
                        .frame(width: 22, height: 22)
                } else {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
                Text(text)
                    .font(.headline)
            }
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(background)
            .cornerRadius(10)
        }
        .disabled(isLoading)
    }
}

#Preview {
    Text("Hello, World!")
    .sheet(isPresented: .constant(true)) {
        AuthSheetView(mode: .signup)
            .preferredColorScheme(.dark)
    }
}

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>
    
    init(continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>) {
        self.continuation = continuation
        super.init()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            continuation.resume(returning: appleIDCredential)
        } else {
            continuation.resume(throwing: NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Apple ID credential"]))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
}

private enum AssociatedKeys {
    static var delegateKey = "AppleSignInDelegateKey"
} 
