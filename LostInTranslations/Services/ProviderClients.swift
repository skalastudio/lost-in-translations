import Foundation

protocol ProviderClient: Sendable {
    var provider: Provider { get }
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult
}

struct ProviderResult: Sendable {
    let results: [OutputResult]
    let model: String
}

struct OpenAIClient: ProviderClient {
    let provider: Provider = .openAI
    private let builder = TaskSpecBuilder()

    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = OpenAIChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: builder.systemPrompt(for: spec)),
                .init(role: "user", content: builder.userPrompt(for: spec)),
            ],
            temperature: 0.2,
            responseFormat: .init(type: "json_object")
        )
        let request = try makeRequest(
            url: URL(string: "https://api.openai.com/v1/chat/completions")!,
            apiKey: apiKey,
            body: requestBody
        )
        let responseData = try await send(request: request)
        let response = try JSONDecoder().decode(OpenAIChatResponse.self, from: responseData)
        guard let content = response.choices.first?.message.content else {
            throw ProviderError.invalidResponse
        }
        let parsed = try ResponseParser.parse(content)
        return ProviderResult(results: parsed, model: model)
    }

    private func makeRequest<T: Encodable>(url: URL, apiKey: String, body: T) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func send(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw ProviderError.invalidResponse }
            guard (200..<300).contains(http.statusCode) else {
                let message = parseOpenAIError(from: data) ?? "OpenAI error: HTTP \(http.statusCode)."
                throw ProviderError.serviceError(message)
            }
            return data
        } catch {
            throw ProviderError.network(error)
        }
    }

    private func parseOpenAIError(from data: Data) -> String? {
        guard let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) else {
            return nil
        }
        if let code = errorResponse.error.code, let type = errorResponse.error.type {
            return "OpenAI error: \(errorResponse.error.message) (\(type), \(code))"
        }
        if let type = errorResponse.error.type {
            return "OpenAI error: \(errorResponse.error.message) (\(type))"
        }
        return "OpenAI error: \(errorResponse.error.message)"
    }
}

struct ClaudeClient: ProviderClient {
    let provider: Provider = .claude
    private let builder = TaskSpecBuilder()

    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = ClaudeRequest(
            model: model,
            maxTokens: 1024,
            system: builder.systemPrompt(for: spec),
            messages: [.init(role: "user", content: builder.userPrompt(for: spec))],
        )
        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let responseData = try await send(request: request)
        let response = try JSONDecoder().decode(ClaudeResponse.self, from: responseData)
        guard let content = response.content.first?.text else {
            throw ProviderError.invalidResponse
        }
        let parsed = try ResponseParser.parse(content)
        return ProviderResult(results: parsed, model: model)
    }

    private func send(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw ProviderError.invalidResponse }
            guard (200..<300).contains(http.statusCode) else {
                throw ProviderError.serviceError("Claude error: HTTP \(http.statusCode).")
            }
            return data
        } catch {
            throw ProviderError.network(error)
        }
    }
}

struct GeminiClient: ProviderClient {
    let provider: Provider = .gemini
    private let builder = TaskSpecBuilder()

    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = GeminiRequest(
            contents: [
                .init(role: "user", parts: [.init(text: builder.systemPrompt(for: spec))]),
                .init(role: "user", parts: [.init(text: builder.userPrompt(for: spec))]),
            ]
        )
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent?key=\(apiKey)"
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let responseData = try await send(request: request)
        let response = try JSONDecoder().decode(GeminiResponse.self, from: responseData)
        guard let content = response.candidates.first?.content.parts.first?.text else {
            throw ProviderError.invalidResponse
        }
        let parsed = try ResponseParser.parse(content)
        return ProviderResult(results: parsed, model: model)
    }

    private func send(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw ProviderError.invalidResponse }
            guard (200..<300).contains(http.statusCode) else {
                throw ProviderError.serviceError("Gemini error: HTTP \(http.statusCode).")
            }
            return data
        } catch {
            throw ProviderError.network(error)
        }
    }
}

private struct OpenAIChatRequest: Encodable {
    let model: String
    let messages: [OpenAIChatMessage]
    let temperature: Double
    let responseFormat: OpenAIChatResponseFormat

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case responseFormat = "response_format"
    }
}

private struct OpenAIChatMessage: Encodable {
    let role: String
    let content: String
}

private struct OpenAIChatResponseFormat: Encodable {
    let type: String
}

private struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

private struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatChoiceMessage
}

private struct OpenAIChatChoiceMessage: Decodable {
    let content: String
}

private struct OpenAIErrorResponse: Decodable {
    let error: OpenAIErrorBody
}

private struct OpenAIErrorBody: Decodable {
    let message: String
    let type: String?
    let code: String?
}

private struct ClaudeRequest: Encodable {
    let model: String
    let maxTokens: Int
    let system: String
    let messages: [ClaudeMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

private struct ClaudeMessage: Encodable {
    let role: String
    let content: String
}

private struct ClaudeResponse: Decodable {
    let content: [ClaudeContent]
}

private struct ClaudeContent: Decodable {
    let text: String
}

private struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
}

private struct GeminiContent: Encodable {
    let role: String
    let parts: [GeminiPart]
}

private struct GeminiPart: Encodable {
    let text: String
}

private struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

private struct GeminiCandidate: Decodable {
    let content: GeminiCandidateContent
}

private struct GeminiCandidateContent: Decodable {
    let parts: [GeminiCandidatePart]
}

private struct GeminiCandidatePart: Decodable {
    let text: String
}
