import Foundation

enum Constants {
    // API Keys
    static let openAIKey = "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"
    static let supabaseURL = "YOUR_SUPABASE_URL" // #warning("Insert Supabase URL here")
    static let supabaseKey = "YOUR_SUPABASE_KEY" // #warning("Insert Supabase key here")
    static let superwallKey = "YOUR_SUPERWALL_KEY" // #warning("Insert Superwall key here")
    
    // App Settings
    static let appName = "Dream Tracker"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // User Defaults Keys
    static let userDefaultsSuite = "group.com.yourcompany.dreamtracker"
    static let lastSyncDateKey = "lastSyncDate"
    static let isDarkModeKey = "isDarkMode"
    static let notificationsEnabledKey = "notificationsEnabled"
    static let sleepTimeKey = "sleepTime"
    static let wakeTimeKey = "wakeTime"
    static let useFaceIDKey = "useFaceID"
    
    // Notifications
    static let dreamReminderIdentifier = "dreamReminder"
    static let dreamReminderTitle = "Время записать сон"
    static let dreamReminderBody = "Не забудьте записать свой сон, пока он еще свеж в памяти"
    
    // File Names
    static let backupFileName = "dreams_backup.json"
    
    // Time Intervals
    static let defaultReminderTime: TimeInterval = 3600 // 1 hour
    static let syncInterval: TimeInterval = 1800 // 30 minutes
    
    // Limits
    static let maxDreamLength = 10000
    static let maxTagsPerDream = 5
    static let maxDreamsPerDay = 10
    
    // URLs
    static let privacyPolicyURL = "https://yourcompany.com/privacy"
    static let termsOfServiceURL = "https://yourcompany.com/terms"
    static let supportEmail = "support@yourcompany.com"
    
    // Feature Flags
    static let isVoiceRecordingEnabled = true
    static let isFaceIDEnabled = true
    static let isCloudSyncEnabled = true
    static let isPremiumFeaturesEnabled = true
} 