//
// ChatView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
//


import SwiftUI

struct ChatView: View {
    
    @StateObject private var chatViewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var textHeight: CGFloat = 48
    
    
    init(with interpretation: Interpretation) {
        self._chatViewModel = StateObject(wrappedValue: ChatViewModel(interpretation: interpretation))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        quickQuestionsView
                        MessageCellView(text: String(localized: "chatFirstMessage"), isResponse: true)
                            .messageAlignment(isResponse: true)
                        ForEach(chatViewModel.messages) { message in
                            let isResponse = message.role == "assistant"
                            MessageCellView(
                                text: message.text,
                                isResponse: isResponse)
                            .messageAlignment(isResponse: isResponse)
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .onChange(of: chatViewModel.messages) { _ in
                    if let last = chatViewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
                .navigationTitle("aIChat")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
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
                MessageInputView(
                    messageText: $chatViewModel.messageText,
                    textHeight: $textHeight
                ) { text in
                    Task {
                        await chatViewModel.sendMessageToAIChat(text)
                    }
                }
                .frame(height: textHeight)
                .padding(.horizontal, 16)
            }
        }
        .background {
            Color.appPurpleDark.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

private extension ChatView {
    var quickQuestionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(chatViewModel.interpretation.chatQuestions, id: \.self) { question in
                    questionView(question)
                        .onTapGesture {
                            Task {
                                await chatViewModel.sendMessageToAIChat(question)
                            }
                        }
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
