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
    @Published var contentState: ContentStateType = .loading
    
    //MARK: - Methods
    
    func fetchInterpretation() async {
        contentState = .loading
        model = nil
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000) // 2 second delay
            model = dreamInterpretationFullModel
            contentState = Bool.random() ? .success : .error(NSError(domain: "Test", code: 1)) 
        } catch {
            contentState = .error(error)
        }
    }
}
