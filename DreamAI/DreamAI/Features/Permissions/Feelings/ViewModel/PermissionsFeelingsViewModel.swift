//
//  PermissionsFeelingsViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine

final class PermissionsFeelingsViewModel: ObservableObject {
    @Published var selectedFeelings: Set<DreamFeeling> = []
    let allFeelings: [DreamFeeling] = DreamFeeling.all
    
    func toggleFeeling(_ feeling: DreamFeeling) {
        if selectedFeelings.contains(feeling) {
            selectedFeelings.remove(feeling)
        } else {
            selectedFeelings.insert(feeling)
        }
    }
    
    var canProceed: Bool {
        !selectedFeelings.isEmpty
    }
} 