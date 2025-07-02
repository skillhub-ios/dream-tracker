//
//  DreamManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI
import Combine
import CloudKit

@MainActor
class DreamManager: ObservableObject {
    
    // MARK: - Properties
    @Published var dreams: [Dream] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    private let storageManager = StorageManager.shared
    private let cloudKitManager = CloudKitManager.shared
    private let authManager = AuthManager.shared
    private let dreamInterpreter = DreamInterpreter.shared
    
    // MARK: - Singleton
    static let shared = DreamManager()
    
    private var cancellables = Set<AnyCancellable>()
    private var activeRequests: [UUID: Task<Void, Never>] = [:]
    
    private init() {
        setupBindings()
        Task {
            await loadDreamsFromStorage()
        }
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Auto-save dreams when they change
        $dreams
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .sink { [weak self] dreams in
                Task {
                    await self?.saveDreamsToStorage(dreams)
                }
            }
            .store(in: &cancellables)
            
        authManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.handleiCloudSyncChange()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Storage Operations
    
    private func loadDreamsFromStorage() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let storedDreams = try await storageManager.loadDreams()
            print("📥 Loaded \(storedDreams.count) dreams from storage")
            
            // Debug: Check interpretation data for each dream
            for (index, dream) in storedDreams.enumerated() {
                if let interpretation = dream.interpretation {
                    print("✅ Dream \(index): '\(dream.title)' has interpretation: \(interpretation.dreamTitle)")
                } else {
                    print("❌ Dream \(index): '\(dream.title)' has NO interpretation data")
                }
            }
            
            if !storedDreams.isEmpty {
                dreams = storedDreams
                print("📋 Updated dreams array with \(dreams.count) dreams")
            }
        } catch {
            errorMessage = "Failed to load dreams: \(error.localizedDescription)"
            print("❌ Error loading dreams: \(error)")
        }
        
