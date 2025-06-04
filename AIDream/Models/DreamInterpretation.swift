import Foundation

struct DreamInterpretation: Codable {
    let title: String
    let summary: String
    let symbols: [DreamSymbol]
    let emotionalAnalysis: String
    let recommendations: [String]
    let tags: [String]
    let quote: String

    struct DreamSymbol: Codable {
        let symbol: String
        let meaning: String
    }
}

extension DreamInterpretation {
    static var preview: DreamInterpretation {
        DreamInterpretation(
            title: "Полет к свободе",
            summary: "Сон о полете символизирует свободу и стремление к независимости",
            symbols: [
                DreamSymbol(symbol: "🦋", meaning: "Трансформация"),
                DreamSymbol(symbol: "🌙", meaning: "Подсознание"),
                DreamSymbol(symbol: "⭐", meaning: "Надежда")
            ],
            emotionalAnalysis: "Сон отражает ваше желание освободиться от ограничений",
            recommendations: [
                "Практикуйте медитацию",
                "Ведите дневник снов"
            ],
            tags: ["Lucid Dream", "Creative Dream"],
            quote: "Сны - это королевская дорога к бессознательному. — Зигмунд Фрейд"
        )
    }
} 
