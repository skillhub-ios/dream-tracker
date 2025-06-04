import SwiftUI
import Speech
 // import AIDream.Views.ChatView

struct DreamCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DreamCreationViewModel()
    @State private var interpretation: DreamInterpretation? = nil
    @State private var dreamDate: Date = Date()
    @State private var isInterpreted = false
    @Namespace private var animation
    @State private var date: Date = Date()
    @State private var showPicker = false
    
    var body: some View {
        ZStack {
                ScrollView {
                    VStack(spacing: 24) {
                        // Описание сна
                        VStack(alignment: .leading, spacing: 8) {
                            HStack{
                                Text("Describe the dream")
                                    .font(.headline)
                                    .foregroundStyle(Color.white)
                                Spacer()
                                Image(systemName: "calendar")
                                                .foregroundColor(.gray)
                                            
                                            Button(action: { showPicker = true }) {
                                                HStack(spacing: 6) {
                                                    Text(dateFormatted(date, format: "d.MM.yyyy"))
                                                    Text("•")
                                                    Text(dateFormatted(date, format: "HH:mm"))
                                                }
                                                .underline()
                                                .foregroundColor(.white)
                                                .font(.system(size: 16, weight: .regular))
                                            }
                                            .sheet(isPresented: $showPicker) {
                                                VStack {
                                                    DatePicker("Select Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                                        .datePickerStyle(.graphical)
                                                        .padding()
                                                    Button("Done") {
                                                        showPicker = false
                                                    }
                                                    .padding()
                                                }
                                            }
                             }
                            
                            ZStack(alignment: .topLeading) {
                                if viewModel.dreamContent.isEmpty {
                                    Text("I dreamed…")
                                        .foregroundColor(.gray)
                                        .padding(12)
                                }
                                TextEditor(text: $viewModel.dreamContent)
                                    .padding(8)
                                    .frame(minHeight: 300)
                                    .background(Color.customSecondaryBackground)
                                    .cornerRadius(12)
                                    .scrollContentBackground(.hidden)
                            }
                            Button(action: {
                                viewModel.isRecording ? viewModel.stopRecording() : viewModel.startRecording()
                            }) {
                                HStack {
                                    Text(viewModel.isRecording ? "Stop Recording" : "Use Microphone")
                                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")

                                }
                                .foregroundColor(Color.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.customSecondaryBackground)
                            .cornerRadius(12)

                        }
 
                         VStack(alignment: .leading, spacing: 8) {
                            Text("Mood before sleep")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(Mood.allCases, id: \.self) { mood in
                                        Button(action: { viewModel.selectedMood = mood }) {
                                            VStack{
                                                VStack {
                                                    Text(mood.emoji)
                                                        .font(.largeTitle)
                                                }
                                                .frame(width: 60, height: 70)
                                                .background(
                                                    Circle()
                                                        .fill(viewModel.selectedMood == mood ? Color.purple : Color.customGrayOverlay)
                                                )
                                                Text(mood.name)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            }
                                             
                                        }
                                    }
                                }
                                 
                            }
                            .padding()
                            .background(Color.customSecondaryBackground)
                            .cornerRadius(20)
                        }
                        // Кнопка интерпретации
                        Button(action: interpretDream) {
                            HStack {
                                 Text("Interpret Dream")
                                Image(systemName: "sparkles")

                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((viewModel.dreamContent.isEmpty || viewModel.selectedMood == nil) ? Color.gray.opacity(0.3) : Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.dreamContent.isEmpty || viewModel.selectedMood == nil)
                        .padding(.top, 16)
                    }
                    
                    .padding()
                }
                
                .background(Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255).ignoresSafeArea())
                .transition(.opacity)
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { dismiss() }
                    .foregroundColor(.purple) // Цвет кнопки Cancel
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    Task {
                        await viewModel.saveDream(interpretation: interpretation)
                        dismiss()
                    }
                }
                .foregroundColor(.purple) // Цвет кнопки Cancel
                .bold()
                .disabled(viewModel.dreamContent.isEmpty)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Dream")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isInterpreted) {
            if let interpretation = interpretation {
                DreamInterpretationScreen(
                    interpretation: interpretation,
                    onDone: {
                        isInterpreted = false
                    },
                    viewModel: viewModel
                )
            }
        }
        .animation(.easeInOut, value: isInterpreted)
        .alert("Ошибка", isPresented: $viewModel.showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Неизвестная ошибка")
        }
    }
    func dateFormatted(_ date: Date, format: String) -> String {
           let formatter = DateFormatter()
           formatter.dateFormat = format
           return formatter.string(from: date)
       }
    func interpretDream() {
        Task {
            do {
                let result = try await viewModel.openAIService.interpretDream(viewModel.dreamContent)
                withAnimation {
                    self.interpretation = result
                    self.isInterpreted = true
                }
            } catch {
                viewModel.error = error
                viewModel.showingError = true
            }
        }
    }
}

