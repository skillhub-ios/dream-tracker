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
    @Published var model: DreamInterpretationFullModel? = nil
    @Published var selectedResonance: ResonanceOption = .yes
    @Published var contentState: ContentStateType = .loading
    @Published var buttonState: DButtonState = .normal
    
    //MARK: - Private Properties
    private var cancellables: Set<AnyCancellable> = []
    private let userManager: UserManager = .shared
    private let openAIManager: OpenAIManager = .shared
    
    private var interpretationModel: DreamInterpretationFullModel?
    private var dream: Dream?
    
    init(interpretationModel: DreamInterpretationFullModel? = nil, dream: Dream? = nil) {
        self.interpretationModel = interpretationModel
        self.dream = dream
        subscribers()
    }


    //MARK: - Methods

    private func subscribers() {
        $contentState
        .receive(on: DispatchQueue.main)
        .map { 
            return switch $0 {
            case .loading: .loading
            case .success: self.userManager.isSubscribed ? .normal : .locked
            case .error: .tryAgain
            }
        }
        .assign(to: \.buttonState, on: self)
        .store(in: &cancellables)
    }
    
    func fetchInterpretation() async {
        if let interpretationModel = interpretationModel {
            self.model = interpretationModel
            self.contentState = .success
            return
        }
        
        guard let dream = dream else {
            // Fallback to mock data if no dream or model is provided
            contentState = .loading
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                model = dreamInterpretationFullModel
                contentState = .success
            } catch {
                contentState = .error(error)
            }
            return
        }
        
        contentState = .loading
        do {
            let fetchedModel = try await openAIManager.getDreamInterpretation(
                dreamText: dream.title, // Assuming title is the full text for now
                mood: nil, // We don't have mood for old dreams here
                tags: dream.tags.map { $0.rawValue }
            )
            self.model = fetchedModel
            contentState = .success
        } catch {
            contentState = .error(error)
        }
    }
}
