//
// SubscriptionViewModel.swift
//
// Created by Cesare on 27.06.2025 on Earth.
//

import Foundation
import SuperwallKit
import Combine
import StoreKit

@MainActor
final class SubscriptionViewModel: ObservableObject {
    @Published var subscriptionProducts: [SubscriptionProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isSubscribed: Bool = false
    @Published var subscriptionType: SubscriptionType = .other
    @Published var subscriptionExpiry: Date?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        Superwall.configure(apiKey: "pk_8beac5fd94b375e0e1e2df7bb99af2bf66f9fae6e806eca1")
        loadProducts()
        addSubscriptions()
    }
    
    func showPaywall() {
        Superwall.shared.register(placement: "campaign_trigger")
    }
    
    private func addSubscriptions() {
        Superwall.shared.$subscriptionStatus
            .map(subscriptionDetails)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] subscriptionType, isSubscribed in
                self?.isSubscribed = isSubscribed
                self?.informAboutSubscriptionStatus(isSubscribed)
                self?.getSubscriptionExpirationDate()
            }
            .store(in: &cancellables)
    }
    
    private func subscriptionDetails(_ status: SuperwallKit.SubscriptionStatus) -> (SubscriptionType, Bool) {
        switch status {
        case .active(let entitlements):
            let hasSubscription = true
            if entitlements.contains(where: { $0.id.contains("monthly") }) {
                return (.monthly, hasSubscription)
            } else if entitlements.contains(where: { $0.id.contains("yearly") }) {
                return (.yearly, hasSubscription)
            } else {
                return (.other, hasSubscription)
            }
        case .unknown, .inactive:
            return (.other, false)
        }
    }
    
    func loadProducts() {
        Task {
            await loadSubscriptionProducts()
        }
    }
    
    func getSubscriptionExpirationDate() {
        Task {
            await getActiveSubscriptionDetails()
        }
    }
    
    private func loadSubscriptionProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let products = try await Product.products(for: SubscriptionConstants.ProductIDs.allProducts)
            
            let subscriptionProducts = products.compactMap { product -> SubscriptionProduct? in
                if product.id.contains("monthly") {
                    return SubscriptionProduct(product: product, type: .monthly)
                } else if product.id.contains("yearly") {
                    return SubscriptionProduct(product: product, type: .yearly, isPopular: true)
                }
                return nil
            }
            
            self.subscriptionProducts = subscriptionProducts.sorted { product1, product2 in
                // Sort yearly first (popular), then monthly
                if product1.type == .yearly && product2.type == .monthly {
                    return true
                }
                return false
            }
            
        } catch {
            errorMessage = "\(SubscriptionConstants.ErrorMessages.loadProductsFailed): \(error.localizedDescription)"
            showError = true
        }
    }
    
    private func informAboutSubscriptionStatus(_ hasSubscription: Bool) {
        NotificationCenter.default.post(
            name: Notification.Name(PublisherKey.hasSubscription.rawValue),
            object: nil,
            userInfo: ["value": hasSubscription]
        )
    }
    
    private func getActiveSubscriptionDetails() async  {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productType == .autoRenewable {
                subscriptionExpiry = transaction.expirationDate
                
                let id = transaction.productID
                
                let type: SubscriptionType
                if id.contains("month") {
                    type = .monthly
                } else if id.contains("year") {
                    type = .yearly
                } else {
                    type = .other
                }
                subscriptionType = type
            }
        }
    }
}

enum SubscriptionType {
    case monthly
    case yearly
    case other
    
    func title() -> String {
        switch self {
        case .monthly:
            "Monthly"
        case .yearly:
            "Yearly"
        case .other:
            ""
        }
    }
}
