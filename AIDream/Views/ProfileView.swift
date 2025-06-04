//
//  ProfileView.swift
//  AIDream
//
//  Created by Александра Тажибай on 03.06.2025.
//
import UniformTypeIdentifiers
import SwiftUI
import LocalAuthentication
import UserNotifications
import CoreData

struct ProfileView: View {
 
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var exportURL: URL?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showDone = false
    @EnvironmentObject var supabaseService: SupabaseService
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @State private var showingLogoutAlert = false
    @State private var showingResetAlert = false
    @State private var showingFeedback = false
    @State private var userProfile: UserProfile? = {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return nil
    }()
    
    // Новые состояния для настроек
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
//    @AppStorage("subscriptionType") private var subscriptionType: String = "monthly" // или "yearly"
    @AppStorage("subscriptionEndDate") private var subscriptionEndDate: Double = Date().timeIntervalSince1970
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("bedtime") private var bedtime: Double = Date().timeIntervalSince1970
    @AppStorage("wakeUpTime") private var wakeUpTime: Double = Date().timeIntervalSince1970
    @State private var showingSubscriptionView = false
    
    @AppStorage("iCloudExportEnabled") private var iCloudExportEnabled: Bool = false
    @Environment(\.managedObjectContext) private var viewContext
    // Форматтер даты
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    // Добавить вычисляемое свойство для даты окончания
    private var subscriptionExpirationDate: Date? {
        subscriptionManager.expirationDate
    }
    private var subscriptionType: String {
        switch subscriptionManager.currentPlan {
        case "monthly": return "Monthly"
        case "yearly": return "Yearly"
        default: return "Free"
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
                .ignoresSafeArea(.all)
            ScrollView {
                VStack(spacing: 10) {
                    subscriptionSection
                    exportImportSection
                    settingsSection
                     
                    Button(action: {
                        Task {
                            do {
                                try await supabaseService.signOut()
                            } catch {
                                print("Ошибка при выходе: \(error)")
                            }
                        }
                    }) {
                        Text("Exit")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color.customSecondaryBackground)
                            .cornerRadius(13)
                     }

                }
                .padding()
            }
            .onChange(of: notificationsEnabled) { value in
                if value {
                    subscriptionManager.requestNotificationPermission()
                    subscriptionManager.scheduleNotification(at: Date(timeIntervalSince1970: bedtime), identifier: "bedtime", body: "Время ложиться спать!")
                    subscriptionManager.scheduleNotification(at: Date(timeIntervalSince1970: wakeUpTime), identifier: "wakeUp", body: "Доброе утро! Запишите свой сон.")
                } else {
                    subscriptionManager.removeNotifications()
                }
            }
            .onChange(of: bedtime) { _ in
                if notificationsEnabled {
                    subscriptionManager.scheduleNotification(
                        at: Date(timeIntervalSince1970: bedtime),
                        identifier: "bedtime",
                        body: "Время ложиться спать!"
                    )
                }
            }
            .onChange(of: wakeUpTime) { _ in
                if notificationsEnabled {
                    subscriptionManager.scheduleNotification(
                        at: Date(timeIntervalSince1970: wakeUpTime),
                        identifier: "wakeUp",
                        body: "Доброе утро! Запишите свой сон."
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {}
                    .foregroundColor(.purple) // Цвет кнопки Cancel
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    
                }
                .foregroundColor(.purple) // Цвет кнопки Cancel
                .bold()
             }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    private var subscriptionSection: some View {
        VStack {
            HStack {
                Text("Subscription")
                    .font(.system(size: 16))
                    .bold()
                    .foregroundStyle(Color.purple)
                Spacer()
                if let expirationDate = subscriptionExpirationDate {
                    Text(dateFormatter.string(from: expirationDate))
                        .font(.system(size: 13))
                        .foregroundStyle(Color.gray)
                } else if subscriptionManager.isTrialActive {
                    Text("Trial active")
                        .font(.system(size: 16))
                } else {
                    Text("No active")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.white)

                }
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Your Plan")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.gray)
                    Text(subscriptionType)
                        .font(.system(size: 28))
                        .foregroundStyle(Color.white)
                        .frame(height: 56)
                }
                Spacer()
                Image(systemName: subscriptionManager.isPremium ? "crown" : "star")
                    .foregroundColor(.purple)
                    .font(.system(size: 32))
            }
        }
        .profileCardStyle()
        .sheet(isPresented: $showingSubscriptionView) {
            SubscriptionView()
        }
    }
    private var exportImportSection: some View {
        VStack {
            HStack {
                Image(systemName: "icloud")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.purple)
                Text("iCloud")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white)

                Spacer()
                Toggle("", isOn: $iCloudExportEnabled)
                    .labelsHidden()
                    .tint(Color.purple)
                    .onChange(of: iCloudExportEnabled) { value in
                        if value {
                            exportDreamsToICloud(context: viewContext) { _ in }
                        }
                    }
            }

