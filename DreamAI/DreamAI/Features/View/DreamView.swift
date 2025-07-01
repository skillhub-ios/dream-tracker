//
//  DreamView.swift
//  DreamAI
//
//  Created by Shaxzod on 01/07/25.
//

import SwiftUI

struct DreamView: View {
    
    // MARK: - Properties
    @EnvironmentObject var viewModel: DreamViewModel
    @EnvironmentObject var interpretationViewModel: DreamInterpretationViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputActive: Bool
    @State private var isShowingInterpretation: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.appGray4
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        headerUI(dreamDate: viewModel.dream.date)
                        
                        dreamTextEditor($viewModel.dreamText)
                        //
                        moodPicker($viewModel.mood)
                        
                        Spacer()
                        
                        DButton(title: "Generate Dream", state: $viewModel.buttonState) {
                            if UserManager.shared.isSubscribed {
                                Task {
                                    await MainActor.run {
                                        interpretationViewModel.updateDreamData(
                                            UserCredential(
                                                dreamText: viewModel.dreamText,
                                                selectedMood: viewModel.mood
                                            )
                                        )
                                        self.isShowingInterpretation = true
                                    }
                                }
                            } else {
                                // TODO: - Show SubscribeView
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationTitle("View Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelNavigationButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneNavigationButton()
                }
            }
            .sheet(isPresented: $isShowingInterpretation) {
                DreamInterpretationView()
                    .environmentObject(interpretationViewModel)
            }
        }
        .onChange(of: isShowingInterpretation) {
            if !isShowingInterpretation {
                dismiss()
            }
        }
    }
}

// MARK: - Private

private extension DreamView {
    
    func dreamTextEditor(_ dreamText: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if dreamText.wrappedValue.isEmpty {
                Text("I dreamed...")
                    .font(.system(size: 17))
                    .foregroundStyle(Color.gray)
                    .padding(.top, 10)
                    .padding(.leading, 5)
            }
            
            TextEditor(text: dreamText)
                .font(.system(size: 17))
                .focused($isInputActive)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        
                        Button("Done") {
                            isInputActive = false
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundStyle(Color.appWhite)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .frame(height: SCREEN_HEIGHT * 0.3)
        .background(Color.appGray3)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func headerUI(dreamDate date: Date) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            Text("Describe the dream")
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 18))
                    .foregroundColor(.gray)
                
                Text(date.formatted(date: .abbreviated, time: .omitted) + " • " + date.formatted(date: .omitted, time: .shortened))
                    .font(.body)
                    .foregroundColor(Color.appGray5)
            }
            .underline()
            .fixedSize(horizontal: true, vertical: false)
            .padding(.top, 12)
        }
    }
    
    func moodPicker(_ selectedMood: Binding<Mood?>) -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood before sleep")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.appWhite)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: 10) {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button(action: {
                            withAnimation {
                                selectedMood.wrappedValue = mood
                            }
                        }) {
                            VStack {
                                Text(mood.emoji)
                                    .font(.system(size: 28))
                                    .padding(10)
                                    .background(selectedMood.wrappedValue == mood ?  Color.appPurple : Color.appGray7.opacity(0.35))
                                    .clipShape(.circle)
                                
                                Text(mood.rawValue)
                                    .font(.caption2)
                                    .foregroundStyle(Color.appWhite)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
            }
            .background(Color.appGray3)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
    
    func cancelNavigationButton() -> some View {
        Button(action: {
            dismiss()
        }) {
            Text("Cancel")
                .foregroundColor(.appPurple)
        }
    }
    
    func doneNavigationButton() -> some View {
        Button(action: {
            dismiss()
        }) {
            Text("Done")
                .foregroundColor(.appPurple)
        }
    }
}

private struct LeftImageLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            configuration.title
            configuration.icon
        }
    }
}


#Preview {
    
    @Previewable @State var dream: Dream = Dream(
        emoji: "🌙",
        emojiBackground: .appPurple,
        title: "Dream",
        tags: [.nightmare],
        date: Date(),
        userCredential: UserCredential(
            dreamText: "I dreamed about a big red dragon, flying in the sky and breathing fire. I was scared and ran away. ",
            selectedMood: .happy
        )
    )
    
    NavigationStack {
        DreamView()
            .environmentObject(DreamViewModel(dream: dream))
            .environmentObject(DreamInterpretationViewModel(dream: dream))
    }
    .colorScheme(.dark)
}
