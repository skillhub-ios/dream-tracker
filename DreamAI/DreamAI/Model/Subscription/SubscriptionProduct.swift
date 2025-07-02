//
//  SubscriptionProduct.swift
//  DreamAI
//
//  Created by Assistant on 2024
//

import Foundation
import StoreKit

struct SubscriptionProduct: Identifiable, Hashable {
    let id: String
    let product: Product
    let type: ProductType
    let displayName: String
    let description: String
    let price: String
    let originalPrice: String?
    let savings: String?
    let isPopular: Bool
    
    enum ProductType {
        case monthly
        case yearly
        
        var period: String {
            switch self {
            case .monthly:
                return "месяц"
            case .yearly:
                return "год"
            }
        }
    }
    
    init(product: Product, type: ProductType, isPopular: Bool = false) {
        self.id = product.id
        self.product = product
        self.type = type
        self.isPopular = isPopular
        
        // Set display name
        switch type {
        case .monthly:
            self.displayName = SubscriptionConstants.Localization.monthlyTitle
        case .yearly:
            self.displayName = SubscriptionConstants.Localization.yearlyTitle
        }
        
        // Set description
        switch type {
        case .monthly:
            self.description = SubscriptionConstants.Localization.monthlyDescription
        case .yearly:
            self.description = SubscriptionConstants.Localization.yearlyDescription
        }
        
        // Format price
        self.price = product.displayPrice
        
        // Calculate savings for yearly subscription
        if type == .yearly {
            // Assuming monthly price is available for comparison
            if let monthlyProduct = Self.getMonthlyProduct(from: [product]) {
                let monthlyPrice = monthlyProduct.price
                let yearlyPrice = product.price
                let yearlyInMonths: Decimal = 12
                let totalMonthlyPrice = monthlyPrice * yearlyInMonths
                let savings = totalMonthlyPrice - yearlyPrice

                let savingsDouble = (savings as NSDecimalNumber).doubleValue
                let totalMonthlyPriceDouble = (totalMonthlyPrice as NSDecimalNumber).doubleValue
                let currencyCode = product.priceFormatStyle.currencyCode

                if savings > 0 {
                    self.savings = "\(SubscriptionConstants.Localization.savings) \(savingsDouble.formatted(.currency(code: currencyCode)))"
                    self.originalPrice = (totalMonthlyPriceDouble / 12).formatted(.currency(code: currencyCode))
                } else {
                    self.savings = nil
                    self.originalPrice = nil
                }
            } else {
                self.savings = nil
                self.originalPrice = nil
            }
        } else {
            self.savings = nil
            self.originalPrice = nil
        }
    }
    
    private static func getMonthlyProduct(from products: [Product]) -> Product? {
        return products.first { $0.id.contains("monthly") || $0.id.contains("month") }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SubscriptionProduct, rhs: SubscriptionProduct) -> Bool {
        return lhs.id == rhs.id
    }
} 
