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
            if !storedDreams.isEmpty {
                dreams = storedDreams
            }
        } catch {
            errorMessage = "Failed to load dreams: \(error.localizedDescription)"
            print("❌ Error loading dreams: \(error)")
        }
        
        isLoading = false
    }
    
    private func saveDreamsToStorage(_ dreams: [Dream]) async {
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
            
            // Mark as successful
            updateDreamStatus(dreamId: dreamId, status: .success)
            
            // Store interpretation data (you might want to add this to the Dream model)
            await storeInterpretationResult(dreamId: dreamId, interpretation: interpretation)
            
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
    
    private func storeInterpretationResult(dreamId: UUID, interpretation: DreamInterpretationFullModel) async {
        // Here you can store the interpretation result
        // You might want to extend the Dream model to include interpretation data
        // For now, we'll just log it
        print("📝 Storing interpretation for dream \(dreamId): \(interpretation.dreamTitle)")
        
        // TODO: Add interpretation data to Dream model or separate storage
        // This could be stored in UserDefaults, Core Data, or as part of the Dream model
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
                    // Simple merge: replace local with cloud dreams
                    self.dreams = cloudDreams
                    // Also update local storage to be in sync
                    Task {
                        await self.saveDreamsToStorage(cloudDreams)
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to sync with iCloud: \(error.localizedDescription)"
                }
                
                self.isLoading = false
            }
        }
    }
}
