import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var supabaseService: SupabaseService
    @EnvironmentObject private var superwallService: SuperwallService
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !supabaseService.isInitialized {
                ProgressView("Инициализация...")
            } else if supabaseService.isAuthenticated {
                TabView(selection: $selectedTab) {
                    DreamListView()
                        .tabItem {
                            Label("Сны", systemImage: "moon.stars")
                        }
                        .tag(0)
                    
                    SettingsView()
                        .tabItem {
                            Label("Настройки", systemImage: "gear")
                        }
                        .tag(1)
                }
            } else {
                AuthView()
            }
        }
        .alert("Ошибка", isPresented: .constant(supabaseService.error != nil)) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = supabaseService.error {
                Text(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(SupabaseService())
        .environmentObject(SuperwallService())
} 