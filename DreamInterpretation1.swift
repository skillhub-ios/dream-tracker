//import Foundation
//
//struct DreamInterpretation: Codable {
//    let summary: String
//    let symbols: [DreamSymbol]
//    let emotionalAnalysis: String
//    let recommendations: String
//    let tags: [String] // ← добавьте это поле для тегов
//
//    struct DreamSymbol: Codable {
//        let symbol: String
//        let meaning: String
//    }
//}
//
//extension DreamInterpretation {
//    static var preview: DreamInterpretation {
//        DreamInterpretation(
//            summary: "Ваш сон о полете символизирует свободу и стремление к новым высотам в жизни. Это может указывать на ваше желание освободиться от ограничений и достичь большего.",
//            symbols: [
//                DreamSymbol(
//                    symbol: "🐍",
//                    meaning: "Hidden fears"
//                ),
//                DreamSymbol(
//                    symbol: "🪞",
//                    meaning: "Self-reflection"
//                )
//            ],
//            emotionalAnalysis: "Сон вызывает положительные эмоции, связанные с чувством свободы и возможностей. Это может указывать на ваш оптимистичный настрой и готовность к переменам.",
//            recommendations:
//                "Рассмотрите возможность новых начинаний в карьере или личной жизни",
//            tags: ["Daydream", "Creative Dream"] // ← добавьте этот параметр
//        )
//    }
//} 
