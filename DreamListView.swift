import SwiftUI
import CoreData
 
struct OffsetModifier: ViewModifier {
    
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        
        content
            .overlay(
                GeometryReader { proxy -> Color in
                    let minY = proxy.frame(in: .named("scroll")).minY
                    DispatchQueue.main.async {
                        self.offset = minY
                    }
                    return Color.clear
                },
                alignment: .top
            )
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

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

    // Для коллапса
    @State private var scrollOffset: CGFloat = 0
    
    @State private var selectedDream: DreamEntry? = nil

    private var filteredDreams: [DreamEntry] {
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
                    moodString.localizedCaseInsensitiveContains(searchText) ||
                    getMoodEmoji(for: moodString).localizedCaseInsensitiveContains(searchText)
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
        case "Moods":
            result.sort { ($0.mood ?? "") < ($1.mood ?? "") }
        default:
            break
        }

        return result
    }
    let maxHeight = UIScreen.main.bounds.height / 2.3
    var topEdge: CGFloat
    
    @State var offset: CGFloat = 0
    
    var headerHeight: CGFloat {
        let topHeight = maxHeight + offset
        return topHeight > 20 + topEdge ? topHeight : 20 + topEdge
    }
    
    var cornerRadius: CGFloat {
        let progress = -offset / (maxHeight - (20 + topEdge))
        let radius = (1 - progress) * 50
        return offset < 0 ? radius : 50
    }
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .overlay(
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                )
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 15) {
                    
                    GeometryReader { proxy in
                        TopBar(topEdge: topEdge, offset: $offset, maxHeight: maxHeight)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: headerHeight, alignment: .bottom)
                            .overlay(NavBar(topEdge: topEdge, offset: $offset, maxHeight: maxHeight, showProfile: { showProfile = true }), alignment: .top)
                    }
                    .frame(height: maxHeight)
                    .offset(y: -offset)
                    .zIndex(1)
                    
                    VStack(spacing: 12) {
                        StickySearchBar(searchText: $searchText, offset: $offset, selectedFilter: $selectedFilter)
                                 .zIndex(1)
 
                        // Карточки снов
                        ForEach(filteredDreams) { dream in
                            Button(action: {
                                selectedDream = dream
                            }) {
                                if let interpretation = dream.interpretationValue {
                                    DreamCard(dream: dream, interpretation: interpretation)
                                } else {
                                    DreamCard(dream: dream, interpretation: DreamInterpretation.preview)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    .background(Color.customBackground)
                    .zIndex(2)
                }
                .modifier(OffsetModifier(offset: $offset))
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(OffsetKey.self) { value in
                           scrollOffset = value
                       }
            .overlay(
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
                .sheet(isPresented: $showProfile) {
                    NavigationView {
                        ProfileView()
                    }
                }
                .sheet(isPresented: $showingAddDream) {
                    NavigationView {
                        DreamCreationView()
                    }
                }
                , alignment: .bottom
            )
        }
        
        .sheet(item: $selectedDream) { dream in
            DreamDetailView(dream: dream)
        }
        
        .onAppear {
            for dream in dreams {
                print("Сон: \(dream.content ?? "nil")")
                print("Теги: \(dream.interpretationValue?.tags ?? [])")
            }
        }
//        .onAppear {
//            print("DreamListView появился")
//            print("Всего снов в базе: \(dreams.count)")
//            for dream in dreams {
//                print("Сон: \(dream.content ?? "nil"), дата: \(dream.date?.description ?? "nil"), интерпретация: \(dream.interpretation ?? "нет")")
//            }
//        }
    }
    func getMoodEmoji(for mood: String) -> String {
        // Если настроение уже содержит эмодзи, извлекаем его
        if let emoji = mood.split(separator: " ").first {
            return String(emoji)
        }
        // Иначе определяем эмодзи по названию
        switch mood {
        case "Счастливый": return "😊"
        case "Грустный": return "😢"
        case "Нейтральный": return "😐"
        case "Тревожный": return "😰"
        case "Возбужденный": return "🤩"
        default: return "😐"
        }
    }
}
struct StickySearchBar: View {
    @Binding var searchText: String
    @Binding var offset: CGFloat
    @Binding var selectedFilter: String

