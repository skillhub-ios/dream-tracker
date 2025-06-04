import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showingLogoutAlert = false
    @State private var showingResetAlert = false
    @State private var showingFeedback = false
    @State private var userProfile: UserProfile? = {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return nil
    }()
    
    var body: some View {
        NavigationView {
            List {
                // Профиль
                Section {
                    if let user = appState.currentUser {
                        HStack {
                            Text(user.email)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(subscriptionManager.subscriptionStatus.rawValue)
                                .foregroundColor(.gray)
                        }
                    }
                } header: {
                    Text("Профиль")
                }
                
                // Персонализация
                if let profile = userProfile {
                    Section("Персонализация") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ощущения от снов: \(profile.dreamFeelings.joined(separator: ", "))")
                            Text("Фокус жизни: \(profile.lifeFocus.joined(separator: ", "))")
                            Text("Возраст: \(profile.ageRange)")
                            Text("Гендер: \(profile.gender)")
                            Text("Вера в значение снов: \(profile.dreamMeaning)")
                            Text("Язык: \(profile.language)")
                        }
                        Button("Изменить") {
                            // TODO: Показать экран редактирования профиля
                        }
                    }
                }
                
                // Внешний вид
//                Section {
//                    Toggle("Темная тема", isOn: $appState.isDarkMode)
//                    
//                    Picker("Язык", selection: $appState.selectedLanguage) {
//                        ForEach(Language.allCases, id: \.self) { language in
//                            Text(language.rawValue).tag(language)
//                        }
//                    }
//                } header: {
//                    Text("Внешний вид")
//                }
                
                // Уведомления
                Section {
                    Toggle("Включить уведомления", isOn: .constant(true))
                    DatePicker("Время сна", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                    DatePicker("Время пробуждения", selection: .constant(Date()), displayedComponents: .hourAndMinute)
                } header: {
                    Text("Уведомления")
                }
                
                // Безопасность
                Section {
                    Toggle("Использовать Face ID", isOn: .constant(true))
                } header: {
                    Text("Безопасность")
                }
                
                // Подписка
                Section {
                    if subscriptionManager.subscriptionStatus == .free {
                        Button("Улучшить до Premium") {
                            // TODO: Show subscription screen
                        }
                    }
                    
                    Button("Восстановить покупки") {
                        Task {
                            try? await subscriptionManager.restorePurchases()
                        }
                    }
                } header: {
                    Text("Подписка")
                }
                
                // Поддержка
                Section {
                    Button("Обратная связь") {
                        showingFeedback = true
                    }
                    
                    Link("Политика конфиденциальности", destination: URL(string: "https://example.com/privacy")!)
                    
                    Link("Условия использования", destination: URL(string: "https://example.com/terms")!)
                } header: {
                    Text("Поддержка")
                }
                
                // Опасная зона
                Section {
                    Button("Сбросить все данные") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                    
                    Button("Выйти") {
                        showingLogoutAlert = true
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Опасная зона")
                }
            }
            .navigationTitle("Настройки")
            .alert("Выйти", isPresented: $showingLogoutAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Выйти", role: .destructive) {
                    Task {
                        try? await SupabaseService().signOut()
                    }
                }
            } message: {
                Text("Вы уверены, что хотите выйти?")
            }
            .alert("Сбросить данные", isPresented: $showingResetAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Сбросить", role: .destructive) {
                    // TODO: Implement data reset
                }
            } message: {
                Text("Все ваши данные будут удалены. Это действие нельзя отменить.")
            }
            .sheet(isPresented: $showingFeedback) {
                ClickbackView()
            }
        }
    }
}

struct ClickbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $feedbackText)
                    .frame(maxHeight: 200)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding()
                
                Button("Отправить") {
                    // TODO: Implement feedback submission
                    dismiss()
                }
                .primaryButtonStyle()
                .padding()
            }
            .navigationTitle("Обратная связь")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
