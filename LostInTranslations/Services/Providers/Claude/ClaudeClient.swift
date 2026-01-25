import Foundation

/// Claude provider client implementation.
struct ClaudeClient: ProviderClient {
    /// Provider identifier.
    let provider: Provider = .claude
    /// Prompt builder used to construct requests.
    private let builder = TaskSpecBuilder()

    /// Executes a task using the Claude API.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - apiKey: API key for Claude.
    /// - Returns: Provider result payload.
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = ClaudeRequest(
            model: model,
            maxTokens: ClaudeAPIConstants.maxTokens,
            system: builder.systemPrompt(for: spec),
            messages: [.init(role: "user", content: builder.userPrompt(for: spec))]
        )
        var request = URLRequest(url: ClaudeAPIConstants.endpoint)
        request.httpMethod = ClaudeAPIConstants.httpMethod
        request.setValue(apiKey, forHTTPHeaderField: ClaudeAPIConstants.apiKeyHeader)
        request.setValue(ClaudeAPIConstants.versionValue, forHTTPHeaderField: ClaudeAPIConstants.versionHeader)
        request.setValue(ClaudeAPIConstants.contentTypeJSON, forHTTPHeaderField: ClaudeAPIConstants.contentTypeHeader)
        request.httpBody = try JSONEncoder().encode(requestBody)

        let responseData = try await send(request: request)
        let response = try JSONDecoder().decode(ClaudeResponse.self, from: responseData)
        guard let content = response.content.first?.text else {
            throw ProviderError.invalidResponse
        }
        let parsed = try ResponseParser.parse(content)
        return ProviderResult(results: parsed, model: model)
    }

    /// Sends a request and validates the Claude response.
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
                parseClaudeError(from: data)
                ?? String(format: String(localized: "error.claude.http"), http.statusCode)
            throw ProviderError.serviceError(message)
        }
        return data
    }

    /// Parses error details from a Claude error response.
    /// - Parameter data: Raw error response data.
    /// - Returns: Localized error message if available.
    private func parseClaudeError(from data: Data) -> String? {
        guard let errorResponse = try? JSONDecoder().decode(ClaudeErrorResponse.self, from: data) else {
            return nil
        }
        if let type = errorResponse.error.type {
            return String(format: String(localized: "error.claude.detailType"), errorResponse.error.message, type)
        }
        return String(format: String(localized: "error.claude.detail"), errorResponse.error.message)
    }
}
