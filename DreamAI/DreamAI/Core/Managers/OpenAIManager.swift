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
    private let session = URLSession.shared
    private let decoder = JSONDecoder()

    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func getDreamInterpretation(dreamText: String, mood: String?) async throws -> Interpretation {
        guard !apiKey.isEmpty else {
            throw NSError(domain: "OpenAIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "OpenAI API key is missing."])
        }
        
        print("🚀 Starting dream interpretation for text: \(dreamText.prefix(50))...")
        
        // Use Chat Completion API with function calling
        return try await getDreamInterpretationWithFunctionCalling(dreamText: dreamText, mood: mood)
    }
    
    // MARK: - Function Calling Method
    private func getDreamInterpretationWithFunctionCalling(dreamText: String, mood: String?) async throws -> Interpretation {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        addHeaders(to: &request)
        
        let systemPrompt = """
                You are a dream interpretation expert. Analyze the user's dream and provide a comprehensive psychological interpretation. 
                Focus on the emotional content, symbolism, and potential meanings in the dreamer's life.
                
                IMPORTANT RULES:
                1. moodInsights must contain exactly 3 items with different emotions
                2. symbolism must contain exactly 3 items with short, concise meanings (1-3 words max)
                3. reflectionPrompts must be an ARRAY of strings, each containing one question with "\\n" at the end
                4. All scores in moodInsights must be between 0.0 and 1.0 (decimal values, not integers)
                5. dreamEmoji should be a single emoji that best represents the overall theme of the dream
                6. ALL emoji fields (dreamEmoji, moodInsights.emoji, symbolism.icon) must be actual emoji characters (🐶, 😊, 🌲) NOT text names ("Dog", "Happy", "Tree")
                7. dreamEmojiBackgroundColor must be a hex color code (e.g., "#FF6B6B", "#4ECDC4", "#45B7D1") that complements the emoji and creates a visually appealing background
                8. tags must be an array of strings with maximum 2 items, selected from these exact values: "Daydream", "Epic Dream", "Continuous Dream", "Prophetic Dream", "Nightmare", "Night Terror", "Lucid Dream", "False Awakening", "Supernatural Dream", "Telepathic Dream", "Creative Dream", "Healing Dream", "Sleep Paralysis". Choose the most logically fitting tags based on the dream content.
                """
        
        let userMessage = "Please interpret this dream: \(dreamText). Mood: \(mood ?? "not specified")."
        
        let body: [String: Any] = [
            "model": "gpt-4",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ],
            "tools": [
                [
                    "type": "function",
                    "function": [
                        "name": "interpret_dream",
                        "description": "Interpret a user's dream and provide psychological analysis",
                        "parameters": [
                            "type": "object",
                            "properties": [
                                "dreamEmoji": [
                                    "type": "string",
                                    "description": "A single emoji character that best represents the overall theme or mood of the dream (e.g., 🐶, 😊, 🌲, NOT 'Dog', 'Happy', 'Tree')"
                                ],
                                "dreamEmojiBackgroundColor": [
                                    "type": "string",
                                    "description": "A hex color code that complements the dream emoji and creates a visually appealing background (e.g., '#FF6B6B', '#4ECDC4', '#45B7D1')"
                                ],
                                "dreamTitle": [
                                    "type": "string",
                                    "description": "A brief, evocative title for the dream"
                                ],
                                "dreamSummary": [
                                    "type": "string",
                                    "description": "A concise summary of the dream in 2-3 sentences"
                                ],
                                "fullInterpretation": [
                                    "type": "string",
                                    "description": "A detailed psychological interpretation of the dream, including potential meanings, symbolism, and insights about the dreamer's subconscious mind"
                                ],
                                "moodInsights": [
                                    "type": "array",
                                    "items": [
                                        "type": "object",
                                        "properties": [
                                            "emoji": [
                                                "type": "string",
                                                "description": "An emoji character representing the mood (e.g., 😊, 😢, 😠, NOT 'Happy', 'Sad', 'Angry')"
                                            ],
                                            "label": [
                                                "type": "string",
                                                "description": "The mood label"
                                            ],
                                            "score": [
                                                "type": "number",
                                                "description": "A decimal score between 0.0 and 1.0 representing the intensity of this mood (e.g., 0.7, 0.4, 0.2)"
                                            ]
                                        ],
                                        "required": ["emoji", "label", "score"]
                                    ],
                                    "description": "Array of exactly 3 mood insights reflecting the emotional tone of the dream. Must include 3 different emotions.",
                                    "minItems": 3,
                                    "maxItems": 3
                                ],
                                "symbolism": [
                                    "type": "array",
                                    "items": [
                                        "type": "object",
                                        "properties": [
                                            "icon": [
                                                "type": "string",
                                                "description": "An emoji character representing the dream element (e.g., 🐶, 🌲, 🏠, NOT 'Dog', 'Tree', 'House')"
                                            ],
                                            "meaning": [
                                                "type": "string",
                                                "description": "The psychological meaning of this symbol (keep it short, 1-3 words max)"
                                            ]
                                        ],
                                        "required": ["icon", "meaning"]
                                    ],
                                    "description": "Array of exactly 3 symbolic elements and their psychological meanings. Keep meanings concise.",
                                    "minItems": 3,
                                    "maxItems": 3
                                ],
                                "reflectionPrompts": [
                                    "type": "array",
                                    "items": [
                                        "type": "string"
                                    ],
                                    "description": "Array of 3 questions to encourage self-reflection about the dream. Each question should be a separate string in the array with '\\n' at the end. Example: ['What did you feel in the dream?\\n', 'What does this dream mean to you?\\n', 'How does this relate to your life?\\n']",
                                    "minItems": 3,
                                    "maxItems": 3
                                ],
                                "tags": [
                                    "type": "array",
                                    "items": [
                                        "type": "string"
                                    ],
                                    "description": "Array of dream tags (maximum 2 items) selected from: 'Daydream', 'Epic Dream', 'Continuous Dream', 'Prophetic Dream', 'Nightmare', 'Night Terror', 'Lucid Dream', 'False Awakening', 'Supernatural Dream', 'Telepathic Dream', 'Creative Dream', 'Healing Dream', 'Sleep Paralysis'. Choose the most logically fitting tags based on the dream content.",
                                    "minItems": 0,
                                    "maxItems": 2
                                ],
                                "quote": [
                                    "type": "object",
                                    "properties": [
                                        "text": [
                                            "type": "string",
                                            "description": "An inspirational quote about dreams or psychology"
                                        ],
                                        "author": [
                                            "type": "string",
                                            "description": "The author of the quote"
                                        ]
                                    ],
                                    "required": ["text", "author"],
                                    "description": "An inspirational quote related to dreams or psychology"
                                ]
                            ],
                            "required": ["dreamEmoji", "dreamEmojiBackgroundColor", "dreamTitle", "dreamSummary", "fullInterpretation", "moodInsights", "symbolism", "reflectionPrompts", "tags", "quote"]
                        ]
                    ]
                ]
            ],
            "tool_choice": [
                "type": "function",
                "function": [
                    "name": "interpret_dream"
                ]
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        print("📡 Making API request to OpenAI...")
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 API Response Status: \(httpResponse.statusCode)")
        }
        
        try handleResponseError(response)
        
        print("📡 Parsing API response...")
        
        let chatResponse = try decoder.decode(ChatCompletionResponse.self, from: data)
        
        print("📡 Response has \(chatResponse.choices.count) choices")
        
        guard let choice = chatResponse.choices.first else {
            throw NSError(domain: "OpenAIManagerError", code: 6, userInfo: [NSLocalizedDescriptionKey: "No choices in response"])
        }
        
        print("📡 Choice finish reason: \(choice.finishReason ?? "unknown")")
        
        guard let toolCalls = choice.message.toolCalls, !toolCalls.isEmpty else {
            throw NSError(domain: "OpenAIManagerError", code: 6, userInfo: [NSLocalizedDescriptionKey: "No tool calls in response"])
        }
        
        guard let toolCall = toolCalls.first,
              toolCall.function.name == "interpret_dream",
              let arguments = toolCall.function.arguments.data(using: .utf8) else {
            throw NSError(domain: "OpenAIManagerError", code: 6, userInfo: [NSLocalizedDescriptionKey: "Invalid tool call or missing function arguments"])
        }
        
        print("📡 Function arguments received: \(arguments.prefix(100))...")
        
        // Log the full JSON for debugging
        print("📡 Full JSON response: \(arguments)")
        
        do {
            let interpretation = try JSONDecoder().decode(Interpretation.self, from: arguments)
            print("✅ Successfully decoded interpretation from function call")
            return interpretation
        } catch {
            print("❌ Failed to decode function call arguments: \(error)")
            print("❌ Arguments that failed to decode: \(arguments)")
            
            // Try to pretty print the JSON for better debugging
            if let jsonObject = try? JSONSerialization.jsonObject(with: arguments),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("❌ Pretty printed JSON: \(prettyString)")
            }
            
            throw NSError(domain: "OpenAIManagerError", code: 7, userInfo: [NSLocalizedDescriptionKey: "Failed to decode interpretation: \(error.localizedDescription)"])
        }
    }
    
    private func addHeaders(to request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }

    private func handleResponseError(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NSError(domain: "NetworkError", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "Invalid server response (Status: \(statusCode))"])
        }
    }
} 