            HStack {
                Image(systemName: "square.and.arrow.up.on.square")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.purple)
                Text("Export/Import")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white)

                Spacer()
                Menu {
                    Button("Export to JSON") {
                        if let url = exportDreamsToJSON(context: viewContext) {
                            exportURL = url
                            showExporter = true
                        }
                    }
                    Button("Import from JSON") {
                        showImporter = true
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.gray)
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: exportURL.map { URLDocument(url: $0) },
                contentType: .json,
                defaultFilename: "DreamsBackup"
            ) { result in
                if case .success = result {
                    showDone = true
                }
            }
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.json]
            ) { result in
                switch result {
                case .success(let url):
                    let shouldAccess = url.startAccessingSecurityScopedResource()
                    defer {
                        if shouldAccess {
                            url.stopAccessingSecurityScopedResource()
                        }
                    }
                    do {
                        let data = try Data(contentsOf: url)
                        importDreamsFromJSONData(data, context: viewContext)
                    } catch {
                        errorMessage = "Import error: \(error.localizedDescription)"
                        showError = true
                    }
                case .failure(let error):
                    errorMessage = "Import error: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
        .profileCardStyle()
    }
    private var settingsSection: some View {
        VStack {
            HStack {
                Image(systemName: "globe")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.purple)
                Text("Language")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white)

                Spacer()
                Picker("Language", selection: $selectedLanguage) {
                    Text("English").tag("en")
                    Text("Русский").tag("ru")
                }
                .tint(Color.gray)
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
            }

            FaceIDToggle()

            HStack {
                Image(systemName: "bell")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.purple)
                Text("Notifications")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white)
                Spacer()
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
                    .tint(Color.purple)
            }

            if notificationsEnabled {
                timeSettings
            }

            HStack {
                Image(systemName: "message")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.purple)
                Text("Write feedback")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .profileCardStyle()
    }
    private var timeSettings: some View {
        Group {
            HStack {
                Image(systemName: "moon")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.purple)
                Text("Bedtime")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white)
                Spacer()
                DatePicker("", selection: Binding(
                    get: { Date(timeIntervalSince1970: bedtime) },
                    set: { bedtime = $0.timeIntervalSince1970 }
                ), displayedComponents: .hourAndMinute)
                .labelsHidden()
                .tint(Color.white)
            }
            HStack {
                Image(systemName: "sun.max")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.purple)
                Text("Wake-up")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.white)
                Spacer()
                DatePicker("", selection: Binding(
                    get: { Date(timeIntervalSince1970: wakeUpTime) },
                    set: { wakeUpTime = $0.timeIntervalSince1970 }
                ), displayedComponents: .hourAndMinute)
                .labelsHidden()
            }
        }
    }
    
    func exportDreamsToJSON(context: NSManagedObjectContext) -> URL? {
        let fetchRequest: NSFetchRequest<DreamEntry> = DreamEntry.fetchRequest()
        do {
            let dreams = try context.fetch(fetchRequest)
            let exportArray = dreams.map { dream in
                [
                    "id": dream.id?.uuidString ?? "",
                    "content": dream.content ?? "",
                    "date": dream.date?.ISO8601Format() ?? "",
                    "mood": dream.mood ?? "",
                    "tags": (dream.tags as? [String]) ?? [],
                    "createdAt": dream.createdAt?.ISO8601Format() ?? "",
                    "updatedAt": dream.updatedAt?.ISO8601Format() ?? ""
                ]
            }
            let data = try JSONSerialization.data(withJSONObject: exportArray, options: .prettyPrinted)
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("DreamsBackup.json")
            try data.write(to: tempURL)
            return tempURL
        } catch {
            errorMessage = "Export error: \(error.localizedDescription)"
            showError = true
            return nil
        }
    }

    func importDreamsFromJSONData(_ data: Data, context: NSManagedObjectContext) {
        do {
            guard let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                errorMessage = "Invalid file structure"
                showError = true
                return
            }
            for dict in array {
                guard let content = dict["content"] as? String, !content.isEmpty else { continue }
                let dream = DreamEntry(context: context)
                dream.id = UUID(uuidString: dict["id"] as? String ?? "") ?? UUID()
                dream.content = content
                dream.date = ISO8601DateFormatter().date(from: dict["date"] as? String ?? "")
                dream.mood = dict["mood"] as? String
                dream.tags = dict["tags"] as? [String] as NSArray?
                dream.createdAt = ISO8601DateFormatter().date(from: dict["createdAt"] as? String ?? "")
                dream.updatedAt = ISO8601DateFormatter().date(from: dict["updatedAt"] as? String ?? "")
            }
            try context.save()
            showDone = true
        } catch {
            errorMessage = "Import error: \(error.localizedDescription)"
            showError = true
        }
    }
    func exportDreamsToICloud(context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<DreamEntry> = DreamEntry.fetchRequest()
        do {
            let dreams = try context.fetch(fetchRequest)
            let exportArray = dreams.map { dream in
                [
                    "id": dream.id?.uuidString ?? "",
                    "content": dream.content ?? "",
                    "date": dream.date?.ISO8601Format() ?? "",
                    "mood": dream.mood ?? "",
                    "tags": (dream.tags as? [String]) ?? [],
                    "createdAt": dream.createdAt?.ISO8601Format() ?? "",
                    "updatedAt": dream.updatedAt?.ISO8601Format() ?? ""
                ]
            }
            let data = try JSONSerialization.data(withJSONObject: exportArray, options: .prettyPrinted)
            if let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
                .appendingPathComponent("Documents")
                .appendingPathComponent("DreamsBackup.json") {
                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
                try data.write(to: url)
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("iCloud export error:", error)
            completion(false)
        }
    }
      }
