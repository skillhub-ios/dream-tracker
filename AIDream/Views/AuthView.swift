import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct AuthView: View {
    @EnvironmentObject private var supabaseService: SupabaseService
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 20)
                
                Text("Dream Tracker")
                    .font(.largeTitle)
                    .bold()
                
                Text("Отслеживайте и анализируйте свои сны")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40)
                
                if !supabaseService.isInitialized {
                    ProgressView("Инициализация...")
                } else {
                    VStack(spacing: 16) {
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
                        .padding(.horizontal)

                        GoogleSignInButton {
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
                        }
                        .frame(height: 50)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding()
            .alert("Ошибка", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(SupabaseService())
} 