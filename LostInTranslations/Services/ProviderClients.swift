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
    private static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

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
            url: Self.endpoint,
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
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ProviderError.network(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw ProviderError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let message =
                parseOpenAIError(from: data)
                ?? String(format: String(localized: "error.openai.http"), http.statusCode)
            throw ProviderError.serviceError(message)
        }
        return data
    }

    private func parseOpenAIError(from data: Data) -> String? {
        guard let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) else {
            return nil
        }
        if let code = errorResponse.error.code, let type = errorResponse.error.type {
            return String(
                format: String(localized: "error.openai.detailTypeCode"),
                errorResponse.error.message,
                type,
                code
            )
        }
        if let type = errorResponse.error.type {
            return String(format: String(localized: "error.openai.detailType"), errorResponse.error.message, type)
        }
        return String(format: String(localized: "error.openai.detail"), errorResponse.error.message)
    }
}

struct ClaudeClient: ProviderClient {
    let provider: Provider = .claude
    private let builder = TaskSpecBuilder()
    private static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!

    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = ClaudeRequest(
            model: model,
            maxTokens: 1024,
            system: builder.systemPrompt(for: spec),
            messages: [.init(role: "user", content: builder.userPrompt(for: spec))]
        )
        var request = URLRequest(url: Self.endpoint)
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
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ProviderError.network(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw ProviderError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let message =
                parseClaudeError(from: data)
                ?? String(format: String(localized: "error.claude.http"), http.statusCode)
            throw ProviderError.serviceError(message)
        }
        return data
    }

    private func parseClaudeError(from data: Data) -> String? {
        struct ClaudeErrorResponse: Decodable {
            let error: ClaudeErrorBody
        }
        struct ClaudeErrorBody: Decodable {
            let message: String
            let type: String?
        }
        guard let errorResponse = try? JSONDecoder().decode(ClaudeErrorResponse.self, from: data) else {
            return nil
        }
        if let type = errorResponse.error.type {
            return String(format: String(localized: "error.claude.detailType"), errorResponse.error.message, type)
        }
        return String(format: String(localized: "error.claude.detail"), errorResponse.error.message)
    }
}

struct GeminiClient: ProviderClient {
    let provider: Provider = .gemini
    private let builder = TaskSpecBuilder()
    private static let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/"

    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = GeminiRequest(
            contents: [
                .init(role: "user", parts: [.init(text: builder.systemPrompt(for: spec))]),
                .init(role: "user", parts: [.init(text: builder.userPrompt(for: spec))]),
            ]
        )
        let urlString = "\(Self.baseURL)\(model):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw ProviderError.invalidResponse
        }
        var request = URLRequest(url: url)
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
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw ProviderError.network(error)
        }
        guard let http = response as? HTTPURLResponse else {
            throw ProviderError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let message =
                parseGeminiError(from: data)
                ?? String(format: String(localized: "error.gemini.http"), http.statusCode)
            throw ProviderError.serviceError(message)
        }
        return data
    }

    private func parseGeminiError(from data: Data) -> String? {
        struct GeminiErrorResponse: Decodable {
            let error: GeminiErrorBody
        }
        struct GeminiErrorBody: Decodable {
            let message: String
            let status: String?
        }
        guard let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) else {
            return nil
        }
        if let status = errorResponse.error.status {
            return String(format: String(localized: "error.gemini.detailStatus"), errorResponse.error.message, status)
        }
        return String(format: String(localized: "error.gemini.detail"), errorResponse.error.message)
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