struct MoodType: Identifiable, Equatable {
    let id = UUID()
    let emoji: String
    let name: String
}

struct CustomMoodView: View {
    var onSave: (MoodType) -> Void
    @State private var emoji: String = ""
    @State private var name: String = ""
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DreamCreationViewModel()
    @State private var customMood: MoodType? = nil
    @State private var interpretation: DreamInterpretation? = nil
    var body: some View {
        NavigationView {
            Form {
                TextField("Emoji", text: $emoji)
                TextField("Name", text: $name)
            }
            .navigationTitle("Custom Mood")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Сохранить") {
//                        Task {
//                            await viewModel.saveDream(interpretation: interpretation)
//                            dismiss()
//                        }
//                    }
//                    .disabled(viewModel.dreamContent.isEmpty)
//                }
//            }
        }
    }
}

struct DreamInterpretationScreen: View {
    let interpretation: DreamInterpretation
    var onDone: () -> Void
    @State private var resonance: Int? = nil
    @ObservedObject var viewModel: DreamCreationViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack{
            Color(UIColor(red: 35/255, green: 24/255, blue: 40/255, alpha: 1))
                     .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Text(interpretation.title)
                    .font(.system(size: 22))
                     .foregroundColor(.purple)
                HStack{
                    Text(interpretation.summary)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.custonPurpleBackground)
                .cornerRadius(16)
                HStack{
                    VStack{
                        ForEach(interpretation.symbols, id: \.symbol) { symbol in
                            HStack(spacing: 4) {
                                Text(symbol.symbol)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(symbol.meaning)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
 
                    }
                    .padding()
                    .background(Color.custonPurpleBackground)
                    .cornerRadius(16)
                    VStack{
                        ForEach(interpretation.symbols, id: \.symbol) { symbol in
                            HStack(spacing: 4) {
                                Text(symbol.symbol)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(symbol.meaning)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                      }
                    .padding()
                    .background(Color.custonPurpleBackground)
                    .cornerRadius(16)

                }
                 HStack {
                    VStack(alignment: .leading, spacing: 10) {
                                Text("🧠  Interpretation")
                                    .font(.system(size: 17))
                                    .bold()
                                    .foregroundColor(.white)
                        Text(interpretation.emotionalAnalysis)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.custonPurpleBackground)

                        .cornerRadius(16)
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                                Text("🔍  Real reflections")
                                    .font(.system(size: 17))
                                    .bold()
                                    .foregroundColor(.white)
                        Text(interpretation.recommendations.joined(separator: "\n"))
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.custonPurpleBackground)
                        .cornerRadius(16)
                HStack{
                    Text(interpretation.quote)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.custonPurpleBackground)
                .cornerRadius(16)
                Text("Did this resonate with you?")
                    .foregroundColor(.white)
                HStack{
                    
                }
                Button(action: {
                    Task {
                        await viewModel.saveDream(interpretation: interpretation)
                        dismiss()
                        onDone()
                    }
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.custonPurpleBackground)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
 //               Text(interpretation.emotionalAnalysis)
//                   .font(.title).bold()
//                   .foregroundColor(.white)
//               Text(interpretation.summary)
//                   .font(.body)
//                   .foregroundColor(.white.opacity(0.9))
//               
//               // Отображаем символы из сна
//               ForEach(interpretation.symbols, id: \.symbol) { symbol in
//                   VStack(alignment: .leading, spacing: 4) {
//                       Text(symbol.symbol)
//                           .font(.headline)
//                           .foregroundColor(.white)
//                       Text(symbol.meaning)
//                           .font(.subheadline)
//                           .foregroundColor(.white.opacity(0.8))
//                   }
//                   .padding(.vertical, 4)
//               }
//               
//               DisclosureGroup("Interpretation") {
//                   Text(interpretation.emotionalAnalysis)
//                       .foregroundColor(.white)
//               }
//               .accentColor(.white)
//               
//               DisclosureGroup("Real reflections") {
//                   Text(interpretation.emotionalAnalysis)
//                       .foregroundColor(.white)
//               }
//               .accentColor(.white)
//               
//               HStack {
//                   Image(systemName: "sparkles")
//                   Text(interpretation.emotionalAnalysis)
//               }
//               .foregroundColor(.yellow)
//               .padding(.vertical, 8)
//               
//               Text("Did this resonate with you?")
//                   .foregroundColor(.white)
//               
//               Button(action: {
//                   Task {
//                       await viewModel.saveDream(interpretation: interpretation)
//                       dismiss()
//                       onDone()
//                   }
//               }) {
//                   Text("Done")
//                       .frame(maxWidth: .infinity)
//                       .padding()
//                       .background(Color.white)
//                       .foregroundColor(.purple)
//                       .cornerRadius(12)
//               }
//               .padding(.top)
           }
           .padding()
        }
         
     }
}
 
extension Color {
    static let borderOverlay = Color(red: 56 / 255, green: 42 / 255, blue: 64 / 255).opacity(0.75)

    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
