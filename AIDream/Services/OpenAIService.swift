import Foundation
import SwiftUI
 
class OpenAIService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    @Published var isProcessing = false
    @Published var error: Error?
    
    init(apiKey: String = Constants.openAIKey) {
        self.apiKey = apiKey
    }
    
    func sendMessage(_ message: String, context: [Message] = []) async throws -> String {
        isProcessing = true
        defer { isProcessing = false }
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var messages: [[String: String]] = [
            ["role": "system", "content": "Ты - опытный сонник, специализирующийся на анализе снов и их интерпретации. Отвечай на русском языке."]
        ]
        
        // Добавляем контекст предыдущих сообщений
        for msg in context {
            messages.append(["role": msg.role.rawValue, "content": msg.content])
        }
        
        // Добавляем текущее сообщение
        messages.append(["role": Role.user.rawValue, "content": message])
        
        let requestBody: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 1000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let statusCode = httpResponse.statusCode
            let responseBody = String(data: data, encoding: .utf8) ?? "<no body>"

            print("OpenAIService: HTTP error \(statusCode)")
            print("Response body:", responseBody)

            if statusCode == 429 {
                throw OpenAIServiceError.rateLimited
            } else {
                throw OpenAIServiceError.httpError(statusCode: statusCode, body: responseBody)
            }
        }
        
        let decoder = JSONDecoder()
        let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
        
        guard let content = openAIResponse.choices.first?.message.content else {
            print("OpenAIService: Cannot parse response", String(data: data, encoding: .utf8) ?? "<no data>")
            throw URLError(.cannotParseResponse)
        }
        
        return content
    }
    
    // MARK: - Tag selection logic
    private let availableTags: [String] = [
        "Daydream", "Epic Dream", "Continuous Dream", "Prophetic Dream", "Nightmare",
        "Night Terror", "Lucid Dream", "False Awakening", "Supernatural Dream",
        "Telepathic Dream", "Creative Dream", "Healing Dream", "Sleep Paralysis"
    ]
    
    private func selectTags(for summary: String, interpretation: String) -> [String] {
        let lowercased = (summary + " " + interpretation).lowercased()
        var matched: [String] = []
        let tagKeywords: [String: [String]] = [
            "Daydream": ["дневной", "мечта", "фантазия"],
            "Epic Dream": ["эпический", "грандиозный", "приключение"],
            "Continuous Dream": ["продолжающийся", "серия", "повторяющийся"],
            "Prophetic Dream": ["пророческий", "будущее", "предсказание"],
            "Nightmare": ["кошмар", "ужас", "страх"],
            "Night Terror": ["паника", "ужас ночью", "террор"],
            "Lucid Dream": ["осознанный", "контроль", "понимание сна"],
            "False Awakening": ["ложное пробуждение", "проснулся во сне"],
            "Supernatural Dream": ["сверхъестественный", "мистика", "магия"],
            "Telepathic Dream": ["телепатия", "мысли других"],
            "Creative Dream": ["творчество", "идея", "созидание"],
            "Healing Dream": ["исцеление", "выздоровление", "лечение"],
            "Sleep Paralysis": ["паралич", "не могу двигаться", "сонный паралич"]
        ]
        for (tag, keywords) in tagKeywords {
            if keywords.contains(where: { lowercased.contains($0) }) {
                matched.append(tag)
            }
        }
        // Если не найдено, просто вернуть первые два
        if matched.isEmpty { return Array(availableTags.prefix(2)) }
        return Array(matched.prefix(2))
    }
    
    func interpretDream(_ content: String) async throws -> DreamInterpretation {
        let prompt = """
        Проанализируй следующий сон и предоставь его интерпретацию в формате JSON:
        
        Сон: \(content)
        
        Формат ответа:
        {
            \"title\": \"Краткое название сна (не более трех слов)\",
            \"summary\": \"Краткое описание значения сна\",
            \"symbols\": [
                {
                    \"symbol\": \"[Используй одну из этих эмодзи: 🐍, 🌊, 🌳, 🔮, 🦋, 🌙, ⭐, 🏔️, 🌊, 🔥]\",
                    \"meaning\": \"Значение символа одним словом или через тире\"
                },
                {
                    \"symbol\": \"[Используй другую эмодзи из списка]\",
                    \"meaning\": \"Значение символа одним словом или через тире\"
                },
                {
                    \"symbol\": \"[Используй третью эмодзи из списка]\",
                    \"meaning\": \"Значение символа одним словом или через тире\"
                }
            ],
            \"emotionalAnalysis\": \"Анализ эмоционального состояния\",
            \"recommendations\": [
                \"Рекомендация 1\",
                \"Рекомендация 2\"
            ],
            \"tags\": [\"Тег1\", \"Тег2\"],
            \"quote\": \"Цитата известного психолога о снах, которая подходит к интерпретации этого сна\"
        }
        
        Используй русский язык для ответа.
        Важно: 
        1. В поле \"symbol\" всегда используй эмодзи, а не текстовое описание символа.
        2. Должно быть ровно три символа с разными эмодзи.
        3. Значение символа должно быть одним словом или через тире.
        4. В поле \"quote\" используй реальную цитату известного психолога (например, Фрейда, Юнга, Адлера) о снах, которая подходит к интерпретации этого конкретного сна.
        5. Название сна должно быть кратким и емким, не более трех слов.
        """
        
        let response = try await sendMessage(prompt)
        
        guard let jsonData = response.data(using: .utf8) else {
            print("OpenAIService: Cannot convert response to data", response)
            throw URLError(.cannotParseResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(DreamInterpretation.self, from: jsonData)
    }
}

// MARK: - Response Models
enum OpenAIServiceError: Error {
    case rateLimited
    case httpError(statusCode: Int, body: String)
}

private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
} 
