import Foundation
import StoreKit

class FeatureAccessService: ObservableObject {
    static let shared = FeatureAccessService()
    
    @Published private(set) var isUnlimitedAIEnabled = false
    @Published private(set) var isExportEnabled = false
    @Published private(set) var isICloudSyncEnabled = false
    
    private let subscriptionService = SubscriptionService.shared
    private let trialPeriodDays = 3
    private let userDefaults = UserDefaults.standard
    
    private let trialStartDateKey = "trialStartDate"
    private let hasUsedTrialKey = "hasUsedTrial"
    
    init() {
        setupSubscriptionObserver()
        checkTrialStatus()
    }
    
    private func setupSubscriptionObserver() {
        Task {
            for await _ in subscriptionService.$purchasedSubscriptions.values {
                await updateFeatureAccess()
            }
        }
    }
    
    @MainActor
    private func updateFeatureAccess() {
        let hasActiveSubscription = !subscriptionService.purchasedSubscriptions.isEmpty
        let isInTrialPeriod = checkTrialStatus()
        
        isUnlimitedAIEnabled = hasActiveSubscription || isInTrialPeriod
        isExportEnabled = hasActiveSubscription || isInTrialPeriod
        isICloudSyncEnabled = hasActiveSubscription || isInTrialPeriod
    }
    
    private func checkTrialStatus() -> Bool {
        if userDefaults.bool(forKey: hasUsedTrialKey) {
            return false
        }
        
        if let startDate = userDefaults.object(forKey: trialStartDateKey) as? Date {
            let trialEndDate = startDate.addingTimeInterval(TimeInterval(trialPeriodDays * 24 * 60 * 60))
            return Date() < trialEndDate
        } else {
            userDefaults.set(Date(), forKey: trialStartDateKey)
            return true
        }
    }
    
    func startTrial() {
        userDefaults.set(Date(), forKey: trialStartDateKey)
        userDefaults.set(false, forKey: hasUsedTrialKey)
        updateFeatureAccess()
    }
    
    func endTrial() {
        userDefaults.set(true, forKey: hasUsedTrialKey)
        updateFeatureAccess()
    }
    
    func canAccessFeature(_ feature: Feature) -> Bool {
        switch feature {
        case .unlimitedAI:
            return isUnlimitedAIEnabled
        case .export:
            return isExportEnabled
        case .iCloudSync:
            return isICloudSyncEnabled
        }
    }
}

enum Feature {
    case unlimitedAI
    case export
    case iCloudSync
} 