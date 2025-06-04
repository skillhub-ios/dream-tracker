import Foundation
import SwiftUI
// import AIDream.Models.Message

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var inputMessage: String = ""
    @Published var isProcessing: Bool = false
    @Published var error: Error?
    
    private let openAIService: OpenAIService
    
    init(openAIService: OpenAIService = OpenAIService()) {
        self.openAIService = openAIService
    }
    
    func sendMessage() async {
        guard !inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(role: Role.user, content: inputMessage)
        messages.append(userMessage)
        
        let currentInput = inputMessage
        inputMessage = ""
        
        do {
            isProcessing = true
            let response = try await openAIService.sendMessage(currentInput, context: messages)
            let assistantMessage = Message(role: Role.assistant, content: response)
            messages.append(assistantMessage)
        } catch {
            self.error = error
            print("ChatViewModel error:", error)
        }
        
        isProcessing = false
    }
    
    func clearChat() {
        messages.removeAll()
    }
} 