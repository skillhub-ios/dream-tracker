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
        id: UUID = UUID(),
        sender: String,
        text: String,
        timeStamp: Date = .now
    ) {
        self.id = id
        self.role = sender
        self.text = text
        self.timeStamp = timeStamp
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
