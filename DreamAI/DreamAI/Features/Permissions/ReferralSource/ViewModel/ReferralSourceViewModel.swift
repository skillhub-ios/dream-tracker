//
//  ReferralSourceViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine

final class ReferralSourceViewModel: ObservableObject {
    @Published var selectedSources: Set<ReferralSource> = []
    let allSources: [ReferralSource] = ReferralSource.all
    
    func toggleSource(_ source: ReferralSource) {
        if selectedSources.contains(source) {
            selectedSources.remove(source)
        } else {
            selectedSources.insert(source)
        }
    }
    
    var canProceed: Bool {
        !selectedSources.isEmpty
    }
} 