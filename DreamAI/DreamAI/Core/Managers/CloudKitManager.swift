//
//  CloudKitManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25.
//

import Foundation
import CloudKit

class CloudKitManager {
    static let shared = CloudKitManager()
    private let privateDB = CKContainer(identifier: "iCloud.com.get.DreamAI").privateCloudDatabase
    
    private init() {}
    
    func saveDream(_ dream: Dream, completion: @escaping (Result<CKRecord, Error>) -> Void) {
        let record = CKRecord(recordType: "Dream", recordID: CKRecord.ID(recordName: dream.id.uuidString))
        record["emoji"] = dream.emoji
        record["emojiBackground"] = dream.emojiBackground.toHex()
        record["title"] = dream.title
        record["tags"] = dream.tags.map { $0.rawValue }
        record["date"] = dream.date
        record["requestStatus"] = dream.requestStatus.toString()
        
        privateDB.save(record) { (savedRecord, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let savedRecord = savedRecord else {
                completion(.failure(NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save record"])))
                return
            }
            completion(.success(savedRecord))
        }
    }
    
    func fetchDreams(completion: @escaping (Result<[Dream], Error>) -> Void) {
        let query = CKQuery(recordType: "Dream", predicate: NSPredicate(value: true))
        
        privateDB.fetch(withQuery: query) { result in
            switch result {
            case .success(let result):
                let dreams = result.matchResults.compactMap { (recordID, recordResult) -> Dream? in
                    switch recordResult {
                    case .success(let record):
                        return Dream(record: record)
                    case .failure(let error):
                        print("Error fetching individual record: \(error)")
                        return nil
                    }
                }
                completion(.success(dreams))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteDream(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> Void) {
        privateDB.delete(withRecordID: recordID) { (deletedRecordID, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let deletedRecordID = deletedRecordID else {
                completion(.failure(NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to delete record"])))
                return
            }
            completion(.success(deletedRecordID))
        }
    }
}
