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
    private let messageDataStore = DIContainer.messageDataStore
    
    init(
        interpretation: Interpretation
    ) {
        self.interpretation = interpretation
        loadChatHistory()
    }
    
    func sendMessageToAIChat(_ text: String) async {
        let message = Message(sender: "user", text: text)
        await MainActor.run {
            messages.append(message)
            if let dreamId = interpretation.dreamParentId {
                messageDataStore.saveMessage(message, dremId: dreamId)
            }
        }
        
        do {
            let lastMessages = messages.suffix(10) // send only last 10 messages
            let response = try await openAIManager.sendChat(messages: Array(lastMessages), interpretation: interpretation)
            
            await MainActor.run {
                messages.append(response)
                if let dreamId = interpretation.dreamParentId {
                    messageDataStore.saveMessage(response, dremId: dreamId)
                }
            }
        } catch {
            print("❌ Ошибка при отправке сообщения: \(error.localizedDescription)")
        }
    }
    
    private func loadChatHistory() {
        guard let dreamId = interpretation.dreamParentId else { return }
        self.messages = messageDataStore.loadMessagesFor(dreamId: dreamId)
    }
    
}
