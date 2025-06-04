import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject private var supabaseService: SupabaseService
    @EnvironmentObject private var superwallService: SuperwallService
    @State private var selectedTab = 0
 
    var body: some View {
                   if supabaseService.isAuthenticated {
                            GeometryReader { proxy in
                               DreamListView(topEdge: proxy.safeAreaInsets.top)
                                   .ignoresSafeArea(.all, edges: .top)
                                }
                    }
                   else {
                       AuthView()
                   }
 
    }
}

#Preview {
    ContentView()
        .environmentObject(SupabaseService())
        .environmentObject(SuperwallService())
}
