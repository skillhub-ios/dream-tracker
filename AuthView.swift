//import SwiftUI
//
//struct AuthView: View {
//    @EnvironmentObject private var supabaseService: SupabaseService
//    @State private var email = ""
//    @State private var password = ""
//    @State private var isSignUp = false
//    @State private var showingError = false
//    @State private var errorMessage = ""
//    @State private var isLoading = false
//    @FocusState private var focusedField: Field?
//    
//    enum Field {
//        case email
//        case password
//    }
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 20) {
//                Image(systemName: "moon.stars.fill")
//                    .font(.system(size: 60))
//                    .foregroundColor(.accentColor)
//                    .padding(.bottom, 20)
//                
//                Text("Dream Tracker")
//                    .font(.largeTitle)
//                    .bold()
//                
//                Text("Отслеживайте и анализируйте свои сны")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.bottom, 40)
//                
//                if !supabaseService.isInitialized {
//                    ProgressView("Инициализация...")
//                } else {
//                    VStack(spacing: 15) {
//                        TextField("Email", text: $email)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .textContentType(.emailAddress)
//                            .keyboardType(.emailAddress)
//                            .autocapitalization(.none)
//                            .focused($focusedField, equals: .email)
//                            .submitLabel(.next)
//                        
//                        SecureField("Пароль", text: $password)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                            .textContentType(isSignUp ? .newPassword : .password)
//                            .focused($focusedField, equals: .password)
//                            .submitLabel(.done)
//                        
//                        Button {
//                            handleAuth()
//                        } label: {
//                            if isLoading {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            } else {
//                                Text(isSignUp ? "Зарегистрироваться" : "Войти")
//                                    .frame(maxWidth: .infinity)
//                            }
//                        }
//                        .buttonStyle(.borderedProminent)
//                        .disabled(email.isEmpty || password.isEmpty || isLoading)
//                        
//                        Button {
//                            withAnimation {
//                                isSignUp.toggle()
//                            }
//                        } label: {
//                            Text(isSignUp ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Зарегистрироваться")
//                                .foregroundColor(.accentColor)
//                        }
//                        .disabled(isLoading)
//                    }
//                    .padding(.horizontal)
//                }
//                
//                Spacer()
//            }
//            .padding()
//            .alert("Ошибка", isPresented: $showingError) {
//                Button("OK", role: .cancel) { }
//            } message: {
//                Text(errorMessage)
//            }
//            .onSubmit {
//                switch focusedField {
//                case .email:
//                    focusedField = .password
//                case .password:
//                    focusedField = nil
//                    handleAuth()
//                case .none:
//                    break
//                }
//            }
//        }
//    }
//    
//    private func handleAuth() {
//        guard !isLoading else { return }
//        
//        Task {
//            isLoading = true
//            do {
//                if isSignUp {
//                    try await supabaseService.signUp(email: email, password: password)
//                } else {
//                    try await supabaseService.signIn(email: email, password: password)
//                }
//            } catch {
//                errorMessage = error.localizedDescription
//                showingError = true
//            }
//            isLoading = false
//        }
//    }
//}
//
//#Preview {
//    AuthView()
//        .environmentObject(SupabaseService())
//} 
