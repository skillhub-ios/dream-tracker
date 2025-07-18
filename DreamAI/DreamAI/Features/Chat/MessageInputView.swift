//
// MessageInputView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
//

import SwiftUI

struct MessageInputView: View {
    @State private var messageText = ""
    @State private var textHeight: CGFloat = 48
    
    private let minHeight: CGFloat = 48
    private let maxHeight: CGFloat = 120
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
                    Image(systemName: messageText.isEmpty ? "microphone.fill" : "arrow.up.circle.fill")
                        .resizable()
                        .frame(
                            width: messageText.isEmpty ? 20 : 28,
                            height: messageText.isEmpty ? 26 : 28)
                        .foregroundStyle(LinearGradient.appPurpleHorizontal)
                }
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
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        print("Отправка: \(messageText)")
        
        messageText = ""
        textHeight = minHeight
    }
}

#Preview {
    MessageInputView()
}
