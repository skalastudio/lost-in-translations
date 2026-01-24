import Foundation

struct ClaudeClient: ProviderClient {
    let provider: Provider = .claude
    private let builder = TaskSpecBuilder()

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
