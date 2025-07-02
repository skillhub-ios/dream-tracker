//
// SubscriptionViewModel.swift
//
// Created by Cesare on 27.06.2025 on Earth.
// 


import Foundation
import SuperwallKit
import Combine
import StoreKit

final class SubscriptionViewModel: ObservableObject {
    @Published var paywallIsPresent: Bool = false
    @Published var activeSubscription: SubscriptionType?
    @Published var selectedSubscription: SubscriptionType = .monthly
    @Published var subscriptionProducts: [SubscriptionProduct] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    init() {
        Superwall.configure(apiKey: "pk_8beac5fd94b375e0e1e2df7bb99af2bf66f9fae6e806eca1")
    }
    
    func showPaywall() {
        Superwall.shared.register(placement: "campaign_trigger")
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
}



enum SubscriptionType: CaseIterable, Identifiable {
    case monthly
    case yearly
    
    var title: String {
        switch self {
        case .monthly: "Monthly"
        case .yearly: "Yearly"
        }
    }
    var id: Self { self }
}

struct ProductIDs {
    static let monthlySubscription = "com.dreamai.monthly.subscription"
    static let yearlySubscription = "com.dreamai.yearly.subscription"
    
    static let allProducts = [
        monthlySubscription,
        yearlySubscription
    ]
}
