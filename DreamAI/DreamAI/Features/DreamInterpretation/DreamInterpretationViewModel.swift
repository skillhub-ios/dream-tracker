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
    private let dreamManager: DreamManager = .shared
    
    private var dream: Dream?
    private var dreamData: UserDreamData?
    
    init(dream: Dream) {
        self.dream = dream
        
        if let interpretation = dream.interpretation {
            // Dream already has interpretation data
            self.model = interpretation
            self.contentState = .success
            print("✅ Dream has existing interpretation: \(interpretation.dreamTitle)")
        } else {
            // Dream doesn't have interpretation data - need to fetch it
            self.model = nil
            self.contentState = .loading
            print("🔄 Dream has no interpretation data, will need to fetch")
            
            // Set up dream data for interpretation
            self.dreamData = UserDreamData(
                dreamText: dream.title,
                mood: extractMoodFromTags(dream.tags)
            )
            
            // Start fetching interpretation
            Task {
                await fetchInterpretationForExistingDream()
            }
        }
        
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

           // Create dream with interpretation data
           let dreamModel = Dream(
               emoji: fetchedModel.dreamEmoji,
               emojiBackground: Color(hex: fetchedModel.dreamEmojiBackgroundColor),
               title: fetchedModel.dreamTitle,
               tags: fetchedModel.tags.compactMap({ Tags(rawValue: $0) }),
               date: Date(),
               requestStatus: .success,
               interpretation: fetchedModel
           )
           
           self.dreamManager.addDream(dreamModel)
           contentState = .success
       } catch {
           contentState = .error(error)
       }
    }

    func updateDreamData(_ dreamData: UserDreamData) {
        self.dreamData = dreamData
    }
    
    /// Fetch interpretation for an existing dream and update it in storage
    func fetchInterpretationForExistingDream() async {
        guard let dream = dream,
              let dreamData = dreamData else {
            contentState = .error(DreamInterpreterError.invalidResponse)
            return
        }
        
        contentState = .loading
        
        do {
            let fetchedModel = try await dreamInterpreter.interpretDream(
                dreamText: dreamData.dreamText,
                mood: dreamData.mood
            )
            
            // Update the model for UI
            self.model = fetchedModel
            
            // Update the dream in DreamManager with the interpretation
            dreamManager.updateDreamInterpretationAndStatus(
                dreamId: dream.id,
                interpretation: fetchedModel,
                status: .success
            )
            
            contentState = .success
            print("✅ Successfully fetched and stored interpretation for existing dream: \(dream.id)")
            
        } catch {
            contentState = .error(error)
            print("❌ Failed to fetch interpretation for existing dream: \(error)")
        }
    }
    
    /// Extract mood from dream tags
    private func extractMoodFromTags(_ tags: [Tags]) -> String? {
        // Map dream tags to potential moods
        let tagToMood: [Tags: String] = [
            .nightmare: "Fearful",
            .nightTerror: "Terrified",
            .lucidDream: "Aware",
            .propheticDream: "Curious",
            .creativeDream: "Inspired",
            .healingDream: "Peaceful",
            .epicDream: "Amazed",
            .daydream: "Relaxed",
            .continuousDream: "Focused",
            .falseAwakening: "Confused",
            .supernaturalDream: "Awe",
            .telepathicDream: "Connected",
            .sleepParalysis: "Anxious"
        ]
        
        // Return the first matching mood from tags
        for tag in tags {
            if let mood = tagToMood[tag] {
                return mood
            }
        }
        
        return nil
    }
}

struct UserDreamData {
    let dreamText: String
    let mood: String?
}
