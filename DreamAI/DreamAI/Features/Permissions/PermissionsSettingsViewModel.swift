//
//  PermissionsSettingsViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI

final class PermissionsSettingsViewModel: ObservableObject {
    @Published var remindersEnabled: Bool = true
    @Published var bedtime: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    @Published var wakeup: Date = DateComponents(calendar: .current, hour: 8, minute: 0).date ?? Date()
    @Published var faceIDEnabled: Bool = true
    @Published var selectedLanguage: Language? = .english
    
    let allLanguages = Language.allCases
}
