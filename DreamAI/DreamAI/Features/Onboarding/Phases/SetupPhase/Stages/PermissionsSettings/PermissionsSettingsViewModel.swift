//
//  PermissionsSettingsViewModel.swift
//  DreamAI
//
// Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class PermissionsSettingsViewModel: ObservableObject {
    
    // MARK: - Dependencies
    let pushNotificationManager: PushNotificationManager = PushNotificationManager.shared
    
    // MARK: - Published Properties
    // Время теперь берём из pushNotificationManager
    var bedtime: Date {
        get { pushNotificationManager.bedtime }
        set { pushNotificationManager.bedtime = newValue }
    }
    var wakeup: Date {
        get { pushNotificationManager.wakeup }
        set { pushNotificationManager.wakeup = newValue }
    }
    
    // MARK: - Initialization
    init() {}
}
