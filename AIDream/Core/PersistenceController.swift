import CoreData
 

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Регистрируем трансформатор до создания контейнера
//        StringArrayTransformer.register()

        container = NSPersistentContainer(name: "AIDream")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Preview Helper
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        // Создаем тестовые данные
        let viewContext = controller.container.viewContext
        
        // Создаем теги
        let tag1 = Tag(context: viewContext)
        tag1.id = UUID()
        tag1.name = "Работа"
        tag1.color = "#FF6B6B"
        tag1.createdAt = Date()
        
        let tag2 = Tag(context: viewContext)
        tag2.id = UUID()
        tag2.name = "Семья"
        tag2.color = "#4ECDC4"
        tag2.createdAt = Date()
        
        // Создаем сны
        let dream1 = DreamEntry(context: viewContext)
        dream1.id = UUID()
        dream1.content = "Я летал над городом и видел все здания с высоты птичьего полета."
        dream1.date = Date()
        dream1.mood = "Счастливый"
        dream1.tags = ["Полёт", "Город"] as NSObject
        dream1.isSynced = true
        dream1.createdAt = Date()
        dream1.updatedAt = Date()
        
        let dream2 = DreamEntry(context: viewContext)
        dream2.id = UUID()
        dream2.content = "Я был в старом доме, где все стены были покрыты фотографиями."
        dream2.date = Date().addingTimeInterval(-86400)
        dream2.mood = "Нейтральный"
        dream2.tags = ["Дом", "Фотографии"] as NSObject
        dream2.isSynced = true
        dream2.createdAt = Date().addingTimeInterval(-86400)
        dream2.updatedAt = Date().addingTimeInterval(-86400)
        
        // Создаем настройки пользователя
        let settings = UserSettings(context: viewContext)
        settings.id = UUID()
        settings.isDarkMode = false
        settings.language = "Русский"
        settings.notificationsEnabled = true
        settings.sleepTime = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date())!
        settings.wakeTime = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
        settings.useFaceID = true
        
        try? viewContext.save()
        
        return controller
    }()
} 
