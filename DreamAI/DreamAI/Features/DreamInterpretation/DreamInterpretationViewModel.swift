//
//  DreamInterpretationViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import Combine

class DreamInterpretationViewModel: ObservableObject {   
    
    //MARK: - Published Properties
    @Published var model: DreamInterpretationFullModel? = nil
    @Published var selectedResonance: ResonanceOption = .yes
    @Published var contentState: ContentStateType = .loading
    @Published var buttonState: DButtonState = .normal
    
    //MARK: - Private Properties
    private var cancellables: Set<AnyCancellable> = []
    private let userManager: UserManager = .shared
    
    init() {
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
        model = nil
        contentState = .loading
        do {
            try await Task.sleep(nanoseconds: 3_000_000_000) // 2 second delay
            model = dreamInterpretationFullModel
            if contentState != .success {
                contentState = .error(NSError(domain: "Test", code: 1))
            } else {
                contentState = .success
            }
        } catch {
            contentState = .error(NSError(domain: "Test", code: 1))
        }
    }
}
