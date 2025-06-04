import Foundation
import Supabase
import AuthenticationServices
import GoogleSignIn

extension SupabaseService {
    
    func signInWithGoogle(presenting viewController: UIViewController) async throws {
        guard let client = client else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Клиент не инициализирован"])
        }

        let config = GIDConfiguration(clientID: "308207137740-c4mohdt4m35hjgc3dusmet4r39e21s5g.apps.googleusercontent.com")

        // Метод signIn изменился, теперь используется signIn(withPresenting:)
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        let user = result.user

        guard let idToken = user.idToken?.tokenString else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "ID Token отсутствует"])
        }


        let response = try await client.auth.signInWithIdToken(
            credentials: .init(
                provider: .google,
                idToken: idToken
            )
        )

        await MainActor.run {
            self.currentUser = User(
                id: response.user.id.uuidString,
                email: response.user.email ?? "",
                displayName: user.profile?.name,
                subscriptionStatus: .free,
                settings: AppUserSettings(
                    isDarkMode: false,
                    language: .russian,
                    notificationsEnabled: false,
                    sleepTime: Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date(),
                    wakeTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
                    useFaceID: false
                )
            )
            self.isAuthenticated = true
        }
    }
}

class SupabaseService: ObservableObject {
    private var client: SupabaseClient?
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var error: Error?
    @Published var isInitialized = false
    
    init() {
        print("SupabaseService: Инициализация...")
        Task {
            await initializeClient()
        }
    }
    func signOut() async throws {
        guard let client = self.client else {
            print("SupabaseService: Клиент не инициализирован")
            return
        }
        
        try await client.auth.signOut()
        
        await MainActor.run {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }


     func initializeClient() async {
        do {
            print("SupabaseService: Создание клиента...")
            let supabaseURL = URL(string: "https://nmzzxpppivylrnzsbmzu.supabase.co")!
            let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5tenp4cHBwaXZ5bHJuenNibXp1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc5NDUzNTYsImV4cCI6MjA2MzUyMTM1Nn0.V7FV8pUKMLFanGJSHiohju0bQixJqkOXw_SF067VKnk"
            
            let client = SupabaseClient(
                supabaseURL: supabaseURL,
                supabaseKey: supabaseKey
            )
            
            await MainActor.run {
                self.client = client
                self.isInitialized = true
            }
            
            // Проверяем сессию после инициализации
            print("SupabaseService: Проверка сессии...")
            do {
                let session = try await client.auth.session
                print("SupabaseService: Сессия найдена")
                await MainActor.run {
                    self.isAuthenticated = true
                    self.currentUser = User(
                        id: session.user.id.uuidString,
                        email: session.user.email ?? "",
                        displayName: session.user.userMetadata["name"] as? String,
                        subscriptionStatus: .free,
                        settings: AppUserSettings(
                            isDarkMode: false,
                            language: .russian,
                            notificationsEnabled: false,
                            sleepTime: Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date(),
                            wakeTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
                            useFaceID: false
                        )
                    )
                }
            } catch {
                print("SupabaseService: Нет активной сессии - это нормально при первом запуске")
            }
            
        } catch {
            print("SupabaseService: Ошибка инициализации клиента - \(error.localizedDescription)")
            await MainActor.run {
                self.error = error
                self.isInitialized = true
            }
        }
    }
    
    // MARK: - Аутентификация через Apple
    
    func signInWithApple() async throws {
        print("SupabaseService: Попытка входа через Apple...")
        guard let client = client else {
            print("SupabaseService: Клиент не инициализирован при попытке входа")
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Клиент не инициализирован"])
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let result = try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate(continuation: continuation)
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
        }
        
        guard let appleIDCredential = result as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let token = String(data: identityToken, encoding: .utf8) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Не удалось получить токен Apple"])
        }
        
        do {
            let response = try await client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .apple,
                    idToken: token
                )
            )
            
            print("SupabaseService: Вход через Apple успешен")
            await MainActor.run {
                self.currentUser = User(
                    id: response.user.id.uuidString,
                    email: response.user.email ?? "",
                    displayName: appleIDCredential.fullName?.givenName,
                    subscriptionStatus: .free,
                    settings: AppUserSettings(
                        isDarkMode: false,
                        language: .russian,
                        notificationsEnabled: false,
                        sleepTime: Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date(),
                        wakeTime: Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
                        useFaceID: false
                    )
                )
                self.isAuthenticated = true
            }
        } catch {
            print("SupabaseService: Ошибка входа через Apple - \(error.localizedDescription)")
            await MainActor.run {
                self.error = error
            }
            throw error
        }
    }
    
//    func signOut() async throws {
//        print("SupabaseService: Попытка выхода...")
//        guard let client = client else {
//            print("SupabaseService: Клиент не инициализирован при попытке выхода")
//            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Клиент не инициализирован"])
//        }
//        
//        do {
//            try await client.auth.signOut()
//            print("SupabaseService: Выход успешен")
//            await MainActor.run {
//                self.currentUser = nil
//                self.isAuthenticated = false
//            }
//        } catch {
//            print("SupabaseService: Ошибка выхода - \(error.localizedDescription)")
//            await MainActor.run {
//                self.error = error
//            }
//            throw error
//        }
//    }
    
    // MARK: - Dreams Sync
    
    func syncDreams() async throws {
        guard let user = currentUser else { return }
        
        // Получаем несинхронизированные сны
        let unsyncedDreams = try await fetchUnsyncedDreams()
        
        // Загружаем их в Supabase
        for dream in unsyncedDreams {
            try await uploadDream(dream)
        }
        
        // Получаем сны с сервера
//        let serverDreams = try await fetchServerDreams()
        
        // Обновляем локальную базу
//        try await updateLocalDreams(with: serverDreams)
    }
    
    private func fetchUnsyncedDreams() async throws -> [DreamEntry] {
        // TODO: Implement fetching unsynced dreams from CoreData
        return []
    }
    
    private func uploadDream(_ dream: DreamEntry) async throws {
        let dreamData: [String: Any] = [
            "id": dream.id?.uuidString ?? "",
            "content": dream.content ?? "",
            "date": dream.date?.ISO8601Format() ?? "",
            "mood": dream.mood ?? "",
            "tags": dream.tags ?? [],
//            "interpretation": dream.interpretation,
            "created_at": dream.createdAt?.ISO8601Format() ?? "",
            "updated_at": dream.updatedAt?.ISO8601Format() ?? ""
        ]
        
//        try await client.database
//            .from("dreams")
//            .upsert(dreamData)
//            .execute()
    }
    
//    private func fetchServerDreams() async throws -> [[String: Any]] {
//        let response = try await client.database
//            .from("dreams")
//            .select()
//            .execute()
//        
//        return response.data
//    }
    
    private func updateLocalDreams(with serverDreams: [[String: Any]]) async throws {
        // TODO: Implement updating local dreams with server data
    }
    
    // MARK: - Backup & Restore
    
//    func backupDreams() async throws -> Data {
////        let dreams = try await fetchAllDreams()
////        return try JSONEncoder().encode(dreams)
//    }
    
//    func restoreDreams(from data: Data) async throws {
////        let dreams = try JSONDecoder().decode([DreamEntry].self, from: data)
////        try await importDreams(dreams)
//    }
//    
    private func fetchAllDreams() async throws -> [DreamEntry] {
        // TODO: Implement fetching all dreams from CoreData
        return []
    }
    
    private func importDreams(_ dreams: [DreamEntry]) async throws {
        // TODO: Implement importing dreams to CoreData
    }
}

// MARK: - Apple Sign In Delegate

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
} 
