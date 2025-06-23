//
//  PushNotificationManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import UserNotifications
import UIKit

@MainActor
class PushNotificationManager: NSObject, ObservableObject {
    static let shared = PushNotificationManager()
    
    @Published var isRegistered = false
    @Published var deviceToken: String?
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: - Public Methods
    
    /// Request notification permissions and register for remote notifications
    func requestPermissions() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound, .provisional]
            )
            
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            
            if granted {
                await registerForRemoteNotifications()
            }
        } catch {
            print("Error requesting notification permissions: \(error)")
        }
    }
    
    /// Register for remote notifications
    func registerForRemoteNotifications() async {
        await MainActor.run {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    /// Unregister from remote notifications
    func unregisterFromRemoteNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
        deviceToken = nil
        isRegistered = false
    }
    
    /// Get current notification settings
    func getNotificationSettings() async -> UNNotificationSettings {
        return await UNUserNotificationCenter.current().notificationSettings()
    }
    
    /// Check if notifications are enabled
    func areNotificationsEnabled() async -> Bool {
        let settings = await getNotificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    /// Get device token as formatted string for easy copying
    var deviceTokenString: String? {
        return deviceToken
    }
    
    /// Get device token with formatting for display
    var deviceTokenDisplay: String? {
        guard let token = deviceToken else { return nil }
        return String(token.prefix(20)) + "..."
    }
    
    /// Send local notification for testing
    func sendLocalNotification(title: String, body: String, timeInterval: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending local notification: \(error)")
            }
        }
    }
    
    /// Clear all pending notifications
    func clearAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// Clear all delivered notifications
    func clearAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // MARK: - Private Methods
    
    /// Handle device token registration
    private func handleDeviceToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        self.deviceToken = token
        self.isRegistered = true
        
        print("Device Token: \(token)")
        
        // Here you would typically send the token to your backend server
        // sendTokenToServer(token)
    }
    
    /// Handle registration error
    private func handleRegistrationError(_ error: Error) {
        print("Failed to register for remote notifications: \(error)")
        self.isRegistered = false
    }
    
    /// Send token to your backend server (implement as needed)
    private func sendTokenToServer(_ token: String) {
        // TODO: Implement sending token to your backend
        // This is where you would make an API call to your server
        // to register the device token for push notifications
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    
    /// Called when a notification is received while the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show the notification even when the app is in the foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when user taps on a notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle the notification tap
        handleNotificationTap(userInfo: userInfo)
        
        completionHandler()
    }
    
    /// Handle notification tap based on user info
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Extract custom data from notification
        if let customData = userInfo["custom_data"] as? [String: Any] {
            // Handle custom data
            print("Custom data: \(customData)")
        }
        
        // Handle different notification types
        if let notificationType = userInfo["type"] as? String {
            switch notificationType {
            case "dream_reminder":
                // Navigate to create dream view
                break
            case "interpretation_ready":
                // Navigate to dream interpretation
                break
            case "general":
                // Handle general notifications
                break
            default:
                break
            }
        }
    }
}

// MARK: - App Delegate Extension

extension PushNotificationManager {
    
    /// Handle successful device token registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        handleDeviceToken(deviceToken)
    }
    
    /// Handle registration failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        handleRegistrationError(error)
    }
    
    /// Handle incoming remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // Handle the remote notification
        print("Received remote notification: \(userInfo)")
        
        // Process the notification data
        if let aps = userInfo["aps"] as? [String: Any] {
            print("APS data: \(aps)")
        }
        
        // Call completion handler
        completionHandler(.newData)
    }
} 