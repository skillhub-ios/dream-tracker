import SwiftUI
extension Color {
    static let customBackground = Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
    static let customSecondaryBackground = Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255)
    static let customGrayOverlay = Color(red: 120 / 255, green: 120 / 255, blue: 128 / 255, opacity: 0.36)
    static let customLightGray = Color(red: 235 / 255, green: 235 / 255, blue: 245 / 255, opacity: 0.6)
    static let dreamyBackground = Color(red: 38/255, green: 26/255, blue: 44/255).opacity(0.75)
    static let custonPurpleBackground = Color(UIColor(red: 56/255, green: 42/255, blue: 64/255, alpha: 0.75))

}
struct DreamCard: View {
    let dream: DreamEntry
    let interpretation: DreamInterpretation
    
    var body: some View {
        //        VStack(alignment: .leading, spacing: 12) {
        HStack{
            VStack{
                Text(getMoodEmoji(for: dream.mood ?? ""))
                    .font(.system(size: 22))
                    .frame(width: 54, height: 54)
                    .background(Color(red: 1.0, green: 0.41, blue: 0.38, opacity: 0.5))
                    .cornerRadius(27)
            }
            VStack(alignment: .leading, spacing: 12) {
                HStack{
                    Text(dream.content ?? "Нет данных")
                        .font(.system(size: 20))
                        .lineLimit(1)
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                }
                HStack(spacing: 8) {
                    ForEach(interpretation.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.customGrayOverlay)
                            .cornerRadius(8)
                    }
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(formattedDate(from: dream.date))
                        .font(.system(size: 14))
                        .foregroundColor(.customLightGray)
                }
                HStack {
                    Text(formattedTime(from: dream.date))
                        .font(.subheadline)
                        .foregroundColor(.customLightGray)
                }
            }
          }
        .padding()
        .frame(maxWidth: .infinity) // <<< растягиваем карточку на всю ширину
        .background(Color.customSecondaryBackground)
        .cornerRadius(12)
        .shadow(radius: 2)
         
    }
    
    
    func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "Нет даты" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yyyy"
        return formatter.string(from: date)
    }
    
    func formattedTime(from date: Date?) -> String {
        guard let date = date else { return "Нет времени" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func getMoodEmoji(for mood: String) -> String {
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
struct DreamLastCard: View {
    
    let dream: DreamEntry
    let interpretation: DreamInterpretation
    var body: some View {
        HStack(spacing: 5){
            Text(getMoodEmoji(for: dream.mood ?? ""))
                .font(.system(size: 11))
                .frame(width: 26, height: 26)
                .background(Color(red: 1.0, green: 0.41, blue: 0.38, opacity: 0.5))
                .cornerRadius(15)
            Text(formattedDate(from: dream.date))
                .font(.system(size: 12))
                .foregroundColor(.customLightGray)
            Text("•")
                .font(.system(size: 12))
                .foregroundColor(.customLightGray)
            Text(formattedTime(from: dream.date))
                .font(.system(size: 12))
                .foregroundColor(.customLightGray)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.dreamyBackground)
        .cornerRadius(60)
    }
    func formattedDate(from date: Date?) -> String {
        guard let date = date else { return "Нет даты" }
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yyyy"
        return formatter.string(from: date)
    }
    
    func formattedTime(from date: Date?) -> String {
        guard let date = date else { return "Нет времени" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    private func getMoodEmoji(for mood: String) -> String {
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
