//
//  StorageManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation
import Combine

@MainActor
class StorageManager: ObservableObject {
    
    // MARK: - Properties
    private let userDefaults = UserDefaults.standard
    private let dreamsKey = "stored_dreams"
    private let lastSyncKey = "last_sync_date"
    
    // MARK: - Singleton
    static let shared = StorageManager()
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Save dreams to persistent storage
    func saveDreams(_ dreams: [Dream]) async throws {
        do {
            print("🔧 Encoding \(dreams.count) dreams to JSON...")
            
            // Debug: Check interpretation data before encoding
            for (index, dream) in dreams.enumerated() {
                if let interpretation = dream.interpretation {
                    print("✅ Encoding dream \(index): '\(dream.title)' with interpretation: \(interpretation.dreamTitle)")
                } else {
                    print("❌ Encoding dream \(index): '\(dream.title)' with NO interpretation data")
                }
            }
            
            let data = try JSONEncoder().encode(dreams)
            print("📦 Encoded dreams to \(data.count) bytes")
            
            userDefaults.set(data, forKey: dreamsKey)
            userDefaults.set(Date(), forKey: lastSyncKey)
            print("✅ Successfully saved \(dreams.count) dreams to storage")
        } catch {
            print("❌ Failed to save dreams: \(error.localizedDescription)")
            throw StorageError.encodingFailed(error)
        }
    }
    
    /// Load dreams from persistent storage
    func loadDreams() async throws -> [Dream] {
        guard let data = userDefaults.data(forKey: dreamsKey) else {
            print("📝 No stored dreams found, returning empty array")
            return []
        }
        
        print("📦 Loading dreams from \(data.count) bytes of data...")
        
        do {
            let dreams = try JSONDecoder().decode([Dream].self, from: data)
            print("✅ Successfully loaded \(dreams.count) dreams from storage")
            
            // Debug: Check interpretation data after decoding
            for (index, dream) in dreams.enumerated() {
                if let interpretation = dream.interpretation {
                    print("✅ Decoded dream \(index): '\(dream.title)' with interpretation: \(interpretation.dreamTitle)")
                } else {
                    print("❌ Decoded dream \(index): '\(dream.title)' with NO interpretation data")
                }
            }
            
            return dreams
        } catch {
            print("❌ Failed to load dreams: \(error.localizedDescription)")
            throw StorageError.decodingFailed(error)
        }
    }
    
    /// Add a single dream to storage
    func addDream(_ dream: Dream) async throws {
        var dreams = try await loadDreams()
        dreams.insert(dream, at: 0)
        try await saveDreams(dreams)
    }
    
    /// Update a specific dream in storage
    func updateDream(_ dream: Dream) async throws {
        var dreams = try await loadDreams()
        if let index = dreams.firstIndex(where: { $0.id == dream.id }) {
            dreams[index] = dream
            try await saveDreams(dreams)
        } else {
            throw StorageError.dreamNotFound
        }
    }
    
    /// Delete specific dreams from storage
    func deleteDreams(ids: [UUID]) async throws {
        var dreams = try await loadDreams()
        dreams.removeAll { ids.contains($0.id) }
        try await saveDreams(dreams)
    }
    
    /// Clear all stored dreams
    func clearAllDreams() async throws {
        userDefaults.removeObject(forKey: dreamsKey)
        userDefaults.removeObject(forKey: lastSyncKey)
        print("🗑️ All dreams cleared from storage")
    }
    
    /// Get the last sync date
    func getLastSyncDate() -> Date? {
        return userDefaults.object(forKey: lastSyncKey) as? Date
    }
    
    /// Check if storage has dreams
    func hasStoredDreams() -> Bool {
        return userDefaults.data(forKey: dreamsKey) != nil
    }
    
    /// Get storage statistics
    func getStorageStats() async -> StorageStats {
        let dreams = (try? await loadDreams()) ?? []
        let lastSync = getLastSyncDate()
        
        return StorageStats(
            totalDreams: dreams.count,
            lastSyncDate: lastSync,
            storageSize: userDefaults.data(forKey: dreamsKey)?.count ?? 0
        )
    }
    
    // MARK: - Backup and Restore
    
    /// Export dreams as JSON data
    func exportDreams() async throws -> Data {
        let dreams = try await loadDreams()
        return try JSONEncoder().encode(dreams)
    }
    
    /// Import dreams from JSON data
    func importDreams(from data: Data) async throws {
        let dreams = try JSONDecoder().decode([Dream].self, from: data)
        try await saveDreams(dreams)
    }
    
    // MARK: - Debug Methods
    
    /// Test JSON encoding/decoding of a single dream
    func testDreamEncoding(_ dream: Dream) -> Bool {
        print("🧪 Testing JSON encoding/decoding for dream: '\(dream.title)'")
        
        do {
            // Test encoding
            let data = try JSONEncoder().encode(dream)
            print("✅ Successfully encoded dream to \(data.count) bytes")
            
            // Test decoding
            let decodedDream = try JSONDecoder().decode(Dream.self, from: data)
            print("✅ Successfully decoded dream: '\(decodedDream.title)'")
            
            // Check interpretation data
            if let originalInterpretation = dream.interpretation {
                print("📝 Original dream has interpretation: \(originalInterpretation.dreamTitle)")
                
                if let decodedInterpretation = decodedDream.interpretation {
                    print("✅ Decoded dream has interpretation: \(decodedInterpretation.dreamTitle)")
                    
                    let isSame = originalInterpretation.dreamTitle == decodedInterpretation.dreamTitle
                    print("🔍 Interpretation data preserved: \(isSame)")
                    return isSame
                } else {
                    print("❌ Decoded dream has NO interpretation data")
                    return false
                }
            } else {
                print("📝 Original dream has NO interpretation data")
                if decodedDream.interpretation == nil {
                    print("✅ Decoded dream also has NO interpretation data (consistent)")
                    return true
                } else {
                    print("❌ Decoded dream has interpretation data (inconsistent)")
                    return false
                }
            }
        } catch {
            print("❌ JSON encoding/decoding failed: \(error)")
            return false
        }
    }
}

// MARK: - Storage Errors
enum StorageError: LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case dreamNotFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let error):
            return "Failed to encode dreams: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode dreams: \(error.localizedDescription)"
        case .dreamNotFound:
            return "Dream not found in storage"
        case .invalidData:
            return "Invalid data format"
        }
    }
}

// MARK: - Storage Statistics
struct StorageStats {
    let totalDreams: Int
    let lastSyncDate: Date?
    let storageSize: Int
    
    var formattedStorageSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(storageSize))
    }
    
    var formattedLastSync: String {
        guard let lastSync = lastSyncDate else {
            return "Never"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: lastSync)
    }
} 