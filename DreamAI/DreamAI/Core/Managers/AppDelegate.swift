//
//  AppDelegate.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Request notification permissions on app launch
        Task {
            await PushNotificationManager.shared.requestPermissions()
        }
        
        return true
    }
    
    // MARK: - Push Notification Methods
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotificationManager.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PushNotificationManager.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationManager.shared.application(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    // MARK: - Background App Refresh
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle background app refresh
        completionHandler(.newData)
    }
} 