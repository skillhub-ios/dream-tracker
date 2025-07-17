//
// ChatView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
//


import SwiftUI

struct ChatView: View {
    
    @StateObject private var chatViewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    init(with interpretation: Interpretation) {
        self._chatViewModel = StateObject(wrappedValue: ChatViewModel(interpretation: interpretation))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 24) {
                    quickQuestionsView
                    MessageCellView(text: String(localized: "chatFirstMessage"), isResponse: true)
                        .messageAlignment(isResponse: true)
                    MessageCellView(text: String(localized: "chatFirstMessage"), isResponse: false)
                        .messageAlignment(isResponse: false)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("aIChat")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .background {
                Color.appPurpleDark.opacity(0.75)
                    .edgesIgnoringSafeArea(.all)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("сancel")
                            .foregroundColor(.appPurple)
                    }
                }
            }
            MessageInputView()
                .padding(.horizontal, 16)
        }
    }
}

private extension ChatView {
    var quickQuestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(chatViewModel.interpretation.chatQuestions, id: \.self) {
                    questionView($0)
                }
            }
        }
    }
    
    func questionView(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color.appPurpleDarkBackground.opacity(0.75))
            }
    }
}

#Preview {
    NavigationView {
        ChatView(with: dreamInterpretationFullModel)
    }
}
