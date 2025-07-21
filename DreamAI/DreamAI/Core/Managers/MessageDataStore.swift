//
// MessageDataStore.swift
//
// Created by Cesare on 21.07.2025 on Earth.
// 


import Foundation
import CoreData
import CloudKit

final class MessageDataStore {
    
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentCloudKitContainer(name: "MessageDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                print("Error loadind CoreData \(error)")
            }
        }
    }
    
    func saveMessage(_ message: Message, dremId: UUID) {
        let entity = MessageEntity(context: container.viewContext)
        
        entity.id = message.id
        entity.text = message.text
        entity.role = message.role
        entity.timeStamp = message.timeStamp
        entity.dreamId = dremId
        
        saveData()
    }
    
    func loadMessagesFor(dreamId: UUID) -> [Message] {
        let request = NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
        request.predicate = NSPredicate(format: "dreamId == %@", dreamId as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: true)]

        do {
            let entities = try container.viewContext.fetch(request)
            return entities.compactMap { entity in
                guard
                    let id = entity.id,
                    let role = entity.role,
                    let text = entity.text,
                    let timeStamp = entity.timeStamp
                else {
                    return nil
                }

                return Message(
                    id: id,
                    sender: role,
                    text: text,
                    timeStamp: timeStamp
                )
            }
        } catch {
            print("Failed to fetch messages for dreamId \(dreamId): \(error)")
            return []
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