// --- Для смены языка ---
extension Bundle {
    private static var bundle: Bundle?

    static func setLanguage(_ language: String) {
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return }
        bundle = Bundle(path: path)
    }

    static func localizedString(key: String, tableName: String? = nil) -> String {
        bundle?.localizedString(forKey: key, value: nil, table: tableName) ??
        NSLocalizedString(key, tableName: tableName, comment: "")
    }
}
struct URLDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var url: URL

    init(url: URL) { self.url = url }
    init(configuration: ReadConfiguration) throws { fatalError() }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        try FileWrapper(url: url)
    }
}
extension View {
    func profileCardStyle() -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.customSecondaryBackground)
            .cornerRadius(17)
    }
}
// 
//
////
////  ProfileView.swift
////  AIDream
////
////  Created by Александра Тажибай on 03.06.2025.
////
//import UniformTypeIdentifiers
//import SwiftUI
//import LocalAuthentication
//import UserNotifications
//import CoreData
//
//struct ProfileView: View {
// 
//    @State private var showExporter = false
//    @State private var showImporter = false
//    @State private var exportURL: URL?
//    @State private var isLoading = false
//    @State private var showError = false
//    @State private var errorMessage = ""
//    @State private var showDone = false
// 
//    @EnvironmentObject private var appState: AppState
//    @EnvironmentObject private var subscriptionManager: SubscriptionManager
//    @State private var showingLogoutAlert = false
//    @State private var showingResetAlert = false
//    @State private var showingFeedback = false
//    @State private var userProfile: UserProfile? = {
//        if let data = UserDefaults.standard.data(forKey: "userProfile"),
//           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
//            return profile
//        }
//        return nil
//    }()
//    
//    // Новые состояния для настроек
//    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
////    @AppStorage("subscriptionType") private var subscriptionType: String = "monthly" // или "yearly"
//    @AppStorage("subscriptionEndDate") private var subscriptionEndDate: Double = Date().timeIntervalSince1970
//    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
//    @AppStorage("bedtime") private var bedtime: Double = Date().timeIntervalSince1970
//    @AppStorage("wakeUpTime") private var wakeUpTime: Double = Date().timeIntervalSince1970
//    @State private var showingSubscriptionView = false
//    
//    @AppStorage("iCloudExportEnabled") private var iCloudExportEnabled: Bool = false
//    @Environment(\.managedObjectContext) private var viewContext
//    // Форматтер даты
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter
//    }
//    
//    // Добавить вычисляемое свойство для даты окончания
//    private var subscriptionExpirationDate: Date? {
//        subscriptionManager.expirationDate
//    }
//    private var subscriptionType: String {
//        switch subscriptionManager.currentPlan {
//        case "monthly": return "Monthly"
//        case "yearly": return "Yearly"
//        default: return "Free"
//        }
//    }
//    
//    var body: some View {
//        ZStack{
//            Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
//                .ignoresSafeArea(.all)
//            ScrollView{
//                VStack(spacing: 10){
//                    // Подписка
//                    VStack{
//                        HStack{
//                            Text("Subscription")
//                                .font(.system(size: 16))
//                                .foregroundStyle(Color.purple)
//                            Spacer()
//                            if let expirationDate = subscriptionExpirationDate {
//                                Text(dateFormatter.string(from: expirationDate))
//                                    .font(.system(size: 16))
//                            } else if subscriptionManager.isTrialActive {
//                                Text("Trial active")
//                                    .font(.system(size: 16))
//                            } else {
//                                Text("No active")
//                                    .font(.system(size: 16))
//                            }
//                        }
//                        HStack{
//                            VStack(alignment: .leading){
//                                Text("Your Plan")
//                                    .font(.system(size: 16))
//                                Text(subscriptionType)
//                                    .font(.system(size: 28))
//                            }
//                            Spacer()
//                            Image(systemName: subscriptionManager.isPremium ? "crown" : "star")
//                                .foregroundColor(.purple)
//                                .font(.system(size: 32))
//                        }
////                        if !subscriptionManager.isPremium {
////                            Button("Upgrade to Premium") {
////                                showingSubscriptionView = true
////                            }
////                            .buttonStyle(.borderedProminent)
////                            .tint(.purple)
////                        } else {
////                            Button("Manage Subscription") {
////                                showingSubscriptionView = true
////                            }
////                            .buttonStyle(.bordered)
////                        }
//                    }
//                    .profileCardStyle()
//                    .sheet(isPresented: $showingSubscriptionView) {
//                        SubscriptionView()
//                    }
//                    // iCloud и Export/Import (заглушки)
//                    VStack{
//                        HStack{
//                            Image(systemName: "icloud")
//                                .font(.system(size: 16))
//                            Text("iCloud")
//                                .font(.system(size: 17))
//                            Spacer()
//                            Toggle("", isOn: $iCloudExportEnabled)
//                                .labelsHidden()
//                                .onChange(of: iCloudExportEnabled) { value in
//                                    if value {
//                                        exportDreamsToICloud(context: viewContext) { success in
//                                            // Можно показать алерт об успехе/ошибке
//                                        }
//                                    }
//                                }
//                        }
////                        HStack{
////                            Image(systemName: "square.and.arrow.up.on.square")
////                                .font(.system(size: 16))
////                            Text("Export/Import")
////                                .font(.system(size: 17))
////                            Spacer()
////                            Image(systemName: "chevron.right")
////                        }
//                        HStack {
//                            Image(systemName: "square.and.arrow.up.on.square")
//                                .font(.system(size: 16))
//                            Text("Export/Import")
//                                .font(.system(size: 17))
//                            Spacer()
//                            Menu {
//                                Button("Export to JSON") {
//                                    if let url = exportDreamsToJSON(context: viewContext) {
//                                        exportURL = url
//                                        showExporter = true
//                                    }
//                                }
//                                Button("Import from JSON") {
//                                    showImporter = true
//                                }
//                            } label: {
//                                Image(systemName: "chevron.right")
//                            }
//                        }
//                        .fileExporter(
//                            isPresented: $showExporter,
//                            document: exportURL.map { URLDocument(url: $0) },
//                            contentType: .json,
//                            defaultFilename: "DreamsBackup"
//                        ) { result in
//                            if case .success = result {
//                                showDone = true
//                            }
//                        }
//                        .fileImporter(
//                            isPresented: $showImporter,
//                            allowedContentTypes: [.json]
//                        ) { result in
//                            switch result {
//                            case .success(let url):
//                                let shouldAccess = url.startAccessingSecurityScopedResource()
//                                defer {
//                                    if shouldAccess {
//                                        url.stopAccessingSecurityScopedResource()
//                                    }
//                                }
//
//                                do {
//                                    let data = try Data(contentsOf: url)
//                                    importDreamsFromJSONData(data, context: viewContext)
//                                } catch {
//                                    errorMessage = "Import error: \(error.localizedDescription)"
//                                    showError = true
//                                }
//                            case .failure(let error):
//                                errorMessage = "Import error: \(error.localizedDescription)"
//                                showError = true
//                            }
//                        }
//                    }
//                    .profileCardStyle()
//                    // Язык, FaceID, Уведомления, время
//                    VStack{
//                        HStack{
//                            Image(systemName: "globe")
//                                .font(.system(size: 16))
//                            Text("Language")
//                                .font(.system(size: 17))
//                            Spacer()
//                            Picker("Language", selection: $selectedLanguage) {
//                                Text("English").tag("en")
//                                Text("Русский").tag("ru")
//                            }
//                            .pickerStyle(MenuPickerStyle())
//                            .frame(width: 100)
//                        }
//                        FaceIDToggle()
//                        HStack {
//                            Image(systemName: "bell")
//                                .font(.system(size: 16))
//                            Text("Notifications")
//                                .font(.system(size: 17))
//                            Spacer()
//                            Toggle("", isOn: $notificationsEnabled)
//                                .labelsHidden()
//                        }
//                        if notificationsEnabled {
//                            HStack {
//                                Image(systemName: "moon")
//                                    .font(.system(size: 16))
//                                Text("Bedtime")
//                                    .font(.system(size: 17))
//                                Spacer()
//                                DatePicker("Bedtime", selection: Binding(
//                                    get: { Date(timeIntervalSince1970: bedtime) },
//                                    set: { bedtime = $0.timeIntervalSince1970 }
//                                ), displayedComponents: .hourAndMinute)
//                                .labelsHidden()
//                            }
//                            HStack {
//                                Image(systemName: "sun.max")
//                                    .font(.system(size: 16))
//                                Text("Wake-up")
//                                    .font(.system(size: 17))
//                                Spacer()
//                                DatePicker("Wake-up", selection: Binding(
//                                    get: { Date(timeIntervalSince1970: wakeUpTime) },
//                                    set: { wakeUpTime = $0.timeIntervalSince1970 }
//                                ), displayedComponents: .hourAndMinute)
//                                .labelsHidden()
//                            }
//                        }
//                            .onChange(of: notificationsEnabled) { value in
//                                if value {
//                                    requestNotificationPermission()
//                                    scheduleNotification(at: Date(timeIntervalSince1970: bedtime), identifier: "bedtime", body: "Время ложиться спать!")
//                                    scheduleNotification(at: Date(timeIntervalSince1970: wakeUpTime), identifier: "wakeUp", body: "Доброе утро! Запишите свой сон.")
//                                } else {
//                                    removeNotifications()
//                                }
//                            }
//                            .onChange(of: bedtime) { _ in
//                                if notificationsEnabled {
//                                    scheduleNotification(at: Date(timeIntervalSince1970: bedtime), identifier: "bedtime", body: "Время ложиться спать!")
//                                }
//                            }
//                            .onChange(of: wakeUpTime) { _ in
//                                if notificationsEnabled {
//                                    scheduleNotification(at: Date(timeIntervalSince1970: wakeUpTime), identifier: "wakeUp", body: "Доброе утро! Запишите свой сон.")
//                                }
//                            }
//                        HStack{
//                            Text(Bundle.localizedString(key: "SomeKey"))
//                                .font(.system(size: 16))
//                            Text("Write feedback")
//                                .font(.system(size: 17))
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                        }
//                    }
//                    .profileCardStyle()
//                    // Кнопка выхода
//                    HStack{
//                        Button(action: { showingLogoutAlert = true }) {
//                            Text("Exit")
//                                .font(.system(size: 28))
//                                .foregroundColor(.red)
//                        }
//                        .alert(isPresented: $showingLogoutAlert) {
//                            Alert(title: Text("Are you sure you want to exit?"), primaryButton: .destructive(Text("Exit")), secondaryButton: .cancel())
//                        }
//                    }
//                    // Ссылки на политику и т.д. (заглушки)
//                    HStack(spacing: 20) {
//                        Button("Privacy Policy") {}
//                        Button("Terms") {}
//                        Button("Data Deletion") {}
//                    }
//                    .font(.footnote)
//                    .foregroundColor(.blue)
//                }
//                .padding()
//            }
//            // В body, например, в .overlay или .alert:
//            .overlay {
//                if isLoading {
//                    ProgressView("Loading...")
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background(Color.black.opacity(0.3))
//                }
//            }
//            .alert("Error", isPresented: $showError) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text(errorMessage)
//            }
//            .alert("Done", isPresented: $showDone) {
//                Button("OK", role: .cancel) {}
//            } message: {
//                Text("Operation completed successfully!")
//            }
//        }
//        .onChange(of: notificationsEnabled) { value in
//            if value {
//                requestNotificationPermission()
//                scheduleNotification(at: Date(timeIntervalSince1970: bedtime), body: "Time to sleep!")
//                scheduleNotification(at: Date(timeIntervalSince1970: wakeUpTime), body: "Good morning!")
//            } else {
//                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//            }
//        }
//        .onChange(of: selectedLanguage) { lang in
//            Bundle.setLanguage(lang)
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button("Cancel") { }
//                    .foregroundColor(.purple)
//            }
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Done") { }
//                    .foregroundColor(.purple)
//                    .bold()
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .principal) {
//                Text("Profile")
//                    .font(.headline)
//                    .foregroundColor(.white)
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//    }
// 
//    private func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            // Можно обработать результат
//        }
//    }
//
//    private func scheduleNotification(at date: Date, identifier: String, body: String) {
//        let content = UNMutableNotificationContent()
//        content.title = "AIDream"
//        content.body = body
//        content.sound = .default
//
//        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
//
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request)
//    }
//
//    private func removeNotifications() {
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bedtime", "wakeUp"])
//    }
//    func exportDreamsToJSON(context: NSManagedObjectContext) -> URL? {
//        let fetchRequest: NSFetchRequest<DreamEntry> = DreamEntry.fetchRequest()
//        do {
//            let dreams = try context.fetch(fetchRequest)
//            let exportArray = dreams.map { dream in
//                [
//                    "id": dream.id?.uuidString ?? "",
//                    "content": dream.content ?? "",
//                    "date": dream.date?.ISO8601Format() ?? "",
//                    "mood": dream.mood ?? "",
//                    "tags": (dream.tags as? [String]) ?? [],
//                    "createdAt": dream.createdAt?.ISO8601Format() ?? "",
//                    "updatedAt": dream.updatedAt?.ISO8601Format() ?? ""
//                ]
//            }
//            let data = try JSONSerialization.data(withJSONObject: exportArray, options: .prettyPrinted)
//            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("DreamsBackup.json")
//            try data.write(to: tempURL)
//            return tempURL
//        } catch {
//            errorMessage = "Export error: \(error.localizedDescription)"
//            showError = true
//            return nil
//        }
//    }
//
//    func importDreamsFromJSONData(_ data: Data, context: NSManagedObjectContext) {
//        do {
//            guard let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
//                errorMessage = "Invalid file structure"
//                showError = true
//                return
//            }
//            for dict in array {
//                guard let content = dict["content"] as? String, !content.isEmpty else { continue }
//                let dream = DreamEntry(context: context)
//                dream.id = UUID(uuidString: dict["id"] as? String ?? "") ?? UUID()
//                dream.content = content
//                dream.date = ISO8601DateFormatter().date(from: dict["date"] as? String ?? "")
//                dream.mood = dict["mood"] as? String
//                dream.tags = dict["tags"] as? [String] as NSArray?
//                dream.createdAt = ISO8601DateFormatter().date(from: dict["createdAt"] as? String ?? "")
//                dream.updatedAt = ISO8601DateFormatter().date(from: dict["updatedAt"] as? String ?? "")
//            }
//            try context.save()
//            showDone = true
//        } catch {
//            errorMessage = "Import error: \(error.localizedDescription)"
//            showError = true
//        }
//    }
//    func exportDreamsToICloud(context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
//        let fetchRequest: NSFetchRequest<DreamEntry> = DreamEntry.fetchRequest()
//        do {
//            let dreams = try context.fetch(fetchRequest)
//            let exportArray = dreams.map { dream in
//                [
//                    "id": dream.id?.uuidString ?? "",
//                    "content": dream.content ?? "",
//                    "date": dream.date?.ISO8601Format() ?? "",
//                    "mood": dream.mood ?? "",
//                    "tags": (dream.tags as? [String]) ?? [],
//                    "createdAt": dream.createdAt?.ISO8601Format() ?? "",
//                    "updatedAt": dream.updatedAt?.ISO8601Format() ?? ""
//                ]
//            }
//            let data = try JSONSerialization.data(withJSONObject: exportArray, options: .prettyPrinted)
//            if let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
//                .appendingPathComponent("Documents")
//                .appendingPathComponent("DreamsBackup.json") {
//                try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
//                try data.write(to: url)
//                completion(true)
//            } else {
//                completion(false)
//            }
//        } catch {
//            print("iCloud export error:", error)
//            completion(false)
//        }
//    }
//    // --- Уведомления ---
//    private func requestNotificationPermission() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            // обработка
//        }
//    }
//    private func scheduleNotification(at date: Date, body: String) {
//        let content = UNMutableNotificationContent()
//        content.title = "AIDream"
//        content.body = body
//        content.sound = .default
//        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        UNUserNotificationCenter.current().add(request)
//    }
//}
//// --- Для смены языка ---
//extension Bundle {
//    private static var bundle: Bundle?
//
//    static func setLanguage(_ language: String) {
//        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else { return }
//        bundle = Bundle(path: path)
//    }
//
//    static func localizedString(key: String, tableName: String? = nil) -> String {
//        bundle?.localizedString(forKey: key, value: nil, table: tableName) ??
//        NSLocalizedString(key, tableName: tableName, comment: "")
//    }
//}
//struct URLDocument: FileDocument {
//    static var readableContentTypes: [UTType] { [.json] }
//    var url: URL
//
//    init(url: URL) { self.url = url }
//    init(configuration: ReadConfiguration) throws { fatalError() }
//    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//        try FileWrapper(url: url)
//    }
//}
//extension View {
//    func profileCardStyle() -> some View {
//        self
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.customSecondaryBackground)
//            .cornerRadius(17)
//    }
//}