    var body: some View {
        GeometryReader { geometry -> AnyView in
            let minY = geometry.frame(in: .global).minY
            let yOffset = minY < 0 ? -minY + 40 : 0

            return AnyView(
                HStack(spacing: 8) {
                    TextField("Search dreams...", text: $searchText)
                        .frame(height: 20)
                         .padding(15)
                        .foregroundStyle(Color.customLightGray)
                        .background(Color.customSecondaryBackground)
                        .cornerRadius(10)

                    Menu {
                        Button("Newest First") { selectedFilter = "Newest First" }
                        Button("Oldest First") { selectedFilter = "Oldest First" }
                        Button("Tags") { selectedFilter = "Tags" }
                        Button("Moods") { selectedFilter = "Moods" }
                    } label: {
                        Image("filter")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .padding(15)
                            .background(Color.customSecondaryBackground)
                            .cornerRadius(10)
                    }
                }
                    .padding(.top, 8)
                .offset(y: yOffset)
            )
        }
        .frame(height: 60)
    }
}

//struct StickySearchBar: View {
//    @Binding var searchText: String
//    @Binding var offset: CGFloat
//    
//    var body: some View {
//        GeometryReader { geometry -> AnyView in
//            let minY = geometry.frame(in: .global).minY
//            let offset = minY < 0 ? -minY + 40 : 0
//            
//            return AnyView(
//                TextField("Search dreams...", text: $searchText)
//                    .padding(10)
//                    .foregroundStyle(Color.customLightGray)
//                    .background(Color.customSecondaryBackground)
//                    .cornerRadius(10)
//                    .padding(.top, 8)
//                    .offset(y: offset)
//            )
//        }
//        .frame(height: 60)
//    }
//}

// MARK: - Offset Key for Sticky Behavior
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct NavBar: View {
    
    let topEdge: CGFloat
    @Binding var offset: CGFloat
    var maxHeight: CGFloat
    var showProfile: () -> Void

    var topBarOpacity: CGFloat {
        -(offset + 70) / (maxHeight - (80 + topEdge))
    }
    var profileIconOpacity: CGFloat {
        let progress = -offset / (maxHeight - (20 + topEdge))
        return max(0, 1 - progress * 1.5) // исчезает быстрее
    }

    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Button(action: showProfile) {
                Image("profileIcon")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .opacity(profileIconOpacity)
            }
            
            Spacer()
            Spacer()

             
        }
        .padding(.horizontal)
        .frame(height: 80)
        .foregroundColor(.white)
        .padding(.top, topEdge)
    }
}

struct TopBar: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DreamEntry.date, ascending: false)],
        animation: .default)
    private var dreams: FetchedResults<DreamEntry>
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedMood: String?
    @State private var selectedTags: Set<String> = []
    let topEdge: CGFloat
    @Binding var offset: CGFloat
    var maxHeight: CGFloat
    var filteredDreams: [DreamEntry] {
        dreams.filter { dream in
            let matchesSearch = searchText.isEmpty || (dream.content?.localizedCaseInsensitiveContains(searchText) ?? false)
            let matchesMood = selectedMood == nil || dream.mood == selectedMood
            let matchesTags = selectedTags.isEmpty || (dream.tags as? [String])?.contains(where: { selectedTags.contains($0) }) ?? false
            return matchesSearch && matchesMood && matchesTags
        }
    }
    var barOpacity: CGFloat {
        let progress = -offset / 70
        let opactity = 1 - progress
        return offset < 0 ? opactity : 1
    }
    
    var body: some View {
         VStack(alignment: .center, spacing: 15) {
             Spacer()
             Text("Good morning")
                 .font(.system(size: 34, weight: .bold))
                 .foregroundColor(.white)
                 .minimumScaleFactor(0.9)
                 .lineLimit(1)
                 .layoutPriority(1)

             Text("ready to lod a dream?")
                .font(.system(size: 15))
                .foregroundColor(.customLightGray)
                .opacity(0.5)
             if let dream = filteredDreams.first {
                 NavigationLink(destination: DreamDetailView(dream: dream)) {
                     if let interpretation = dream.interpretationValue {
                         DreamLastCard(dream: dream, interpretation: interpretation)
                     } else {
                         DreamLastCard(dream: dream, interpretation: DreamInterpretation.preview)
                     }
                 }
             }
             Spacer()
        }
        .padding()
        .opacity(barOpacity)
    }
}









