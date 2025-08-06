//
// MoodStore.swift
//
// Created by Cesare on 08.07.2025 on Earth.
//


import Foundation
import CoreData

final class MoodStore: AppDataResettable {

    // MARK: - Public Properties
    
    @Published var moods: [Mood] = []
    
    // MARK: - Private Properties
    private let container: NSPersistentContainer
    
    // MARK: - Lifecycle
    
    init() {
        container = NSPersistentCloudKitContainer(name: "MoodDataModel")
        container.loadPersistentStores { _, error in
            if let error {
                print("Error loadind CoreData \(error)")
            }
        }
        loadMoods()
    }
    // MARK: - Public Functions
    
    func addMood(_ mood: Mood) {
        moods.append(mood)
        saveMood(mood)
    }
    
    func resetAppData() {
        moods.removeAll()
        
        let request: NSFetchRequest<NSFetchRequestResult> = MoodEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try container.viewContext.execute(deleteRequest)
            saveData()
        } catch {
            print("Ошибка при очистке MoodEntity: \(error)")
        }
        
        // Возвращаем дефолтные настроения
        loadMoods()
    }
    
    // MARK: - Private Functions
    
    private func saveMood(_ mood: Mood) {
        let newMood = MoodEntity(context: container.viewContext)
        
        newMood.id = mood.id
        newMood.title = mood.title
        newMood.emoji = mood.emoji
        newMood.isDefault = mood.isDefault
        
        saveData()
    }
    
    func loadMoods() {
        moods = loadDefaultMoods()
        moods.append(contentsOf: loadCustomMoods())
    }
    
    private func loadDefaultMoods() -> [Mood] {
        Mood.predefined
    }
    
    private func loadCustomMoods() -> [Mood] {
        let moodsRequest = NSFetchRequest<MoodEntity>(entityName: "MoodEntity")
        var moodsEntity: [MoodEntity] = []
        
        do {
            moodsEntity = try container.viewContext.fetch(moodsRequest)
        } catch let error {
            print("⚠️ Error fetch moods: \(error)")
        }
        
        return moodsEntity.map { Mood(from: $0) }
    }
    
    private func saveData() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Error saving \(error)")
        }
    }
}
