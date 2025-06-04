//import SwiftUI
//
//struct DreamInterpretationView: View {
//    let interpretation: DreamInterpretation
//    @Environment(\.dismiss) private var dismiss
//    @State private var rating: Int = 0
//    @StateObject private var viewModel = DreamCreationViewModel()
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 24) {
//                    // Краткое резюме
//                    InterpretationSection(
//                        title: "Краткое резюме",
//                        content: interpretation.summary
//                    )
//                    
//                    // Символы
//                    InterpretationSection(
//                        title: "Символы и их значение",
//                        content: interpretation.symbols.map { "• \($0.symbol): \($0.meaning)" }.joined(separator: "\n")
//                    )
//                    
//                    // Эмоциональный анализ
//                    InterpretationSection(
//                        title: "Эмоциональный анализ",
//                        content: interpretation.emotionalAnalysis
//                    )
//                    
//                    // Рекомендации
//                    InterpretationSection(
//                        title: "Рекомендации",
//                        content: interpretation.recommendations.map { "• \($0)" }.joined(separator: "\n")
//                    )
//                    
//                    // Оценка интерпретации
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Насколько точна интерпретация?")
//                            .font(.headline)
//                        
//                        HStack {
//                            ForEach(1...5, id: \.self) { index in
//                                Image(systemName: index <= rating ? "star.fill" : "star")
//                                    .foregroundColor(.dreamPrimary)
//                                    .font(.title2)
//                                    .onTapGesture {
//                                        rating = index
//                                    }
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(12)
//                }
//                .padding()
//            }
//            .navigationTitle("Интерпретация сна")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Готово") {
//                        Task {
//                            await viewModel.saveDream(interpretation: interpretation)
//                            dismiss()
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct InterpretationSection: View {
//    let title: String
//    let content: String
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(title)
//                .font(.headline)
//            
//            Text(content)
//                .font(.body)
//                .foregroundColor(.primary)
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//    }
//} 
