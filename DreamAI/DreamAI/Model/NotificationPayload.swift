//
//  NotificationPayload.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation

struct NotificationPayload: Codable {
    let aps: APS
    let customData: [String: String]?
    
    struct APS: Codable {
        let alert: Alert?
        let badge: Int?
        let sound: String?
        let category: String?
        let threadId: String?
        
        enum CodingKeys: String, CodingKey {
            case alert, badge, sound, category
            case threadId = "thread-id"
        }
        
        struct Alert: Codable {
            let title: String?
            let body: String?
            let subtitle: String?
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case aps
        case customData = "custom_data"
    }
}

// MARK: - Notification Types

enum NotificationType: String, CaseIterable {
    case dreamReminder = "dream_reminder"
    case interpretationReady = "interpretation_ready"
    case weeklyInsights = "weekly_insights"
    case general = "general"
    
    var title: String {
        switch self {
        case .dreamReminder:
            return "Dream Reminder"
        case .interpretationReady:
            return "Interpretation Ready"
        case .weeklyInsights:
            return "Weekly Insights"
        case .general:
            return "General"
        }
    }
    
    var description: String {
        switch self {
        case .dreamReminder:
            return "Daily reminders to record your dreams"
        case .interpretationReady:
            return "When your dream analysis is complete"
        case .weeklyInsights:
            return "Weekly dream patterns and insights"
        case .general:
            return "General app notifications"
        }
    }
    
    var icon: String {
        switch self {
        case .dreamReminder:
            return "moon.fill"
        case .interpretationReady:
            return "brain.head.profile"
        case .weeklyInsights:
            return "chart.line.uptrend.xyaxis"
        case .general:
            return "bell.fill"
        }
    }
}

// MARK: - Sample Payloads

extension NotificationPayload {
    static func dreamReminder(title: String = "Time to Record Your Dream", body: String = "Don't forget to capture today's dream before it fades away") -> NotificationPayload {
        return NotificationPayload(
            aps: APS(
                alert: APS.Alert(
                    title: title,
                    body: body,
                    subtitle: "DreamAI Reminder"
                ),
                badge: 1,
                sound: "default",
                category: "DREAM_REMINDER",
                threadId: "dream-reminders"
            ),
            customData: [
                "type": NotificationType.dreamReminder.rawValue,
                "action": "create_dream"
            ]
        )
    }
    
    static func interpretationReady(dreamTitle: String) -> NotificationPayload {
        return NotificationPayload(
            aps: APS(
                alert: APS.Alert(
                    title: "Dream Interpretation Ready",
                    body: "Your interpretation for '\(dreamTitle)' is now available",
                    subtitle: "DreamAI Analysis"
                ),
                badge: 1,
                sound: "default",
                category: "INTERPRETATION_READY",
                threadId: "interpretations"
            ),
            customData: [
                "type": NotificationType.interpretationReady.rawValue,
                "action": "view_interpretation",
                "dream_title": dreamTitle
            ]
        )
    }
    
    static func weeklyInsights() -> NotificationPayload {
        return NotificationPayload(
            aps: APS(
                alert: APS.Alert(
                    title: "Weekly Dream Insights",
                    body: "Discover patterns and insights from your dreams this week",
                    subtitle: "DreamAI Weekly Report"
                ),
                badge: 1,
                sound: "default",
                category: "WEEKLY_INSIGHTS",
                threadId: "weekly-insights"
            ),
            customData: [
                "type": NotificationType.weeklyInsights.rawValue,
                "action": "view_insights"
            ]
        )
    }
} 