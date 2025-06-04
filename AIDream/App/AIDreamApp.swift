import SwiftUI

@main
struct AIDreamApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appSettings = AppSettings.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
        }
    }
} 