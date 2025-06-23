//
//  OpenAIModels.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation

struct OpenAIThread: Codable {
    let id: String
    let object: String
    let createdAt: Int
    let metadata: [String: String]
}

struct OpenAIMessage: Codable {
    let id: String
    let object: String
    let createdAt: Int
    let threadId: String
    let role: String
    let content: [MessageContent]
    
    struct MessageContent: Codable {
        let type: String
        let text: MessageText?
    }

    struct MessageText: Codable {
        let value: String
        let annotations: [String]
    }
}

struct OpenAIRun: Codable {
    let id: String
    let object: String
    let createdAt: Int
    let assistantId: String
    let threadId: String
    let status: String
    let requiredAction: RequiredAction?
    
    struct RequiredAction: Codable {
        let type: String
        let submitToolOutputs: SubmitToolOutputs
    }

    struct SubmitToolOutputs: Codable {
        let toolCalls: [ToolCall]
    }

    struct ToolCall: Codable {
        let id: String
        let type: String
        let function: ToolFunction
    }

    struct ToolFunction: Codable {
        let name: String
        let arguments: String
    }
} 