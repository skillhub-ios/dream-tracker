//
// FirebaseAnalyticsManager.swift
//
// Created by Cesare on 10.07.2025 on Earth.
//


import Foundation
import FirebaseAnalytics

final class FirebaseAnalyticsManager {
    
    func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}

enum AnalyticsEvent {
    case useApp(source: String?)
    case trialStarted(productId: String, source: String?)
    case subscribed(productId: String, price: Double, currency: String)
    case premiumFeatureUsed(feature: String, screen: String)
    case screenViewed(name: String)
    
    var name: String {
        switch self {
        case .useApp:
            return "use_app"
        case .trialStarted:
            return "trial_start"
        case .subscribed:
            return "subscribe"
        case .premiumFeatureUsed:
            return "premium_feature_used"
        case .screenViewed:
            return "screen_view"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .useApp(let source):
            return ["source": source ?? "unknown"]
        case .trialStarted(let productId, let source):
            return [
                "product_id": productId,
                "source": source ?? "unknown"
            ]
        case .subscribed(let productId, let price, let currency):
            return [
                "product_id": productId,
                "price": price,
                "currency": currency
            ]
        case .premiumFeatureUsed(let feature, let screen):
            return [
                "feature": feature,
                "screen": screen
            ]
        case .screenViewed(let name):
            return [
                "screen_name": name
            ]
        }
    }
}

enum ScreenName {
    static let main = "Main"
    static let login = "Login"
    static let onboarding = "Onboarding"
    static let createDream = "CreateDream"
    static let editDream = "EditDream"
    static let interpretation = "Interpretation"
    static let paywall = "Paywall"
    static let profile = "Profile"
}

enum PremiumFeature {
    static let hideContent = "HideContent"
    static let interpretDream = "InterpretDream"
    static let selectMood = "SelectMood"
}
