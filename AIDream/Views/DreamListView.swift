import SwiftUI
import CoreData

struct DreamListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DreamEntry.date, ascending: false)],
        animation: .default)
    private var dreams: FetchedResults<DreamEntry>
    
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedMood: String?
    @State private var selectedTags: Set<String> = []
    @State private var showProfile = false
    @State private var showingAddDream = false
    @State private var selectedFilter = "Newest First"
    @State private var selectedDream: DreamEntry? = nil
    
    var filteredDreams: [DreamEntry] {
        var result = dreams.filter { dream in
            let matchesSearch: Bool
            switch selectedFilter {
            case "Tags":
                if let tags = dream.interpretationValue?.tags {
                    matchesSearch = searchText.isEmpty || tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
                } else {
                    matchesSearch = searchText.isEmpty
                }
            case "Moods":
                let moodString = dream.mood ?? ""
                matchesSearch = searchText.isEmpty ||
                    moodString.localizedCaseInsensitiveContains(searchText)
            default:
                matchesSearch = searchText.isEmpty || (dream.content?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
            return matchesSearch
        }
        
        switch selectedFilter {
        case "Newest First":
            result.sort { ($0.date ?? Date()) > ($1.date ?? Date()) }
        case "Oldest First":
            result.sort { ($0.date ?? Date()) < ($1.date ?? Date()) }
        default:
            break
        }
        
        return result
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 16) {
                    // Верхняя панель
                    HStack {
                        Button(action: { showProfile = true }) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Приветствие
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Доброе утро")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        Text("Готовы записать сон?")
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Поиск и фильтр
                    HStack {
                        TextField("Поиск", text: $searchText)
                            .padding(10)
                            .background(Color(.systemGray5).opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        Button(action: { showingFilters.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Список снов
                    VStack(spacing: 12) {
                        ForEach(filteredDreams) { dream in
                            Button(action: {
                                selectedDream = dream
                            }) {
                                DreamCard(dream: dream)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Кнопка добавления
            Button(action: { showingAddDream = true }) {
                ZStack {
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 64, height: 64)
                        .shadow(radius: 8)
                    Image(systemName: "plus")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }
            }
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showingAddDream) {
            NavigationView {
                DreamCreationView()
            }
        }
        .sheet(item: $selectedDream) { dream in
            NavigationView {
                DreamDetailView(dream: dream)
            }
        }
    }
}

#Preview {
    DreamListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
