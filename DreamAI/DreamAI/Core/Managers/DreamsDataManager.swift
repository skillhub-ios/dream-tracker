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
    
    
    
    
    // MARK: - OLD ---------------------------
    
    //    init() {
    //        setupBindings()
    //        Task {
    //            await loadDreamsFromStorage()
    //        }
    //    }
    
    // MARK: - Setup
    
    //    private func setupBindings() {
    //        // Auto-save dreams when they change
    //        $dreams
    //            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
    //            .sink { [weak self] dreams in
    //                Task {
    //                    await self?.saveDreamsToStorage(dreams)
    //                }
    //            }
    //            .store(in: &cancellables)
    //
    //        authManager.objectWillChange
    //            .receive(on: RunLoop.main)
    //            .sink { [weak self] _ in
    //                self?.handleiCloudSyncChange()
    //            }
    //            .store(in: &cancellables)
    //    }
    
    // MARK: - Storage Operations
    
    //    private func loadDreamsFromStorage() async {
    //        isLoading = true
    //        errorMessage = nil
    //
    //        do {
    //            let storedDreams = try await storageManager.loadDreams()
    //            if storedDreams.isEmpty {
    //                // Load mock dreams if no stored dreams exist
    //                loadMockDreams()
    //            } else {
    //                dreams = storedDreams
    //            }
    //        } catch {
    //            errorMessage = "Failed to load dreams: \(error.localizedDescription)"
    //            print("❌ Error loading dreams: \(error)")
    //            // Fallback to mock dreams
    //            loadMockDreams()
    //        }
    //
    //        isLoading = false
    //    }
    
    //    private func saveDreamsToStorage(_ dreams: [Dream]) async {
    //        if authManager.isSyncingWithiCloud {
    //            // Save to CloudKit
    //            for dream in dreams {
    //                cloudKitManager.saveDream(dream) { result in
    //                    switch result {
    //                    case .success:
    //                        print("☁️ Dream saved to CloudKit")
    //                    case .failure(let error):
    //                        print("❌ Error saving dream to CloudKit: \(error)")
    //                    }
    //                }
    //            }
    //        } else {
    //            // Save to local storage
    //            do {
    //                try await storageManager.saveDreams(dreams)
    //            } catch {
    //                errorMessage = "Failed to save dreams: \(error.localizedDescription)"
    //                print("❌ Error saving dreams: \(error)")
    //            }
    //        }
    //    }
    //
    //    // MARK: - Public Methods
    //
    //    func addDream(_ dream: Dream) {
    //        dreams.insert(dream, at: 0)
    //        objectWillChange.send()
    //    }
    //
    //    func updateDreamStatus(dreamId: UUID, status: RequestStatus) {
    //        if let index = dreams.firstIndex(where: { $0.id == dreamId }) {
    //            dreams[index].requestStatus = status
    //            objectWillChange.send()
    //        }
    //    }
    //
    //    func startDreamInterpretation(dreamId: UUID) {
    //        updateDreamStatus(dreamId: dreamId, status: .loading(progress: 0.0))
    //
    //        // Simulate API call with progress updates
    //        Task {
    //            await simulateDreamInterpretationRequest(dreamId: dreamId)
    //        }
    //    }
    //
    //    func deleteDreams(ids: [UUID]) {
    //        let dreamsToDelete = dreams.filter { ids.contains($0.id) }
    //
    //        if authManager.isSyncingWithiCloud {
    //            for dream in dreamsToDelete {
    //                let recordID = CKRecord.ID(recordName: dream.id.uuidString)
    //                cloudKitManager.deleteDream(recordID: recordID) { result in
    //                    switch result {
    //                    case .success:
    //                        print("☁️ Dream deleted from CloudKit")
    //                    case .failure(let error):
    //                        print("❌ Error deleting dream from CloudKit: \(error)")
    //                    }
    //                }
    //            }
    //        }
    //
    //        dreams.removeAll { ids.contains($0.id) }
    //        objectWillChange.send()
    //    }
    //
    //    func getDream(by id: UUID) -> Dream? {
    //        return dreams.first { $0.id == id }
    //    }
    //
    //    // MARK: - Storage Management
    //
    //    func refreshFromStorage() async {
    //        await loadDreamsFromStorage()
    //    }
    //
    //    func clearAllDreams() async {
    //        do {
    //            try await storageManager.clearAllDreams()
    //            dreams = []
    //            objectWillChange.send()
    //        } catch {
    //            errorMessage = "Failed to clear dreams: \(error.localizedDescription)"
    //        }
    //    }
    //
    //    func exportDreams() async -> Data? {
    //        do {
    //            return try await storageManager.exportDreams()
    //        } catch {
    //            errorMessage = "Failed to export dreams: \(error.localizedDescription)"
    //            return nil
    //        }
    //    }
    //
    //    func importDreams(from data: Data) async {
    //        do {
    //            try await storageManager.importDreams(from: data)
    //            await loadDreamsFromStorage()
    //        } catch {
    //            errorMessage = "Failed to import dreams: \(error.localizedDescription)"
    //        }
    //    }
    //
    //    func getStorageStats() async -> StorageStats {
    //        return await storageManager.getStorageStats()
    //    }
    //
    //    // MARK: - Private Methods
    //
    //    private func simulateDreamInterpretationRequest(dreamId: UUID) async {
    //        let progressSteps: [Double] = [0.2, 0.4, 0.6, 0.8, 1.0]
    //
    //        for progress in progressSteps {
    //            try? await Task.sleep(for: .seconds(1.0))
    //
    //            await MainActor.run {
    //                updateDreamStatus(dreamId: dreamId, status: .loading(progress: progress))
    //            }
    //        }
    //
    //        // Simulate random success or error
    //        let isSuccess = Bool.random()
    //
    //        await MainActor.run {
    //            updateDreamStatus(dreamId: dreamId, status: isSuccess ? .success : .error)
    //        }
    //
    //        // If success, update the dream with interpretation data
    //        if isSuccess {
    //            await updateDreamWithInterpretation(dreamId: dreamId)
    //        }
    //    }
    //
    //    private func updateDreamWithInterpretation(dreamId: UUID) async {
    //        // Here you would typically update the dream with actual interpretation data
    //        // For now, we'll just mark it as successful
    //        print("Dream interpretation completed for dream: \(dreamId)")
    //    }
    //
    //    private func handleiCloudSyncChange() {
    //        if authManager.isSyncingWithiCloud {
    //            // Switched to iCloud, let's sync
    //            syncWithCloud()
    //        } else {
    //            // Switched to local, reload from local storage
    //            Task {
    //                await loadDreamsFromStorage()
    //            }
    //        }
    //    }
    //
    //    private func syncWithCloud() {
    //        isLoading = true
    //        cloudKitManager.fetchDreams { [weak self] result in
    //            DispatchQueue.main.async {
    //                guard let self = self else { return }
    //
    //                switch result {
    //                case .success(let cloudDreams):
    //                    // Simple merge: replace local with cloud dreams
    //                    self.dreams = cloudDreams
    //                    // Also update local storage to be in sync
    //                    Task {
    //                        await self.saveDreamsToStorage(cloudDreams)
    //                    }
    //                case .failure(let error):
    //                    self.errorMessage = "Failed to sync with iCloud: \(error.localizedDescription)"
    //                }
    //
    //                self.isLoading = false
    //            }
    //        }
    //    }
    //
}

#if DEBUG

func loadMockDreams() -> [Dream] {[
    Dream(emoji: "😰", emojiBackground: .appGreen, title: "Falling from a great height", tags: [.nightmare, .epicDream], date: Date().addingTimeInterval(-86400)),
    Dream(emoji: "🏃‍♂️", emojiBackground: .appBlue, title: "Running but can't escape", tags: [.nightmare, .epicDream], date: Date().addingTimeInterval(-172800)),
    Dream(emoji: "🌊", emojiBackground: .appPurple, title: "Drowning in the ocean", tags: [.nightmare, .propheticDream], date: Date().addingTimeInterval(-259200)),
    Dream(emoji: "✈️", emojiBackground: .appOrange, title: "Flying over the mountains", tags: [.lucidDream, .epicDream], date: Date().addingTimeInterval(-345600)),
    Dream(emoji: "🏠", emojiBackground: .appRed, title: "Lost in a house", tags: [.nightmare, .continuousDream], date: Date().addingTimeInterval(-432000))
]
}

#endif
