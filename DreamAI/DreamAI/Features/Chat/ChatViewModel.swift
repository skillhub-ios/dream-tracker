//
// ChatView.swift
//
// Created by Cesare on 16.07.2025 on Earth.
//


import Foundation

final class ChatViewModel: ObservableObject {
    
    var interpretation: Interpretation
    @Published var messages: [Message] = []
    @Published var messageText = ""
    
    private let openAIManager = OpenAIManager.shared
    
    func sendMessageToAIChat(_ text: String) async {
        let message = Message(sender: "user", text: text)
        await MainActor.run {
            messages.append(message)
            print("New message appened: \(message)")
        }
        
        do {
            let lastMessages = messages.suffix(10) // send only last 10 messages
            let response = try await openAIManager.sendChat(messages: Array(lastMessages), interpretation: interpretation)
            
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
