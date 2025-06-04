import SwiftUI

struct DreamCard: View {
    let dream: DreamEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(dream.date?.formatted(date: .abbreviated, time: .shortened) ?? "")
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
            
            Text(dream.interpretationValue?.summary ?? (dream.content?.prefix(50) ?? ""))
                .font(.headline)
                .lineLimit(2)
            
            if let tags = dream.tags as? [String], !tags.isEmpty {
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
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
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
    
    return DreamCard(dream: dream)
        .padding()
        .previewLayout(.sizeThatFits)
} 