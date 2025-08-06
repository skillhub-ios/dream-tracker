//
//  SubscriptionConstants.swift
//  DreamAI
//
//  Created by Assistant on 2024
//

import Foundation

struct SubscriptionConstants {
    
    // MARK: - Product IDs
    struct ProductIDs {
        static let monthlySubscription = "com.dreamai.monthly.subscription"
        static let yearlySubscription = "com.dreamai.yearly.subscription"
        static let weeklySubscription = "com.dreamai.weekly.subscription"
        
        static let allProducts = [
            monthlySubscription,
            yearlySubscription
        ]
    }
    
    // MARK: - Superwall Events
    struct Events {
        static let showPaywall = "campaign_trigger"
        static let subscriptionStarted = "subscription_started"
        static let subscriptionCancelled = "subscription_cancelled"
        static let subscriptionRestored = "subscription_restored"
        static let purchaseFailed = "purchase_failed"
    }
    
    // MARK: - Localization Keys
    struct Localization {
        static let monthlyTitle = "Месячная подписка"
        static let yearlyTitle = "Годовая подписка"
        static let monthlyDescription = "Полный доступ ко всем функциям на 1 месяц"
        static let yearlyDescription = "Полный доступ ко всем функциям на 1 год"
        static let popularBadge = "ПОПУЛЯРНО"
        static let bestOffer = "Лучшее предложение"
        static let savings = "Экономия"
        static let restorePurchases = "Восстановить покупки"
        static let subscriptionTerms = "Подписка автоматически продлевается, если не отменена за 24 часа до окончания периода. Управлять подпиской можно в настройках App Store."
    }
    
    // MARK: - Features
    struct Features {
        static let aiInterpretation = "ИИ интерпретация снов"
        static let unlimitedInterpretations = "Неограниченные интерпретации"
        static let dreamAnalytics = "Аналитика снов"
        static let cloudSync = "Синхронизация"
        static let privacy = "Приватность"
        
        static let allFeatures = [
            (icon: "brain.head.profile", title: aiInterpretation, description: "Глубокий анализ ваших снов с помощью искусственного интеллекта"),
            (icon: "infinity", title: unlimitedInterpretations, description: "Столько интерпретаций, сколько вам нужно"),
            (icon: "chart.line.uptrend.xyaxis", title: dreamAnalytics, description: "Отслеживайте паттерны и тенденции в ваших снах"),
            (icon: "icloud", title: cloudSync, description: "Ваши сны синхронизируются между устройствами"),
            (icon: "lock.shield", title: privacy, description: "Ваши данные защищены и приватны")
        ]
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let loadProductsFailed = "Ошибка загрузки продуктов"
        static let purchaseFailed = "Ошибка покупки"
        static let restoreFailed = "Ошибка восстановления покупок"
        static let unknownError = "Неизвестная ошибка"
    }
} 
