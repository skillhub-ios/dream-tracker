//
//  ExportImportManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class ExportImportManager: ObservableObject {
    
    // MARK: - Properties
    @Published var isExporting = false
    @Published var isImporting = false
    @Published var exportProgress: Double = 0.0
    @Published var importProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var exportedFileURL: URL?
    
    private let storageManager = StorageManager.shared
    private let fileManager = FileManager.default
    
    // MARK: - Singleton
    static let shared = ExportImportManager()
    
    private init() {}
    
    // MARK: - Export Methods
    
    /// Export dreams to a JSON file in the user's accessible directory
    func exportDreamsToFile() async throws -> URL {
        isExporting = true
        exportProgress = 0.0
        errorMessage = nil
        
        defer { isExporting = false }
        
        do {
            // Get dreams data
            exportProgress = 0.3
            let dreamsData = try await storageManager.exportDreams()
            
            // Create filename with timestamp
            exportProgress = 0.6
            let timestamp = DateFormatter.timestamp.string(from: Date())
            let filename = "DreamAI_Backup_\(timestamp).json"
            
            // Get user's accessible directory (On My iPhone)
            let accessibleDirectory = try getAccessibleDirectory()
            let fileURL = accessibleDirectory.appendingPathComponent(filename)
            
            // Write data to file
            exportProgress = 0.8
            try dreamsData.write(to: fileURL)
            
            exportProgress = 1.0
            successMessage = "Dreams exported successfully to \(filename)"
            exportedFileURL = fileURL
            
            print("✅ Dreams exported to: \(fileURL.path)")
            return fileURL
            
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
            print("❌ Export error: \(error)")
            throw ExportImportError.exportFailed(error)
        }
    }
    
    /// Export dreams and prepare for sharing
    func exportAndShareDreams() async throws -> URL {
        let fileURL = try await exportDreamsToFile()
        
        // The share sheet will be triggered by the UI layer
        return fileURL
    }
    
    /// Export dreams to a specific location chosen by user
    func exportDreamsToLocation() async throws -> URL {
        isExporting = true
        exportProgress = 0.0
        errorMessage = nil
        
        defer { isExporting = false }
        
        do {
            // Get dreams data
            exportProgress = 0.3
            let dreamsData = try await storageManager.exportDreams()
            
            // Create filename with timestamp
            exportProgress = 0.6
            let timestamp = DateFormatter.timestamp.string(from: Date())
            let filename = "DreamAI_Backup_\(timestamp).json"
            
            // Get user's accessible directory
            let accessibleDirectory = try getAccessibleDirectory()
            let fileURL = accessibleDirectory.appendingPathComponent(filename)
            
            // Write data to file
            exportProgress = 0.8
            try dreamsData.write(to: fileURL)
            
            exportProgress = 1.0
            successMessage = "Dreams exported successfully"
            exportedFileURL = fileURL
            
            print("✅ Dreams exported to: \(fileURL.path)")
            return fileURL
            
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
            print("❌ Export error: \(error)")
            throw ExportImportError.exportFailed(error)
        }
    }
    
    // MARK: - Import Methods
    
    /// Import dreams from a JSON file
    func importDreamsFromFile(_ fileURL: URL) async throws {
        isImporting = true
        importProgress = 0.0
        errorMessage = nil
        
        defer { isImporting = false }
        
        do {
            print("📥 Starting import from: \(fileURL.path)")
            
            // Start accessing the security-scoped resource
            guard fileURL.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security-scoped resource, trying to copy file...")
                // Try to copy file to accessible location
                let accessibleFileURL = try copyFileToAccessibleLocation(fileURL)
                try await performImport(fileURL: accessibleFileURL)
                return
            }
            
            defer {
                fileURL.stopAccessingSecurityScopedResource()
                print("🔓 Stopped accessing security-scoped resource")
            }
            
            // Validate file exists
            importProgress = 0.2
            guard fileManager.fileExists(atPath: fileURL.path) else {
                throw ExportImportError.fileNotFound
            }
            
            // Perform the actual import
            try await performImport(fileURL: fileURL)
            
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
            print("❌ Import error: \(error)")
            throw ExportImportError.importFailed(error)
        }
    }
    
    /// Perform the actual import operation
    private func performImport(fileURL: URL) async throws {
        // Read file data
        importProgress = 0.4
        let fileData = try Data(contentsOf: fileURL)
        
        // Validate JSON structure
        importProgress = 0.6
        guard let jsonObject = try? JSONSerialization.jsonObject(with: fileData),
              let jsonArray = jsonObject as? [[String: Any]] else {
            throw ExportImportError.invalidJSONFormat
        }
        
        // Import dreams
        importProgress = 0.8
        try await storageManager.importDreams(from: fileData)
        
        importProgress = 1.0
        successMessage = "Successfully imported \(jsonArray.count) dreams"
        
        print("✅ Dreams imported from: \(fileURL.lastPathComponent)")
    }
    
    /// Import dreams from a file with validation
    func importDreamsFromFileWithValidation(_ fileURL: URL) async throws -> ImportValidationResult {
        do {
            print("🔍 Validating file: \(fileURL.path)")
            
            // Start accessing the security-scoped resource
            guard fileURL.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security-scoped resource: \(fileURL.path)")
                return ImportValidationResult(
                    isValid: false,
                    dreamCount: 0,
                    fileSize: 0,
                    fileName: fileURL.lastPathComponent,
                    dreams: nil,
                    error: ExportImportError.fileAccessDenied
                )
            }
            
            defer {
                fileURL.stopAccessingSecurityScopedResource()
                print("🔓 Stopped accessing security-scoped resource")
            }
            
            // Check if file exists
            guard fileManager.fileExists(atPath: fileURL.path) else {
                print("❌ File does not exist: \(fileURL.path)")
                return ImportValidationResult(
                    isValid: false,
                    dreamCount: 0,
                    fileSize: 0,
                    fileName: fileURL.lastPathComponent,
                    dreams: nil,
                    error: ExportImportError.fileNotFound
                )
            }
            
            // Read and validate file
            let fileData = try Data(contentsOf: fileURL)
            print("📄 Read file data: \(fileData.count) bytes")
            
            // Try to decode dreams to validate structure
            let dreams = try JSONDecoder().decode([Dream].self, from: fileData)
            print("✅ Successfully decoded \(dreams.count) dreams")
            
            // Create validation result
            let result = ImportValidationResult(
                isValid: true,
                dreamCount: dreams.count,
                fileSize: fileData.count,
                fileName: fileURL.lastPathComponent,
                dreams: dreams,
                error: nil
            )
            
            return result
            
        } catch {
            print("❌ Validation error: \(error.localizedDescription)")
            return ImportValidationResult(
                isValid: false,
                dreamCount: 0,
                fileSize: 0,
                fileName: fileURL.lastPathComponent,
                dreams: nil,
                error: error
            )
        }
    }
    
    // MARK: - File Management
    
    /// Copy file to accessible location if needed
    private func copyFileToAccessibleLocation(_ sourceURL: URL) throws -> URL {
        let accessibleDirectory = try getAccessibleDirectory()
        let fileName = sourceURL.lastPathComponent
        let destinationURL = accessibleDirectory.appendingPathComponent(fileName)
        
        // Remove existing file if it exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        
        // Copy file to accessible location
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
        print("📋 Copied file to accessible location: \(destinationURL.path)")
        
        return destinationURL
    }
    
    /// Get list of exported backup files from accessible directory
    func getBackupFiles() throws -> [BackupFile] {
        let accessibleDirectory = try getAccessibleDirectory()
        let files = try fileManager.contentsOfDirectory(at: accessibleDirectory, includingPropertiesForKeys: [.creationDateKey, .fileSizeKey])
        
        return files
            .filter { $0.pathExtension == "json" && $0.lastPathComponent.contains("DreamAI_Backup") }
            .compactMap { url in
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: url.path)
                    let creationDate = attributes[.creationDate] as? Date ?? Date()
                    let fileSize = attributes[.size] as? Int ?? 0
                    
                    return BackupFile(
                        url: url,
                        name: url.lastPathComponent,
                        creationDate: creationDate,
                        fileSize: fileSize
                    )
                } catch {
                    print("❌ Error reading file attributes: \(error)")
                    return nil
                }
            }
            .sorted { $0.creationDate > $1.creationDate }
    }
    
    /// Delete a backup file
    func deleteBackupFile(_ backupFile: BackupFile) throws {
        try fileManager.removeItem(at: backupFile.url)
        print("🗑️ Deleted backup file: \(backupFile.name)")
    }
    
    /// Clear all backup files
    func clearAllBackupFiles() throws {
        let backupFiles = try getBackupFiles()
        for backupFile in backupFiles {
            try deleteBackupFile(backupFile)
        }
        print("🗑️ Cleared all backup files")
    }
    
    // MARK: - Helper Methods
    
    /// Get user's accessible directory (On My iPhone)
    private func getAccessibleDirectory() throws -> URL {
        // Use the app's documents directory which is accessible via Files app
        let documentsPath = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        print("📁 Using documents directory: \(documentsPath.path)")
        return documentsPath
    }
    
    /// Get documents directory (for internal app storage)
    private func getDocumentsDirectory() throws -> URL {
        return try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    // MARK: - Validation
    
    /// Validate if a file is a valid DreamAI backup
    func isValidDreamAIBackup(_ fileURL: URL) -> Bool {
        guard fileURL.pathExtension == "json" else { return false }
        
        // Start accessing the security-scoped resource
        guard fileURL.startAccessingSecurityScopedResource() else {
            return false
        }
        
        defer {
            fileURL.stopAccessingSecurityScopedResource()
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let dreams = try JSONDecoder().decode([Dream].self, from: data)
            return !dreams.isEmpty
        } catch {
            return false
        }
    }
    
    // MARK: - Storage Statistics
    
    /// Get storage statistics
    func getStorageStats() async -> StorageStats {
        return await storageManager.getStorageStats()
    }
    
    // MARK: - Debug Information
    
    /// Get current file path information for debugging
    func getCurrentFilePathInfo() -> String {
        do {
            let accessibleDirectory = try getAccessibleDirectory()
            let documentsDirectory = try getDocumentsDirectory()
            
            return """
            📁 Accessible Directory: \(accessibleDirectory.path)
            📁 Documents Directory: \(documentsDirectory.path)
            📱 App Bundle: \(Bundle.main.bundlePath)
            """
        } catch {
            return "❌ Error getting file path info: \(error.localizedDescription)"
        }
    }
    
    // MARK: - State Management
    
    /// Reset all states and clear exported file URL
    func resetState() {
        isExporting = false
        isImporting = false
        exportProgress = 0.0
        importProgress = 0.0
        errorMessage = nil
        successMessage = nil
        exportedFileURL = nil
    }
}

// MARK: - Export Import Errors
enum ExportImportError: LocalizedError {
    case exportFailed(Error)
    case importFailed(Error)
    case fileNotFound
    case invalidJSONFormat
    case fileAccessDenied
    case insufficientStorage
    
    var errorDescription: String? {
        switch self {
        case .exportFailed(let error):
            return "Export failed: \(error.localizedDescription)"
        case .importFailed(let error):
            return "Import failed: \(error.localizedDescription)"
        case .fileNotFound:
            return "Backup file not found"
        case .invalidJSONFormat:
            return "Invalid backup file format"
        case .fileAccessDenied:
            return "Access to file denied"
        case .insufficientStorage:
            return "Insufficient storage space"
        }
    }
}

// MARK: - Import Validation Result
struct ImportValidationResult {
    let isValid: Bool
    let dreamCount: Int
    let fileSize: Int
    let fileName: String
    let dreams: [Dream]?
    let error: Error?
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
}

// MARK: - Backup File Model
struct BackupFile: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let creationDate: Date
    let fileSize: Int
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
    
    var formattedCreationDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: creationDate)
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
} 
