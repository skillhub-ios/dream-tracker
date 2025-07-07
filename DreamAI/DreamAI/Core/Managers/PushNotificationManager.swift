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
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Request notification permissions for local notifications
    func requestPermissions() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
                self.isRegistered = granted
            }
            
            if granted {
                await scheduleDreamReminders()
            }
        } catch {
            print("Error requesting notification permissions: \(error)")
        }
    }
    
    /// Schedule local notifications for dream reminders
    func scheduleDreamReminders(bedtime: Date? = nil, wakeup: Date? = nil) async {
        guard authorizationStatus == .authorized else { return }
        
        // Clear existing notifications
        clearAllPendingNotifications()
        
        // Schedule bedtime reminder
        if let bedtime = bedtime {
            await scheduleBedtimeReminder(at: bedtime)
        }
        
        // Schedule wake-up reminder
        if let wakeup = wakeup {
            await scheduleWakeupReminder(at: wakeup)
        }
    }
    
    /// Schedule bedtime reminder notification
    private func scheduleBedtimeReminder(at time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Dream Time"
        content.body = "Time to record your dreams before sleep"
        content.sound = .default
        content.categoryIdentifier = "DREAM_REMINDER"
        
        // Create daily trigger for bedtime
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "bedtime_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Bedtime reminder scheduled for \(time)")
        } catch {
            print("Error scheduling bedtime reminder: \(error)")
        }
    }
    
    /// Schedule wake-up reminder notification
    private func scheduleWakeupReminder(at time: Date) async {
        let content = UNMutableNotificationContent()
        content.title = "Dream Recall"
        content.body = "Don't forget to record your dreams from last night"
        content.sound = .default
        content.categoryIdentifier = "DREAM_REMINDER"
        
        // Create daily trigger for wake-up time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "wakeup_reminder",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("Wake-up reminder scheduled for \(time)")
        } catch {
            print("Error scheduling wake-up reminder: \(error)")
        }
    }
    
    /// Disable notifications and clear all scheduled reminders
    func disableNotifications() {
        clearAllPendingNotifications()
        clearAllDeliveredNotifications()
        
        Task {
            await updateAuthorizationStatus(.denied)
        }
        
        isRegistered = false
    }
    
    /// Get current notification settings
    func getNotificationSettings() async -> UNNotificationSettings {
        return await UNUserNotificationCenter.current().notificationSettings()
    }
    
    /// Check if notifications are enabled
    func areNotificationsEnabled() async -> Bool {
        let settings = await getNotificationSettings()
        await updateAuthorizationStatus(settings.authorizationStatus)
        return settings.authorizationStatus == .authorized
    }
    
    /// Update authorization status
    private func updateAuthorizationStatus(_ status: UNAuthorizationStatus? = nil) async {
        let settings = await getNotificationSettings()
        let currentStatus = status ?? settings.authorizationStatus
        
        await MainActor.run {
            self.authorizationStatus = currentStatus
        }
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
    
    /// Get pending notifications for debugging
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
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
        // Handle different notification types
        if let categoryIdentifier = userInfo["categoryIdentifier"] as? String {
            switch categoryIdentifier {
            case "DREAM_REMINDER":
                // Navigate to create dream view
                print("Dream reminder tapped - navigate to create dream")
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
        // This method is no longer used as we're focusing on local notifications
    }
    
    /// Handle registration failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // This method is no longer used as we're focusing on local notifications
    }
    
    /// Handle incoming remote notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // This method is no longer used as we're focusing on local notifications
        completionHandler(.newData)
    }
} 
