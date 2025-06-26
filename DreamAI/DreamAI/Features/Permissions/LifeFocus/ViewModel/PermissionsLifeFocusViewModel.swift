//
//  PermissionsLifeFocusViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation

final class PermissionsLifeFocusViewModel: ObservableObject {
    @Published var selectedAreas: Set<LifeFocusArea> = []
    let allAreas: [LifeFocusArea] = LifeFocusArea.all
    
    func toggleArea(_ area: LifeFocusArea) {
        if selectedAreas.contains(area) {
            selectedAreas.remove(area)
        } else if selectedAreas.count < 3 {
            selectedAreas.insert(area)
        }
    }
    
    var canProceed: Bool {
        (1...3).contains(selectedAreas.count)
    }
}
