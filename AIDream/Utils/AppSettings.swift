import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.shared.set(isDarkMode, forKey: Constants.isDarkModeKey)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    @Published var language: String {
        didSet {
            UserDefaults.shared.set(language, forKey: "language")
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    @Published var notificationsEnabled: Bool {
        didSet {
            UserDefaults.shared.set(notificationsEnabled, forKey: Constants.notificationsEnabledKey)
            if notificationsEnabled {
                requestNotificationPermission()
            }
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    @Published var sleepTime: Date {
        didSet {
            UserDefaults.shared.set(sleepTime, forKey: Constants.sleepTimeKey)
            updateNotificationSchedule()
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    @Published var wakeTime: Date {
        didSet {
            UserDefaults.shared.set(wakeTime, forKey: Constants.wakeTimeKey)
            updateNotificationSchedule()
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    @Published var useFaceID: Bool {
        didSet {
            UserDefaults.shared.set(useFaceID, forKey: Constants.useFaceIDKey)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    private init() {
        self.isDarkMode = UserDefaults.shared.bool(forKey: Constants.isDarkModeKey)
        self.language = UserDefaults.shared.string(forKey: "language") ?? "ru"
        self.notificationsEnabled = UserDefaults.shared.bool(forKey: Constants.notificationsEnabledKey)
        self.sleepTime = UserDefaults.shared.object(forKey: Constants.sleepTimeKey) as? Date ?? Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
        self.wakeTime = UserDefaults.shared.object(forKey: Constants.wakeTimeKey) as? Date ?? Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
        self.useFaceID = UserDefaults.shared.bool(forKey: Constants.useFaceIDKey)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.updateNotificationSchedule()
                } else {
                    self.notificationsEnabled = false
                }
            }
        }
    }
    
    private func updateNotificationSchedule() {
        guard notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = Constants.dreamReminderTitle
        content.body = Constants.dreamReminderBody
        content.sound = .default
        
        // Создаем триггер для времени пробуждения
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: wakeTime)
        let wakeTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Создаем триггер для времени сна
        dateComponents = Calendar.current.dateComponents([.hour, .minute], from: sleepTime)
        let sleepTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Удаляем старые уведомления
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Добавляем новые уведомления
        let wakeRequest = UNNotificationRequest(identifier: "wakeReminder", content: content, trigger: wakeTrigger)
        let sleepRequest = UNNotificationRequest(identifier: "sleepReminder", content: content, trigger: sleepTrigger)
        
        UNUserNotificationCenter.current().add(wakeRequest)
        UNUserNotificationCenter.current().add(sleepRequest)
    }
    
    func resetSettings() {
        isDarkMode = false
        language = "ru"
        notificationsEnabled = false
        sleepTime = Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date()
        wakeTime = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date()
        useFaceID = false
    }
} 