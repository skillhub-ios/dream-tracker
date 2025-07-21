//
// Message.swift
//
// Created by Cesare on 17.07.2025 on Earth.
// 


import Foundation

struct Message: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let role: String
    let text: String
    let timeStamp: Date
    
    init(
        sender: String,
        text: String
    ) {
        self.id = UUID()
        self.role = sender
        self.text = text
        self.timeStamp = .now
    }
}

struct OpenAIChatResponse: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: OpenAIMessage
    }

    struct OpenAIMessage: Decodable {
        let role: String
        let content: String
    }
}
