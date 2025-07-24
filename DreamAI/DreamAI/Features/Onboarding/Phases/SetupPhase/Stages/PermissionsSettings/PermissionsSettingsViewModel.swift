//
//  PermissionsSettingsViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PermissionsSettingsViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let pushNotificationManager: PushNotificationManager = PushNotificationManager.shared
    
    // MARK: - Published Properties
    @Published var remindersEnabled: Bool = false
    @Published var bedtime: Date = DateComponents(calendar: .current, hour: 20, minute: 0).date ?? Date()
    @Published var wakeup: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    
    // MARK: - Initialization
    init() {
        initializeNotificationStatus()
    }
    
    private func initializeNotificationStatus() {
        Task {
            let isEnabled = await pushNotificationManager.areNotificationsEnabled()
            await MainActor.run {
                self.remindersEnabled = isEnabled
            }
        }
    }
}
