//
//  DreamInterpretationViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

class DreamInterpretationViewModel: ObservableObject {   
    
    @Published var model: DreamInterpretationFullModel? = nil
    @Published var selectedResonance: ResonanceOption = .yes
    
    //MARK: - Methods
    
    func fetchInterpretation() async {
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
        model = dreamInterpretationFullModel
        
    }
}