//
//
//import SwiftUI
//import CoreData
//
//struct ScrollOffsetPreferenceKey: PreferenceKey {
//    static var defaultValue: CGFloat = 0
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = nextValue()
//    }
//}
//
//struct CollapsibleDreamHeader: View {
//    let state: HeaderState
//    var showProfile: () -> Void
//    var lastDream: DreamEntry?
//
//    enum HeaderState {
//        case expanded
//        case collapsed
//    }
//
//    var body: some View {
//        let height: CGFloat = state == .expanded ? 260 : 100
//        ZStack(alignment: .bottomLeading) {
//            LinearGradient(
//                gradient: Gradient(colors: [Color.purple, Color.black]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .frame(height: height)
//            .ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 4) {
//                HStack {
//                    Button(action: showProfile) {
//                        Image(systemName: "person.circle.fill")
//                            .font(.system(size: 32))
//                            .foregroundColor(.white)
//                    }
//                    Spacer()
//                }
//                .padding(.horizontal)
//                .padding(.top, 16)
//
//                if state == .expanded {
//                    Text("Good morning")
//                        .font(.largeTitle).bold()
//                        .foregroundColor(.white)
//                    Text("Ready to log a dream?")
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.bottom, 24)
//        }
//        .frame(height: height)
//        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: state)
//    }
//}
//
//struct DreamListView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \DreamEntry.date, ascending: false)],
//        animation: .default)
//    private var dreams: FetchedResults<DreamEntry>
//
//    @State private var searchText = ""
//    @State private var showingFilters = false
//    @State private var selectedMood: String?
//    @State private var selectedTags: Set<String> = []
//    @State private var showProfile = false
//    @State private var showingAddDream = false
//
//    // Для коллапса
//    @State private var headerState: CollapsibleDreamHeader.HeaderState = .expanded
//    @State private var scrollOffset: CGFloat = 0
//
//    var filteredDreams: [DreamEntry] {
//        dreams.filter { dream in
//            let matchesSearch = searchText.isEmpty || (dream.content?.localizedCaseInsensitiveContains(searchText) ?? false)
//            let matchesMood = selectedMood == nil || dream.mood == selectedMood
//            let matchesTags = selectedTags.isEmpty || (dream.tags as? [String])?.contains(where: { selectedTags.contains($0) }) ?? false
//            return matchesSearch && matchesMood && matchesTags
//        }
//    }
//
//    var body: some View {
//        ZStack(alignment: .top) {
//            ScrollView {
//                // Spacer для отступа под header
//                Spacer().frame(height: headerState == .expanded ? 260 : 100)
//
//                // Поиск и фильтр
//                HStack {
//                    TextField("Search", text: $searchText)
//                        .padding(10)
//                        .background(Color(.systemGray5).opacity(0.2))
//                        .cornerRadius(12)
//                        .foregroundColor(.white)
//                    Button(action: { showingFilters.toggle() }) {
//                        Image(systemName: "line.3.horizontal.decrease.circle")
//                            .font(.system(size: 24))
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 8)
//
//                VStack(spacing: 12) {
//                    ForEach(filteredDreams) { dream in
//                        NavigationLink(destination: DreamDetailView(dream: dream)) {
//                            DreamCard(dream: dream)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 8)
//                .background(GeometryReader {
//                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: -$0.frame(in: .named("scroll")).origin.y)
//                })
//            }
//            .coordinateSpace(name: "scroll")
//            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
//                scrollOffset = value
//                updateHeaderState()
//            }
//
//            // Хедер всегда сверху
//            CollapsibleDreamHeader(state: headerState, showProfile: { showProfile = true }, lastDream: dreams.first)
//                .zIndex(1)
//        }
//        .background(Color.black.ignoresSafeArea())
//        .overlay(
//            Button(action: { showingAddDream = true }) {
//                ZStack {
//                    Circle()
//                        .fill(Color.purple)
//                        .frame(width: 64, height: 64)
//                        .shadow(radius: 8)
//                    Image(systemName: "plus")
//                        .font(.system(size: 32))
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.bottom, 24)
//            .sheet(isPresented: $showingAddDream) {
//                Text("Здесь будет форма добавления сна")
//                    .padding()
//            }
//            , alignment: .bottom
//        )
//    }
//
//    private func updateHeaderState() {
//        if scrollOffset > 100 && headerState == .expanded {
//            headerState = .collapsed
//        } else if scrollOffset <= 100 && headerState == .collapsed {
//            headerState = .expanded
//        }
//    }
//}
//struct MessageCardView: View {
//    
//    var message: Message
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            
//            Circle()
//                 .frame(width: 50, height: 50, alignment: .center)
//                .opacity(0.8)
//            
//            VStack(alignment: .leading, spacing: 8) {
//                
//                Text(message.username)
//                    .fontWeight(.bold)
//                
//                Text(message.message)
//                    .foregroundColor(.secondary)
//            }
//            .foregroundColor(.primary)
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//    }
//    
//}
//
//  