        isLoading = false
    }
    
    private func saveDreamsToStorage(_ dreams: [Dream]) async {
        print("💾 Saving \(dreams.count) dreams to storage")
        
        // Debug: Check interpretation data before saving
        for (index, dream) in dreams.enumerated() {
            if let interpretation = dream.interpretation {
                print("✅ Saving dream \(index): '\(dream.title)' with interpretation: \(interpretation.dreamTitle)")
            } else {
                print("❌ Saving dream \(index): '\(dream.title)' with NO interpretation data")
            }
        }
        
        if authManager.isSyncingWithiCloud {
            // Save to CloudKit
            for dream in dreams {
                cloudKitManager.saveDream(dream) { result in
                    switch result {
                    case .success:
                        print("☁️ Dream saved to CloudKit")
                    case .failure(let error):
                        print("❌ Error saving dream to CloudKit: \(error)")
                    }
                }
            }
        } else {
            // Save to local storage
            do {
                try await storageManager.saveDreams(dreams)
                print("💾 Successfully saved dreams to local storage")
            } catch {
                errorMessage = "Failed to save dreams: \(error.localizedDescription)"
                print("❌ Error saving dreams: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    func addDream(_ dream: Dream) {
        dreams.insert(dream, at: 0)
        objectWillChange.send()
    }
    
    func updateDreamStatus(dreamId: UUID, status: RequestStatus) {
        if let index = dreams.firstIndex(where: { $0.id == dreamId }) {
            dreams[index].requestStatus = status
            objectWillChange.send()
        }
    }
    
    /// Update dream interpretation data
    func updateDreamInterpretation(dreamId: UUID, interpretation: DreamInterpretationFullModel) {
        if let index = dreams.firstIndex(where: { $0.id == dreamId }) {
            dreams[index].interpretation = interpretation
            objectWillChange.send()
            print("📝 Updated interpretation for dream \(dreamId): \(interpretation.dreamTitle)")
        }
    }
    
    /// Update dream interpretation and status
    func updateDreamInterpretationAndStatus(dreamId: UUID, interpretation: DreamInterpretationFullModel, status: RequestStatus = .success) {
        if let index = dreams.firstIndex(where: { $0.id == dreamId }) {
            dreams[index].interpretation = interpretation
            dreams[index].requestStatus = status
            objectWillChange.send()
            print("📝 Updated interpretation and status for dream \(dreamId): \(interpretation.dreamTitle)")
        }
    }
    
    /// Update a dream with new data
    func updateDream(_ updatedDream: Dream) {
        if let index = dreams.firstIndex(where: { $0.id == updatedDream.id }) {
            dreams[index] = updatedDream
            objectWillChange.send()
            print("📝 Updated dream: \(updatedDream.title)")
        }
    }
    
    /// Get dream interpretation
    func getDreamInterpretation(dreamId: UUID) -> DreamInterpretationFullModel? {
        return getDream(by: dreamId)?.interpretation
    }
    
    // MARK: - Verification Methods
    
    /// Verify that interpretation data is being saved properly
    func verifyInterpretationStorage(dreamId: UUID) async -> Bool {
        guard let dream = getDream(by: dreamId) else {
            print("❌ Dream not found for verification: \(dreamId)")
            return false
        }
        
        guard let interpretation = dream.interpretation else {
            print("❌ No interpretation data found for dream: \(dreamId)")
            return false
        }
        
        print("✅ Dream has interpretation data:")
        print("   - Title: \(interpretation.dreamTitle)")
        print("   - Summary: \(interpretation.dreamSummary)")
        print("   - Mood insights count: \(interpretation.moodInsights.count)")
        print("   - Symbolism count: \(interpretation.symbolism.count)")
        
        // Test storage persistence by reloading from storage
        await refreshFromStorage()
        
        guard let reloadedDream = getDream(by: dreamId) else {
            print("❌ Dream not found after reload: \(dreamId)")
            return false
        }
        
        guard let reloadedInterpretation = reloadedDream.interpretation else {
            print("❌ Interpretation data lost after reload: \(dreamId)")
            return false
        }
        
        let isPersisted = reloadedInterpretation.dreamTitle == interpretation.dreamTitle &&
                         reloadedInterpretation.dreamSummary == interpretation.dreamSummary
        
        if isPersisted {
            print("✅ Interpretation data successfully persisted to storage")
        } else {
            print("❌ Interpretation data not properly persisted")
        }
        
        return isPersisted
    }
    
    /// Add test interpretation data to a dream
    func addTestInterpretation(dreamId: UUID) {
        guard let dream = getDream(by: dreamId) else {
            print("❌ Dream not found for test interpretation: \(dreamId)")
            return
        }
        
        let testInterpretation = DreamInterpretationFullModel(
            hasSubscription: false,
            dreamEmoji: "🧪",
            dreamEmojiBackgroundColor: "#FF6B6B",
            dreamTitle: "Test Dream Interpretation",
            dreamSummary: "This is a test interpretation to verify storage functionality.",
            fullInterpretation: "This dream represents a test of the interpretation storage system. It symbolizes the need to verify that data persistence is working correctly.",
            moodInsights: [
                MoodInsight(emoji: "🤔", label: "Curiosity", score: 0.8),
                MoodInsight(emoji: "😌", label: "Calm", score: 0.6),
                MoodInsight(emoji: "✨", label: "Wonder", score: 0.7)
            ],
            symbolism: [
                SymbolMeaning(icon: "🧪", meaning: "Testing"),
                SymbolMeaning(icon: "💾", meaning: "Storage"),
                SymbolMeaning(icon: "✅", meaning: "Verification")
            ],
            reflectionPrompts: [
                "Is the storage system working properly?\n",
                "Can you see the interpretation data?\n",
                "Does the data persist after app restart?\n"
            ],
            tags: ["Daydream", "Creative Dream"],
            quote: Quote(text: "The best way to test something is to actually test it.", author: "Test Author")
        )
        
        updateDreamInterpretationAndStatus(dreamId: dreamId, interpretation: testInterpretation, status: .success)
        print("🧪 Added test interpretation to dream: \(dreamId)")
    }
    
    func startDreamInterpretation(dreamId: UUID) {
        // Cancel any existing request for this dream
        cancelDreamInterpretation(dreamId: dreamId)
        
        // Update status to loading
        updateDreamStatus(dreamId: dreamId, status: .loading(progress: 0.0))
        
        // Start real API request
        let task = Task {
            await performDreamInterpretation(dreamId: dreamId)
        }
        
        activeRequests[dreamId] = task
    }
    
    func cancelDreamInterpretation(dreamId: UUID) {
        activeRequests[dreamId]?.cancel()
        activeRequests.removeValue(forKey: dreamId)
        updateDreamStatus(dreamId: dreamId, status: .idle)
    }
    
    func deleteDreams(ids: [UUID]) {
        // Cancel any active requests for dreams being deleted
        for id in ids {
            cancelDreamInterpretation(dreamId: id)
        }
        
        let dreamsToDelete = dreams.filter { ids.contains($0.id) }
        
        if authManager.isSyncingWithiCloud {
            for dream in dreamsToDelete {
                let recordID = CKRecord.ID(recordName: dream.id.uuidString)
                cloudKitManager.deleteDream(recordID: recordID) { result in
                    switch result {
                    case .success:
                        print("☁️ Dream deleted from CloudKit")
                    case .failure(let error):
                        print("❌ Error deleting dream from CloudKit: \(error)")
                    }
                }
            }
        }

        dreams.removeAll { ids.contains($0.id) }
        objectWillChange.send()
    }
    
    func getDream(by id: UUID) -> Dream? {
        return dreams.first { $0.id == id }
    }
    
    // MARK: - Storage Management
    
    func refreshFromStorage() async {
        await loadDreamsFromStorage()
    }
    
    func clearAllDreams() async {
        // Cancel all active requests
        for dreamId in activeRequests.keys {
            cancelDreamInterpretation(dreamId: dreamId)
        }
        
        do {
            try await storageManager.clearAllDreams()
            dreams = []
            objectWillChange.send()
        } catch {
            errorMessage = "Failed to clear dreams: \(error.localizedDescription)"
        }
    }
    
    func exportDreams() async -> Data? {
        do {
            return try await storageManager.exportDreams()
        } catch {
            errorMessage = "Failed to export dreams: \(error.localizedDescription)"
            return nil
        }
    }
    
    func importDreams(from data: Data) async {
        do {
            try await storageManager.importDreams(from: data)
            await loadDreamsFromStorage()
        } catch {
            errorMessage = "Failed to import dreams: \(error.localizedDescription)"
        }
    }
    
    func getStorageStats() async -> StorageStats {
        return await storageManager.getStorageStats()
    }
    
    // MARK: - Private Methods
    
    private func performDreamInterpretation(dreamId: UUID) async {
        guard let dream = getDream(by: dreamId) else {
            updateDreamStatus(dreamId: dreamId, status: .error)
            return
        }
        
        // Extract dream text from the dream title (you might want to store actual dream text separately)
        let dreamText = dream.title
        let mood: String? = nil // You can add mood tracking later
        
        // Progress steps for UI feedback
        let progressSteps: [Double] = [0.2, 0.4, 0.6, 0.8, 0.9]
        
        // Update progress for each step
        for progress in progressSteps {
            // Check if task was cancelled
            if Task.isCancelled {
                updateDreamStatus(dreamId: dreamId, status: .idle)
                return
            }
            
            updateDreamStatus(dreamId: dreamId, status: .loading(progress: progress))
            
            // Small delay to show progress
            try? await Task.sleep(for: .milliseconds(300))
        }
        
        do {
            // Make actual API call
            let interpretation = try await dreamInterpreter.interpretDream(
                dreamText: dreamText,
                mood: mood
            )
            
            // Check if task was cancelled
            if Task.isCancelled {
                updateDreamStatus(dreamId: dreamId, status: .idle)
                return
            }
            
            // Update to 100% progress
            updateDreamStatus(dreamId: dreamId, status: .loading(progress: 1.0))
            
            // Small delay to show completion
            try? await Task.sleep(for: .milliseconds(200))
            
            // Update dream with interpretation data and mark as successful
            updateDreamInterpretationAndStatus(dreamId: dreamId, interpretation: interpretation, status: .success)
            
            print("✅ Dream interpretation completed for dream: \(dreamId)")
            
        } catch {
            // Check if task was cancelled
            if Task.isCancelled {
                updateDreamStatus(dreamId: dreamId, status: .idle)
                return
            }
            
            print("❌ Dream interpretation failed for dream \(dreamId): \(error)")
            updateDreamStatus(dreamId: dreamId, status: .error)
        }
        
        // Clean up the task
        activeRequests.removeValue(forKey: dreamId)
    }
    

    
    private func handleiCloudSyncChange() {
        if authManager.isSyncingWithiCloud {
            // Switched to iCloud, let's sync
            syncWithCloud()
        } else {
            // Switched to local, reload from local storage
            Task {
                await loadDreamsFromStorage()
            }
        }
    }
    
    private func syncWithCloud() {
        isLoading = true
        cloudKitManager.fetchDreams { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let cloudDreams):
                    // Merge cloud dreams with local interpretation data
                    let mergedDreams = self.mergeCloudDreamsWithLocalInterpretations(cloudDreams)
                    self.dreams = mergedDreams
                    // Also update local storage to be in sync
                    Task {
                        await self.saveDreamsToStorage(mergedDreams)
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to sync with iCloud: \(error.localizedDescription)"
                }
                
                self.isLoading = false
            }
        }
    }
    
    /// Merge cloud dreams with local interpretation data to preserve local interpretations
    private func mergeCloudDreamsWithLocalInterpretations(_ cloudDreams: [Dream]) -> [Dream] {
        var mergedDreams = cloudDreams
        
        for (index, cloudDream) in cloudDreams.enumerated() {
            // Check if we have a local version with interpretation data
            if let localDream = self.dreams.first(where: { $0.id == cloudDream.id }),
               let localInterpretation = localDream.interpretation {
                // Preserve local interpretation data
                mergedDreams[index].interpretation = localInterpretation
                print("🔄 Preserved local interpretation for dream: \(cloudDream.title)")
            }
        }
        
        return mergedDreams
    }
}
