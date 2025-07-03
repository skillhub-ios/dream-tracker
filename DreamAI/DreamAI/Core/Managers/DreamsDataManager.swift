//
//  DreamsDataManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import Combine
import CloudKit
import CoreData

final class DreamsDataManager: ObservableObject {
    
    // MARK: - Public Properties
    
    @Published var dreams: [DreamEntity] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let container: NSPersistentContainer
    
    // MARK: - External Dependencies
    
    private let authManager = AuthManager.shared
    
    // MARK: - Lifecycle
    
    init() {
        container = NSPersistentContainer(name: "DreamDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                print("Error loadind CoreData \(error)")
            }
        }
        loadDreams()
    }
    
    // MARK: - Public Functions
    
    func saveDream(_ dream: Dream) {
        let newDream = DreamEntity(context: container.viewContext)
        
        newDream.id = dream.id
        newDream.title = dream.title
        newDream.date = dream.date
        newDream.emoji = dream.emoji
        newDream.emojiBackground = dream.emojiBackground.toHex()
        newDream.tags = dream.tags.map(\.rawValue).joined(separator: ", ")
        
        saveData()
    }
    
    func deleteDreamsAndItsInterpretations(dreamsIds: [UUID]) {
        let dreamsRemovalRequest: NSFetchRequest<DreamEntity> = DreamEntity.fetchRequest()
        dreamsRemovalRequest.predicate = NSPredicate(format: "id IN %@", dreamsIds)
        
        let interpretationsRemovalRequest: NSFetchRequest<InterpretationEntity> = InterpretationEntity.fetchRequest()
        interpretationsRemovalRequest.predicate = NSPredicate(format: "dreamParentId IN %@", dreamsIds)
        
        do {
            let dreamsToDelete = try container.viewContext.fetch(dreamsRemovalRequest)
            let interpretationsToDelete = try container.viewContext.fetch(interpretationsRemovalRequest)
            
            for interpretation in interpretationsToDelete {
                container.viewContext.delete(interpretation)
            }
            
            for dream in dreamsToDelete {
                container.viewContext.delete(dream)
            }
            
            saveData()
            
        } catch {
            print("Ошибка при удалении данных из CoreData: \(error)")
        }
    }
    
    func saveInterpretation(_ interpretation: Interpretation) {
        let newInterpretation = InterpretationEntity(context: container.viewContext)
        let encoder = JSONEncoder()
        
        newInterpretation.dreamTitle = interpretation.dreamTitle
        newInterpretation.dreamSummary = interpretation.dreamSummary
        newInterpretation.fullInterpretation = interpretation.fullInterpretation
        newInterpretation.moodInsights = try? encoder.encode(interpretation.moodInsights)
        newInterpretation.symbolism = try? encoder.encode(interpretation.symbolism)
        newInterpretation.reflectionPrompts = interpretation.reflectionPrompts.joined(separator: ", ")
        newInterpretation.quote = try? encoder.encode(interpretation.quote)
        newInterpretation.dreamParentId = interpretation.dreamParentId
        
        saveData()
    }
    
    func loadInterpretation(with parentId: UUID) -> Interpretation? {
        let interpretationRequest = NSFetchRequest<InterpretationEntity>(entityName: "InterpretationEntity")
        interpretationRequest.predicate = NSPredicate(format: "dreamParentId == %@", argumentArray: [parentId])
        interpretationRequest.fetchLimit = 1
        
        do {
            let interpretationEntity = try container.viewContext.fetch(interpretationRequest).first
            guard let interpretationEntity,
                  let interpretation = Interpretation(from: interpretationEntity) else { return nil }
            return interpretation
        } catch let error {
            print("⚠️ Error load Interpretation with parentId \(parentId): \(error)")
            return nil
        }
    }
    
    // MARK: - Private Functions
    
    private func loadDreams() {
        let dreamsRequest = NSFetchRequest<DreamEntity>(entityName: "DreamEntity")
        do {
            try dreams = container.viewContext.fetch(dreamsRequest)
        } catch let error {
            print("⚠️ Error fetch dreams: \(error)")
        }
    }
    
    private func saveData() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving \(error)")
        }
    }
}

#if DEBUG

func loadMockDreams() -> [Dream] {[
    Dream(emoji: "😰", emojiBackground: .appGreen, title: "Falling from a great height", tags: [.nightmare, .epicDream], date: Date().addingTimeInterval(-86400)),
    Dream(emoji: "🏃‍♂️", emojiBackground: .appBlue, title: "Running but can't escape", tags: [.nightmare, .epicDream], date: Date().addingTimeInterval(-172800)),
    Dream(emoji: "🌊", emojiBackground: .appPurple, title: "Drowning in the ocean", tags: [.nightmare, .propheticDream], date: Date().addingTimeInterval(-259200)),
    Dream(emoji: "✈️", emojiBackground: .appOrange, title: "Flying over the mountains", tags: [.lucidDream, .epicDream], date: Date().addingTimeInterval(-345600)),
    Dream(emoji: "🏠", emojiBackground: .appRed, title: "Lost in a house", tags: [.nightmare, .continuousDream], date: Date().addingTimeInterval(-432000))
]}

#endif
