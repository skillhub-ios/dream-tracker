import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct AuthView: View {
    @EnvironmentObject private var supabaseService: SupabaseService
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Фон
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Нижний модальный блок
            VStack {
                Spacer()
                VStack(spacing: 16) {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.top, 8)

                    Text("Sign up")
                        .font(.headline)
                        .foregroundStyle(.white)

                    SignInWithAppleButton(
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            Task {
                                do {
                                    try await supabaseService.signInWithApple()
                                } catch {
                                    await MainActor.run {
                                        self.errorMessage = error.localizedDescription
                                        self.showingError = true
                                    }
                                }
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)

                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = scene.windows.first?.rootViewController {
                            Task {
                                do {
                                    try await supabaseService.signInWithGoogle(presenting: rootVC)
                                } catch {
                                    await MainActor.run {
                                        self.errorMessage = error.localizedDescription
                                        self.showingError = true
                                    }
                                }
                            }
                        }
                    }) {
                        HStack {
                            Spacer()

                            Image("google") // Используй кастомное изображение Google, если есть: Image("google-icon")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 12)

 
                            Text("Continue with Google")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .frame(height: 50)
                        .background(Color.customSecondaryBackground)
                         
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                }
                .padding(.bottom, 32)
                .background(Color.customBackground)
            }
        }
        .alert("Ошибка", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

