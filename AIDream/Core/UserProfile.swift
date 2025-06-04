import Foundation

struct UserProfile: Codable {
    var dreamFeelings: [String]
    var lifeFocus: [String]
    var ageRange: String
    var gender: String
    var dreamMeaning: String
    var notifications: NotificationsSettings
    var language: String
}

struct NotificationsSettings: Codable {
    var reminders: Bool
    var bedtime: Date
    var wakeup: Date
    var faceID: Bool
} 