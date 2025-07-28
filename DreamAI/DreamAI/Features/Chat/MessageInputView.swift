//
// MessageInputView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
//

import SwiftUI

struct MessageInputView: View {
    
    @Binding var messageText: String
    @Binding var textHeight: CGFloat
    var onSendAction: (String) -> Void
    
    private let minHeight: CGFloat = 48
    private let maxHeight: CGFloat = 96
    private let cornerRadius: CGFloat = 50
    
    var body: some View {
        // Основной контейнер с фиксированной высотой
        ZStack {
            // Фон
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(LinearGradient.appPurpleHorizontal, lineWidth: 1)
                .fill(Color.appPurpleDarkBackground.opacity(0.75))
            
            // Содержимое внутри фона
            HStack(spacing: 12) {
                // Текстовое поле
                ZStack(alignment: .topLeading) {
                    // Placeholder
                    if messageText.isEmpty {
                        Text("aiChatMessagePlaceholder")
                            .foregroundColor(.appPurpleDarkStroke)
                            .padding(.top, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    // Текстовый редактор
                    TextEditor(text: $messageText)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .font(.system(size: 16))
                        .frame(minHeight: 32)
                        .onChange(of: messageText) { _ in
                            updateHeight()
                        }
                }
                // Кнопка
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(LinearGradient.appPurpleHorizontal)
                }
                .disabled(messageText.isEmpty)
                .frame(width: 32, height: 32)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(height: textHeight) // Фиксируем высоту всего контейнера
        .onAppear {
            updateHeight()
        }
    }
    
    private func updateHeight() {
        let textSize = messageText.boundingRect(
            with: CGSize(width: UIScreen.main.bounds.width - 100, height: .infinity),
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        )
        
        let newHeight = max(minHeight, min(textSize.height + 32, maxHeight))
        
        withAnimation(.easeInOut(duration: 0.1)) {
            textHeight = newHeight
        }
    }
    
    private func sendMessage() {
        let textToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToSend.isEmpty else { return }

        onSendAction(textToSend)
        messageText = ""
        textHeight = minHeight
    }
}

#Preview {
    VStack {
        MessageInputView(
            messageText: .constant(""),
            textHeight: .constant(48),
            onSendAction: {_ in })
        MessageInputView(
            messageText: .constant("Chat message"),
            textHeight: .constant(48),
            onSendAction: {_ in })
    }
    .padding()
}
