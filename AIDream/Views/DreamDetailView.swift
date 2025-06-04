import SwiftUI

struct DreamDetailView: View {
    let dream: DreamEntry
    @State private var showingInterpretation = false
    @State private var showingDeleteAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Дата и настроение
                HStack {
                    Text(dream.date?.formatted(date: .long, time: .shortened) ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(dream.mood ?? "")
                        .font(.subheadline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.1))
                        .foregroundColor(.accentColor)
                        .cornerRadius(8)
                }
                
                // Содержание сна
                VStack(alignment: .leading, spacing: 12) {
                    Text("Содержание сна")
                        .font(.headline)
                    
                    Text(dream.content ?? "")
                        .font(.body)
                }
                
                // Теги
                if let tags = dream.tags as? [String], !tags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Теги")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // Интерпретация
                if let interpretation = dream.interpretationValue {
                    VStack(alignment: .leading, spacing: 16) {
                        Button(action: { showingInterpretation.toggle() }) {
                            HStack {
                                Text(showingInterpretation ? "Скрыть интерпретацию" : "Показать интерпретацию")
                                    .font(.headline)
                                Image(systemName: showingInterpretation ? "chevron.up" : "chevron.down")
                            }
                            .foregroundColor(.accentColor)
                        }
                        
                        if showingInterpretation {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Интерпретация сна")
                                    .font(.title2).bold()
                                
                                Text(interpretation.summary)
                                    .font(.body)
                                
                                if !interpretation.tags.isEmpty {
                                    HStack {
                                        ForEach(interpretation.tags, id: \.self) { tag in
                                            Text(tag)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.purple.opacity(0.15))
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                
                                DisclosureGroup("Толкование") {
                                    Text(interpretation.interpretation)
                                }
                                
                                DisclosureGroup("Реальные размышления") {
                                    Text(interpretation.reflection)
                                }
                                
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text(interpretation.quote)
                                }
                                .foregroundColor(.purple)
                                .padding(.vertical, 8)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                } else {
                    Button(action: { showingInterpretation = true }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Интерпретировать сон")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Детали сна")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Удалить", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .alert("Удалить сон?", isPresented: $showingDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                deleteDream()
            }
        } message: {
            Text("Это действие нельзя отменить")
        }
    }
    
    private func deleteDream() {
        viewContext.delete(dream)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Ошибка при удалении сна: \(error)")
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let dream = DreamEntry(context: context)
    dream.id = UUID()
    dream.content = "Я летал над городом и видел все здания с высоты птичьего полета."
    dream.date = Date()
    dream.mood = "Счастливый"
    dream.tags = ["Полёт", "Город"]
    dream.createdAt = Date()
    dream.updatedAt = Date()
    
    return NavigationView {
        DreamDetailView(dream: dream)
    }
} 