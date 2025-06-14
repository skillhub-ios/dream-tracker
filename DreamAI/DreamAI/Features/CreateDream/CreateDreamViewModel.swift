//
//  CreateDreamViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI
import Combine

class CreateDreamViewModel: ObservableObject {
    
    // MARK: - PROPERTIES
    @Published var selectedDate: Date = Date()
    @Published var dreamText = ""
    @Published var selectedMood: Mood? = .calm
    @Published var isButtonDisabled: Bool = true    
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.selectedMood = Mood.allCases.randomElement()
        subscribers()
    }

    // MARK: - Methods

    private func subscribers() {
        Publishers.CombineLatest3($selectedDate, $dreamText, $selectedMood)
            .map { date, text, mood in
                text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || mood == nil
            }
            .assign(to: \.isButtonDisabled, on: self)
            .store(in: &cancellables)
    }
}
