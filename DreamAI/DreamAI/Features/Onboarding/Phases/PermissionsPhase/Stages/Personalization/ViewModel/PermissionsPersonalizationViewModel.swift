//
//  PermissionsPersonalizationViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

final class PermissionsPersonalizationViewModel: ObservableObject {
    @Published var selectedAge: AgeRange = .notToSay
    @Published var selectedGender: Gender = .preferNotToSay
    @Published var selectedBelief: DreamBelief?
    
    let allAges = AgeRange.allCases
    let allGenders = Gender.allCases
    let allBeliefs = DreamBelief.allCases
    
    var canProceed: Bool {
        selectedBelief != nil
    }
}

enum DreamBelief: String, CaseIterable, Identifiable, Hashable {
    case yes = "Yes"
    case somewhat = "Somewhat"
    case notReally = "Not really"
    
    var id: String { rawValue }
    var displayTitle: LocalizedStringKey {
        switch self {
        case .yes: "yes"
        case .somewhat: "somewhat"
        case .notReally: "notReally"
        }
    }
}
