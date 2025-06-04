import Foundation
import StoreKit
import SuperwallKit

class SuperwallService: ObservableObject {
    @Published var isSubscribed = false
    @Published var error: Error?
    
    private let paywallId = "YOUR_PAYWALL_ID" // #warning("Insert paywall ID here")
    
    init() {
        setupSuperwall()
    }
    
    private func setupSuperwall() {
        // Configure Superwall with your API key
        Superwall.configure(apiKey: "YOUR_API_KEY") // #warning("Insert API key here")
        
        // Register for subscription status updates
//        Superwall.shared.subscriptionStatusDidChange = { [weak self] status in
//            DispatchQueue.main.async {
//                self?.isSubscribed = status == .active
//            }
//        }
    }
    
//    func presentPaywall() async throws {
//        do {
//            try await Superwall.shared.present(paywallId: paywallId)
//        } catch {
//            self.error = error
//            throw error
//        }
//    }
    
//    func restorePurchases() async throws {
//        do {
//            try await Superwall.shared.restorePurchases()
//        } catch {
//            self.error = error
//            throw error
//        }
//    }
    
//    func checkSubscriptionStatus() {
//        Task {
//            do {
//                let status = try await Superwall.shared.subscriptionStatus()
//                DispatchQueue.main.async {
//                    self.isSubscribed = status == .active
//                }
//            } catch {
//                self.error = error
//            }
//        }
//    }
} 
