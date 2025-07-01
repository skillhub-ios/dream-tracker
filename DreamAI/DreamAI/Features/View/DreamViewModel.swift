//
//  DreamViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 01/07/25.
//

import SwiftUI

class DreamViewModel: ObservableObject {
    
    // MARK: - Properties
    @State var buttonState: DButtonState
    @State var dreamText: String = ""
    @State var mood: Mood? = nil
    
    let dream: Dream
    
    // MARK: - Services
    
    // MARK: - init
    init(dream: Dream) {
        self.dream = dream
        self.buttonState = UserManager.shared.isSubscribed ? .normal : .locked
        self.dreamText = dream.userCredential?.dreamText ?? ""
        self.mood = dream.userCredential?.selectedMood
    }
    
}
