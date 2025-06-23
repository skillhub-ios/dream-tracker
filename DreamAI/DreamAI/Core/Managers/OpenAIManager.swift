//
//  OpenAIManager.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import Foundation

class OpenAIManager {
    static let shared = OpenAIManager()
    private let apiKey = OpenAISecrets.apiKey
    private let assistantId = "asst_sbyQENuGQYaifyFdoNPTMGKT"
    private let session = URLSession.shared
    private let decoder = JSONDecoder()

    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func getDreamInterpretation(dreamText: String, mood: String?, tags: [String]) async throws -> DreamInterpretationFullModel {
        guard !apiKey.isEmpty && apiKey != "YOUR_OPENAI_API_KEY" else {
            throw NSError(domain: "OpenAIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API key is missing."])
        }
        
        let threadId = try await createThread()
        
        let userMessage = "dreamText: \(dreamText), mood: \(mood ?? "none"), tags: \(tags.joined(separator: ", "))"
        _ = try await addMessage(threadId: threadId, content: userMessage)
        
        let run = try await createRun(threadId: threadId)
        
        var retries = 0
        while retries < 15 { // Wait for max 15 seconds
            let runStatus = try await getRunStatus(threadId: threadId, runId: run.id)
            
            switch runStatus.status {
            case "requires_action":
                if let toolCall = runStatus.requiredAction?.submitToolOutputs.toolCalls.first {
                    let arguments = toolCall.function.arguments
                    if let data = arguments.data(using: .utf8) {
                        return try JSONDecoder().decode(DreamInterpretationFullModel.self, from: data)
                    }
                }
                throw NSError(domain: "OpenAIManagerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to decode interpretation."])
            case "completed":
                 throw NSError(domain: "OpenAIManagerError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Run completed without returning data."])
            case "failed":
                throw NSError(domain: "OpenAIManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Dream interpretation failed. The run failed."])
            default:
                try await Task.sleep(nanoseconds: 1_000_000_000) // wait 1 second
                retries += 1
            }
        }
        
        throw NSError(domain: "OpenAIManagerError", code: 4, userInfo: [NSLocalizedDescriptionKey: "Request timed out."])
    }
}

// MARK: - API Calls
private extension OpenAIManager {
    private func createThread() async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/threads")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addHeaders(to: &request)

        let (data, response) = try await session.data(for: request)
        try handleResponseError(response)
        
        let thread = try decoder.decode(OpenAIThread.self, from: data)
        return thread.id
    }
    
    private func addMessage(threadId: String, content: String) async throws -> OpenAIMessage {
        let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addHeaders(to: &request)
        
        let body = ["role": "user", "content": content]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        try handleResponseError(response)

        return try decoder.decode(OpenAIMessage.self, from: data)
    }
    
    private func createRun(threadId: String) async throws -> OpenAIRun {
        let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/runs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addHeaders(to: &request)
        
        let body = ["assistant_id": assistantId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await session.data(for: request)
        try handleResponseError(response)

        return try decoder.decode(OpenAIRun.self, from: data)
    }
    
    private func getRunStatus(threadId: String, runId: String) async throws -> OpenAIRun {
        let url = URL(string: "https://api.openai.com/v1/threads/\(threadId)/runs/\(runId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        addHeaders(to: &request)
        
        let (data, response) = try await session.data(for: request)
        try handleResponseError(response)
        
        return try decoder.decode(OpenAIRun.self, from: data)
    }
    
    private func addHeaders(to request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("assistants=v2", forHTTPHeaderField: "OpenAI-Beta")
    }

    private func handleResponseError(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "NetworkError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])
        }
    }
} 