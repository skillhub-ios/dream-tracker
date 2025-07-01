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
    private let dreamInterpreter: DreamInterpreter = .shared
    
    private var dream: Dream?
    private var dreamData: UserDreamData?
    
    init(dream: Dream) {
        self.dream = dream
//        self.contentState = dream.requestStatus
        subscribers()
    }

    init(dreamData: UserDreamData) {
        self.dreamData = dreamData
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
        
        guard let dreamData = dreamData else {
            // If no dream is provided, show error
            contentState = .error(DreamInterpreterError.invalidResponse)
            return
        }
        
        contentState = .loading
        
        do {
            let fetchedModel = try await dreamInterpreter.interpretDream(
                dreamText: dreamData.dreamText,
                mood: dreamData.mood
            )
            self.model = fetchedModel
            contentState = .success
        } catch {
            contentState = .error(error)
        }
    }
}

struct UserDreamData {
    let dreamText: String
    let mood: String?
}
