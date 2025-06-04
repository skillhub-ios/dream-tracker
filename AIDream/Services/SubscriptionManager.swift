import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: Product.SubscriptionInfo.RenewalState?
    @Published private(set) var error: Error?
    @Published private(set) var isLoading = false
    @Published var expirationDate: Date?
    @Published var currentPlan: String? // "monthly" или "yearly"
    private let productIds = [
        "com.dreamtracker.subscription.monthly",
        "com.dreamtracker.subscription.yearly"
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
      func requestNotificationPermission() {
          UNUserNotificationCenter.current().getNotificationSettings { settings in
              if settings.authorizationStatus != .authorized {
                  print("❌ Уведомления не разрешены пользователем")
              }
          }
    }

    func scheduleNotification(at date: Date, identifier: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = "AIDream"
        content.body = body
        content.sound = .default

        var triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
        triggerDate.second = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
            } else {
                print("✅ Уведомление добавлено: \(identifier) на \(triggerDate)")
            }
        }
    }

      func removeNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bedtime", "wakeUp"])
    }
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                await self.handleTransactionResult(result)
            }
        }
    }
    
    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) async {
        guard case .verified(let transaction) = result else {
            return
        }
        
        await transaction.finish()
        await self.updateSubscriptionStatus()
    }
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            subscriptions = try await Product.products(for: productIds)
        } catch {
            self.error = error
            print("Failed to load products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            guard case .verified(let transaction) = verification else {
                throw SubscriptionError.verificationFailed
            }
            await transaction.finish()
            await updateSubscriptionStatus()
        case .userCancelled:
            throw SubscriptionError.userCancelled
        case .pending:
            throw SubscriptionError.pending
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    func updateSubscriptionStatus() async {
        purchasedSubscriptions.removeAll()
        expirationDate = nil
        currentPlan = nil
        for await result in StoreKit.Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                purchasedSubscriptions.append(subscription)
                // Определяем тип подписки
                if subscription.id.contains("monthly") {
                    currentPlan = "monthly"
                } else if subscription.id.contains("yearly") {
                    currentPlan = "yearly"
                }
                // Получаем дату окончания из transaction
                if let expirationDate = transaction.expirationDate {
                    DispatchQueue.main.async {
                        self.expirationDate = expirationDate
                    }
                }
            }
        }
    }
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }
        
        try await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    var isPremium: Bool {
        !purchasedSubscriptions.isEmpty
    }
    
    var isTrialAvailable: Bool {
        UserDefaults.standard.bool(forKey: "trialUsed") == false
    }
    
    func startTrial() {
        UserDefaults.standard.set(Date(), forKey: "trialStartDate")
        UserDefaults.standard.set(true, forKey: "trialUsed")
    }
    
    var isTrialActive: Bool {
        guard let trialStartDate = UserDefaults.standard.object(forKey: "trialStartDate") as? Date else {
            return false
        }
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 3, to: trialStartDate) ?? Date()
        return Date() < trialEndDate
    }
    
    var subscriptionStatus: SubscriptionStatus {
        if isPremium {
            return .premium
        } else if isTrialActive {
            return .trial
        } else {
            return .free
        }
    }
}

enum SubscriptionError: LocalizedError {
    case verificationFailed
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .verificationFailed:
            return "Ошибка верификации покупки"
        case .userCancelled:
            return "Покупка отменена"
        case .pending:
            return "Покупка ожидает подтверждения"
        case .unknown:
            return "Неизвестная ошибка"
        }
    }
}

enum SubscriptionPlan: String {
    case monthly = "com.dreamtracker.subscription.monthly"
    case yearly = "com.dreamtracker.subscription.yearly"
    
    var price: String {
        switch self {
        case .monthly: return "299 ₽"
        case .yearly: return "2990 ₽"
        }
    }
    
    var period: String {
        switch self {
        case .monthly: return "месяц"
        case .yearly: return "год"
        }
    }
}
