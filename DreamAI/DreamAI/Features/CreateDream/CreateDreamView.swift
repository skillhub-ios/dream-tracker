//
//  CreateDreamView.swift
//  DreamAI
//
//  Created by Shaxzod on 11/06/25.
//

import SwiftUI

struct CreateDreamView: View {
    
    // MARK: - Properties
    @StateObject private var viewModel = CreateDreamViewModel()
    @EnvironmentObject private var subscriptionViewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputActive: Bool
    @State private var isShowingInterpretation: Bool = false
    @State private var interpretationModel: Interpretation?
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appGray4
                .ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    DreamDateView(date: $viewModel.selectedDate, isCreating: true)
                        dreamTextEditor($viewModel.dreamText)
                        microphoneButton {
                            Task {
                                await viewModel.toggleRecording()
                            }
                        }
                        moodPicker($viewModel.selectedMood)
                    
                    Spacer()
                    
                    DButton(title: "Interpret Dream", isDisabled: $viewModel.isButtonDisabled) {
                        if subscriptionViewModel.isSubscribed {
                            viewModel.createDream()
                            isShowingInterpretation = true
                        } else {
                            subscriptionViewModel.showPaywall()
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("Create Dream")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                cancelNavigationButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                doneNavigationButton()
            }
        }
        .alert("Permission Required", isPresented: $viewModel.showPermissionAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.permissionAlertMessage)
        }
        .onChange(of: isShowingInterpretation) {
            if !isShowingInterpretation {
                dismiss()
            }
        }
        .sheet(isPresented: $isShowingInterpretation) {
            if let dream = viewModel.currentDream {
                DreamInterpretationView(dream: dream)
            }
        }
    }
}

// MARK: - Private

private extension CreateDreamView {
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
        .background(Color.appGray1)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    func microphoneButton(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(viewModel.isRecording ? "Stop Recording" : "Use Microphone", systemImage: viewModel.isRecording ? "stop.circle.fill" : "microphone.fill")
                .labelStyle(LeftImageLabel())
                .font(.system(size: 17))
                .foregroundStyle(Color.appWhite)
                .frame(height: 25)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(viewModel.isRecording ? Color.appRed : Color.appGray1)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
            .background(Color.appGray1)
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
            if !viewModel.dreamText.isEmpty {
                viewModel.createDream()
            }
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
    NavigationStack {
        CreateDreamView()
    }
    .colorScheme(.dark)
}
