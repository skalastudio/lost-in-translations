import Foundation

/// Gemini provider client implementation.
struct GeminiClient: ProviderClient {
    /// Provider identifier.
    let provider: Provider = .gemini
    /// Prompt builder used to construct requests.
    private let builder = TaskSpecBuilder()

    /// Executes a task using the Gemini API.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - apiKey: API key for Gemini.
    /// - Returns: Provider result payload.
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = GeminiRequest(
            contents: [
                .init(role: "user", parts: [.init(text: builder.systemPrompt(for: spec))]),
                .init(role: "user", parts: [.init(text: builder.userPrompt(for: spec))]),
            ]
        )
        let urlString =
            "\(GeminiAPIConstants.baseURL)\(model)\(GeminiAPIConstants.generateContentPath)"
            + "?\(GeminiAPIConstants.apiKeyQueryName)=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw ProviderError.invalidResponse
        }
        var request = URLRequest(url: url)
        request.httpMethod = GeminiAPIConstants.httpMethod
        request.setValue(GeminiAPIConstants.contentTypeJSON, forHTTPHeaderField: GeminiAPIConstants.contentTypeHeader)
        request.httpBody = try JSONEncoder().encode(requestBody)

        let responseData = try await send(request: request)
        let response = try JSONDecoder().decode(GeminiResponse.self, from: responseData)
        guard let content = response.candidates.first?.content.parts.first?.text else {
            throw ProviderError.invalidResponse
        }
        let parsed = try ResponseParser.parse(content)
        return ProviderResult(results: parsed, model: model)
    }

    /// Sends a request and validates the Gemini response.
    /// - Parameter request: The URL request to send.
    /// - Returns: Raw response data.
    private func send(request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await ProviderRequestHelper.performRequest(request)
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

    /// Parses error details from a Gemini error response.
    /// - Parameter data: Raw error response data.
    /// - Returns: Localized error message if available.
    private func parseGeminiError(from data: Data) -> String? {
        guard let errorResponse = try? JSONDecoder().decode(GeminiErrorResponse.self, from: data) else {
            return nil
        }
        if let status = errorResponse.error.status {
            return String(format: String(localized: "error.gemini.detailStatus"), errorResponse.error.message, status)
        }
        return String(format: String(localized: "error.gemini.detail"), errorResponse.error.message)
    }
}
