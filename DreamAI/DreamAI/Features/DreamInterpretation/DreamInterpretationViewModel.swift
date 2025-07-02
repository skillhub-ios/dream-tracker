//
//  DreamInterpretationViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import Combine

@MainActor
class DreamInterpretationViewModel: ObservableObject {
    
    //MARK: - Published Properties
    @Published var interpretation: Interpretation? = nil
    @Published var selectedResonance: ResonanceOption = .yes
    @Published var contentState: ContentStateType = .loading
    @Published var buttonState: DButtonState = .normal
    
    //MARK: - Private Properties
    private let userManager: UserManager = .shared
    private let dreamInterpreter = DIContainer.dreamInterpreter
    private let coreDataStore = DIContainer.coreDataStore
    
    private var dream: Dream?
    
    init(dream: Dream) {
        self.dream = dream
        Task {
            await loadInterpretation(for: dream)
        }
        subscribers()
    }
    
    
    //MARK: - Private Methods
    
    private func subscribers() {
        $contentState
            .receive(on: DispatchQueue.main)
            .map {
                return switch $0 {
                case .loading: .loading
                case .success: .normal
                case .error: .tryAgain
                }
            }
            .assign(to: &$buttonState)
    }
    
    private func loadInterpretation(for dream: Dream) async {
        contentState = .loading
        
        // Trying load data from CoreData
        if let interpretation = coreDataStore.loadInterpretation(with: dream.id) {
            self.interpretation = interpretation
            contentState = .success
            return
        }
        
        // Fethcing data from OpenAPI
        do {
            var fetchedModel = try await dreamInterpreter.interpretDream(
                dreamText: dream.title, // Assuming title is the full text for now
                mood: dream.emoji,
                tags: dream.tags.map { $0.rawValue }
            )
            fetchedModel.setDreamParentId(dream.id)
            self.interpretation = fetchedModel
            contentState = .success
            coreDataStore.saveInterpretation(fetchedModel)
        } catch {
            contentState = .error(error)
        }
    }
}
