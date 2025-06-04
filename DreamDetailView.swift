import SwiftUI

struct DreamDetailView: View {
    let dream: DreamEntry
    @State private var showingInterpretation = false
    @State private var showingDeleteAlert = false
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var dreamText: String = ""

    @State private var showInterpretation = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Описание сна
                    VStack(alignment: .leading, spacing: 8) {
                        HStack{
                            Text("Your Dream")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                            Spacer()
                            Text(dream.date?.formatted(date: .long, time: .shortened) ?? "")
                                .foregroundStyle(Color.white)
                            
                        }
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $dreamText)
                                .foregroundStyle(Color.white)
                                .padding(8)
                                .frame(minHeight: 300)
                                .background(Color.customSecondaryBackground)
                                .cornerRadius(12)
                                .scrollContentBackground(.hidden)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mood before sleep")
                            .font(.headline)
                            .foregroundStyle(Color.white)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                        Text(dream.mood ?? "")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.white)
                             }
                        }
                        
                    }
                    .padding()
                    .background(Color.customSecondaryBackground)
                    .cornerRadius(20)
                }
                if let interpretation = dream.interpretationValue {
                    Button(action: {
                        showInterpretation = true
                    }) {
                        HStack {
                            Text("Show Interpret")
                            Image(systemName: "sparkles")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .sheet(isPresented: $showInterpretation) {
                        DreamInterpretationScreen(
                            interpretation: interpretation,
                            onDone: {},
                            viewModel: DreamCreationViewModel()
                        )
                    }
                    }
                    
//                    .padding(.top, 16)
                }
                // Кнопка интерпретации
                
            }
            
            .padding()
            .onAppear {
                dreamText = dream.content ?? ""
            }
            .background(Color(red: 28 / 255, green: 28 / 255, blue: 30 / 255)
            .ignoresSafeArea())
            .transition(.opacity)

        }
 
    }
//  
//import SwiftUI
//
//struct DreamDetailView: View {
//    let dream: DreamEntry
//    @State private var showingDeleteAlert = false
//    @Environment(\.managedObjectContext) private var viewContext
//    @Environment(\.dismiss) private var dismiss
//    @State private var dreamText: String = ""
//    @State private var showInterpretation = false
//    @StateObject private var viewModel = DreamCreationViewModel()
//    @State private var interpretation: DreamInterpretation? = nil
//
//    var body: some View {
//        ZStack {
//            ScrollView {
//                VStack(spacing: 24) {
//                    // Описание сна
//                    VStack(alignment: .leading, spacing: 8) {
//                        HStack {
//                            Text("Your Dream")
//                                .font(.headline)
//                                .foregroundStyle(.white)
//                            Spacer()
//                            Text(dream.date?.formatted(date: .long, time: .shortened) ?? "")
//                                .foregroundStyle(.white)
//                        }
//
//                        TextEditor(text: $dreamText)
//                            .foregroundStyle(.white)
//                            .padding(8)
//                            .frame(minHeight: 300)
//                            .background(Color.customSecondaryBackground)
//                            .cornerRadius(12)
//                            .scrollContentBackground(.hidden)
//                    }
//
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Mood before sleep")
//                            .font(.headline)
//                            .foregroundStyle(.white)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 16) {
//                                Text(dream.mood ?? "")
//                                    .font(.largeTitle)
//                            }
//                        }
//                    }
//                    .padding()
//                    .background(Color.customSecondaryBackground)
//                    .cornerRadius(20)
//
//                    if let existingInterpretation = dream.interpretationValue {
//                        Button(action: {
//                            interpretation = existingInterpretation
//                            showInterpretation = true
//                        }) {
//                            HStack {
//                                Text("Show Interpretation")
//                                Image(systemName: "sparkles")
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.gray)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                        }
//                    } else {
//                        Button(action: interpretDream) {
//                            HStack {
//                                Text("Interpret Dream")
//                                Image(systemName: "sparkles")
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.purple)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding()
//            }
//        }
//        .onAppear {
//            dreamText = dream.content ?? ""
//        }
//        .sheet(isPresented: $showInterpretation) {
//            if let interpretation = interpretation {
//                DreamInterpretationScreen(
//                    interpretation: interpretation,
//                    onDone: {
//                        showInterpretation = false
//                    },
//                    viewModel: viewModel
//                )
//            }
//        }
//        .alert("Ошибка", isPresented: $viewModel.showingError) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(viewModel.error?.localizedDescription ?? "Неизвестная ошибка")
//        }
//    }
//
//    func interpretDream() {
//        Task {
//            do {
//                let result = try await viewModel.openAIService.interpretDream(dreamText)
//                self.interpretation = result
//                self.showInterpretation = true
//            } catch {
//                viewModel.error = error
//                viewModel.showingError = true
//            }
//        }
//    }
//}
