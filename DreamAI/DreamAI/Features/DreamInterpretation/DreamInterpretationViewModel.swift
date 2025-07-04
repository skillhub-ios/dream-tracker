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
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var dream: Dream?
    
    // MARK: - External Dependencies
    private let userManager: UserManager = .shared
    private let dreamInterpreter = DIContainer.dreamInterpreter
    private let coreDataStore = DIContainer.coreDataStore
    
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
        
        $contentState
            .sink { [weak self] state in
                guard let self else { return }
                if let id = self.dream?.id {
                    self.interpretationLoadingStatus(id: id, status: state)
                }
            }
            .store(in: &cancellables)
    }
    
    private func tagSubscriber() {
        $interpretation
            .compactMap { $0 }
            .sink { [weak self] interpretation in
                guard let self else { return }
                if let id = self.dream?.id, !interpretation.tags.isEmpty {
                    self.updateTags([id: interpretation.tags])
                }
            }
            .store(in: &cancellables)
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
                dreamText: dream.description,
                mood: dream.emoji,
                tags: dream.tags.map { $0.rawValue }
            )
            fetchedModel.setDreamParentId(dream.id)
            self.interpretation = fetchedModel
            contentState = .success
            coreDataStore.saveInterpretation(fetchedModel)
            tagSubscriber()
        } catch {
            contentState = .error(error)
        }
    }
    
    private func updateTags(_ tags: [UUID: [String]]) {
        NotificationCenter.default.post(
            name: Notification.Name(PublisherKey.updateTags.rawValue),
            object: nil,
            userInfo: ["value": tags]
        )
    }
    
    private func interpretationLoadingStatus(id: UUID, status: ContentStateType) {
        NotificationCenter.default.post(
            name: Notification.Name(PublisherKey.interpretationLoadingStatus.rawValue),
            object: nil,
            userInfo: ["value": [id: status]]
        )
    }
}
