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
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.appGray4
                .ignoresSafeArea()  
            
            VStack(spacing: 12) {
                headerUI(dreamDate: $viewModel.selectedDate)
                
                dreamTextEditor($viewModel.dreamText)
                
                microphoneButton {
                    Task {
                        await viewModel.toggleRecording()
                    }
                }
                
                moodPicker($viewModel.selectedMood)

                Spacer()
                
                DButton(title: "Generate Dream", isDisabled: $viewModel.isButtonDisabled) {
                    print("Generate dream button pressed")
                }
            }
            .padding(.horizontal, 16)
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
        .onChange(of: viewModel.isRecording) { old, isRecording in
            if !isRecording {
                viewModel.updateDreamText()
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
    
    func headerUI(dreamDate date: Binding<Date>) -> some View {
        HStack(spacing: 8) {
            DatePicker(selection: date) {
                Text("Describe the dream")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .foregroundColor(.white)
            }
            .tint(Color.appPurple)
            .font(.headline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appGray1)
            .cornerRadius(12)
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
