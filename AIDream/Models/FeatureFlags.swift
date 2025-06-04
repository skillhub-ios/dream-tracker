import Foundation

enum FeatureFlag {
    case unlimitedAI
    case export
    case iCloudSync
    
    var isEnabled: Bool {
        switch self {
        case .unlimitedAI:
            return SubscriptionManager.shared.isPremium || SubscriptionManager.shared.isTrialActive
        case .export:
            return SubscriptionManager.shared.isPremium || SubscriptionManager.shared.isTrialActive
        case .iCloudSync:
            return SubscriptionManager.shared.isPremium || SubscriptionManager.shared.isTrialActive
        }
    }
    
    var title: String {
        switch self {
        case .unlimitedAI:
            return "Неограниченное использование ИИ"
        case .export:
            return "Экспорт данных"
        case .iCloudSync:
            return "Синхронизация с iCloud"
        }
    }
    
    var description: String {
        switch self {
        case .unlimitedAI:
            return "Создавайте неограниченное количество снов с помощью ИИ"
        case .export:
            return "Экспортируйте ваши сны в различных форматах"
        case .iCloudSync:
            return "Синхронизируйте ваши сны между устройствами"
        }
    }
} 