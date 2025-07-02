//
//  DreamViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 01/07/25.
//

import SwiftUI

class DreamViewModel: ObservableObject {
    
    // MARK: - Properties
    @Published var buttonState: DButtonState
    @Published var dreamText: String = ""
    @Published var mood: Mood? = nil
    
    let dream: Dream
    private let dreamManager = DreamManager.shared
    
    // MARK: - Services
    
    // MARK: - init
    init(dream: Dream) {
        self.dream = dream
        self.buttonState = UserManager.shared.isSubscribed ? .normal : .locked
        self.dreamText = dream.userCredential?.dreamText ?? ""
        self.mood = dream.userCredential?.selectedMood
    }
    
    // MARK: - Methods
    
    /// Save changes to the dream
    @MainActor
    func saveChanges() {
        // Create updated user credential
        let updatedCredential = UserCredential(
            dreamText: dreamText,
            selectedMood: mood
        )
        
        // Create updated dream with new credential
        var updatedDream = dream
        updatedDream.userCredential = updatedCredential
        updatedDream.title = dreamText
        updatedDream.date = Date()
        updatedDream.emoji = (mood ?? .happy).emoji
        
        // Update the dream in DreamManager
        dreamManager.updateDream(updatedDream)
        print("✅ Successfully saved dream changes")
    }
}
