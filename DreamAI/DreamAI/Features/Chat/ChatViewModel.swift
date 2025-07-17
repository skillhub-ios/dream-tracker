//
// ChatView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
//


import Foundation

final class ChatViewModel: ObservableObject {
    
    var interpretation: Interpretation
    @Published var messages: [Message] = []
    
    private let openAIManager = OpenAIManager.shared
    
    func sendMessage(_ text: String) async {
        let message = Message(sender: "user", text: text)
        await MainActor.run {
            messages.append(message)
        }
        
        do {
            let response = try await openAIManager.sendChat(messages: messages, interpretation: interpretation)
            
            await MainActor.run {
                messages.append(response)
            }
        } catch {
            print("❌ Ошибка при отправке сообщения: \(error.localizedDescription)")
        }
    }
    
    init(
        interpretation: Interpretation
    ) {
        self.interpretation = interpretation
    }
    
}



/// В запрос к OpenAI добавить тематики для начала беседы. Получить и распарсить эти данные - done
/// Создать для модель сообщений - done
/// Настроить отправку и получение сообщений от OpenAI, настроить передачу interpretation
/// Сохранение чатов
/// Настроить возможность записи и распознования голосовых сообщений?
