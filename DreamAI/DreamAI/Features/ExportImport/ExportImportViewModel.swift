//
//  ExportImportViewModel.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine
import SwiftUI

enum ExportImportState {
    case initial
    case loading
    case done
    case error
}

@MainActor
final class ExportImportViewModel: ObservableObject {
    @Published var currentState: ExportImportState = .initial
    @Published var progress: Double = 0.0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    let exportImportManager = ExportImportManager.shared
//    private let dreamManager = DreamManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Monitor export progress
        exportImportManager.$exportProgress
            .assign(to: \.progress, on: self)
            .store(in: &cancellables)
        
        // Monitor import progress
        exportImportManager.$importProgress
            .assign(to: \.progress, on: self)
            .store(in: &cancellables)
        
        // Monitor error messages
        exportImportManager.$errorMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.errorMessage = message
                self?.currentState = .error
            }
            .store(in: &cancellables)
        
        // Monitor success messages
        exportImportManager.$successMessage
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.successMessage = message
                self?.currentState = .done
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Export Functions
    
    func startExport() {
        currentState = .loading
        progress = 0.0
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let fileURL = try await exportImportManager.exportDreamsToFile()
                print("✅ Export completed: \(fileURL.path)")
            } catch {
                errorMessage = "Export failed: \(error.localizedDescription)"
                currentState = .error
            }
        }
    }
    
    func exportAndShare() {
        currentState = .loading
        progress = 0.0
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let fileURL = try await exportImportManager.exportAndShareDreams()
                print("✅ Export and share completed: \(fileURL.path)")
            } catch {
                errorMessage = "Export and share failed: \(error.localizedDescription)"
                currentState = .error
            }
        }
    }
    
    // MARK: - Import Functions
    
    func startImport() {
        currentState = .loading
        progress = 0.0
        errorMessage = nil
        successMessage = nil
        
        // This would typically trigger a document picker
        // For now, we'll simulate the import process
        simulateImportProcess()
    }
    
    func importFromFile(_ fileURL: URL) {
        currentState = .loading
        progress = 0.0
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                // First validate the file
                let validationResult = try await exportImportManager.importDreamsFromFileWithValidation(fileURL)
                
                if validationResult.isValid {
                    // Proceed with import
                    await performImport(fileURL: fileURL, validationResult: validationResult)
                } else {
                    errorMessage = "Invalid backup file format"
                    currentState = .error
                }
            } catch {
                errorMessage = "Import validation failed: \(error.localizedDescription)"
                currentState = .error
            }
        }
    }
    
    private func performImport(fileURL: URL, validationResult: ImportValidationResult) async {
        do {
            try await exportImportManager.importDreamsFromFile(fileURL)
            
            // Refresh dreams from storage
//            await dreamManager.refreshFromStorage()
            
            successMessage = "Successfully imported \(validationResult.dreamCount) dreams"
            currentState = .done
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
            currentState = .error
        }
    }
    
    // MARK: - Backup Management
    
    func getBackupFiles() -> [BackupFile] {
        do {
            return try exportImportManager.getBackupFiles()
        } catch {
            print("Failed to get backup files: \(error)")
            return []
        }
    }
    
    func deleteBackupFile(_ backupFile: BackupFile) {
        do {
            try exportImportManager.deleteBackupFile(backupFile)
            successMessage = "Backup file deleted successfully"
        } catch {
            errorMessage = "Failed to delete backup: \(error.localizedDescription)"
        }
    }
    
    func clearAllBackupFiles() {
        do {
            try exportImportManager.clearAllBackupFiles()
            successMessage = "All backup files cleared"
        } catch {
            errorMessage = "Failed to clear backup files: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Storage Statistics
    
    func getStorageStats() async -> StorageStats {
        return await exportImportManager.getStorageStats()
    }
    
    // MARK: - State Management
    
    func resetToInitial() {
        currentState = .initial
        progress = 0.0
        errorMessage = nil
        successMessage = nil
        exportImportManager.resetState()
    }
    
    // MARK: - Helper Methods
    
    private func simulateImportProcess() {
        // Simulate import process for demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            // Simulate random success/failure for demo
            let isSuccess = Bool.random()
            self?.currentState = isSuccess ? .done : .error
        }
    }
    
    func isValidBackupFile(_ fileURL: URL) -> Bool {
        return exportImportManager.isValidDreamAIBackup(fileURL)
    }
}

// MARK: - Export Import Error Handling

extension ExportImportViewModel {
    
    func handleExportError(_ error: Error) {
        errorMessage = "Export failed: \(error.localizedDescription)"
        currentState = .error
    }
    
    func handleImportError(_ error: Error) {
        errorMessage = "Import failed: \(error.localizedDescription)"
        currentState = .error
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - Mock Data

extension ExportImportViewModel {
    
    // Mock export data
    private var mockExportData: [String: Any] {
        return [
            "dreams": [
                [
                    "id": "1",
                    "title": "Flying Dream",
                    "content": "I was flying over a beautiful landscape...",
                    "date": "2024-01-15",
                    "mood": "happy",
                    "tags": ["lucid", "adventure"]
                ],
                [
                    "id": "2",
                    "title": "Ocean Dream",
                    "content": "I was swimming in crystal clear water...",
                    "date": "2024-01-14",
                    "mood": "peaceful",
                    "tags": ["nature", "peaceful"]
                ]
            ],
            "settings": [
                "notifications": true,
                "language": "en",
                "theme": "dark"
            ],
            "exportDate": ISO8601DateFormatter().string(from: Date())
        ]
    }
    
    // Mock import validation
    private func validateImportData(_ data: [String: Any]) -> Bool {
        // Mock validation logic
        return data["dreams"] != nil && data["settings"] != nil
    }
} 
