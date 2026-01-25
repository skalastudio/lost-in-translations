import Foundation

/// OpenAI provider client implementation.
struct OpenAIClient: ProviderClient {
    /// Provider identifier.
    let provider: Provider = .openAI
    /// Prompt builder used to construct requests.
    private let builder = TaskSpecBuilder()

    /// Executes a task using the OpenAI API.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - apiKey: API key for OpenAI.
    /// - Returns: Provider result payload.
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let model = ModelCatalog.defaultModel(for: provider, tier: spec.modelTier)
        let requestBody = OpenAIChatRequest(
            model: model,
            messages: [
                .init(role: "system", content: builder.systemPrompt(for: spec)),
                .init(role: "user", content: builder.userPrompt(for: spec)),
            ],
            temperature: OpenAIAPIConstants.temperature,
            responseFormat: .init(type: OpenAIAPIConstants.responseFormatType)
        )
        let request = try makeRequest(
            url: OpenAIAPIConstants.endpoint,
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

    /// Builds the URL request for the API call.
    /// - Parameters:
    ///   - url: API endpoint.
    ///   - apiKey: API key for authorization.
    ///   - body: Encodable request payload.
    /// - Returns: URL request configured for OpenAI.
    private func makeRequest<T: Encodable>(url: URL, apiKey: String, body: T) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = OpenAIAPIConstants.httpMethod
        request.setValue(
            "\(OpenAIAPIConstants.bearerPrefix)\(apiKey)",
            forHTTPHeaderField: OpenAIAPIConstants.authorizationHeader
        )
        request.setValue(OpenAIAPIConstants.contentTypeJSON, forHTTPHeaderField: OpenAIAPIConstants.contentTypeHeader)
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    /// Sends a request and validates the OpenAI response.
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
                parseOpenAIError(from: data)
                ?? String(format: String(localized: "error.openai.http"), http.statusCode)
            throw ProviderError.serviceError(message)
        }
        return data
    }

    /// Parses error details from an OpenAI error response.
    /// - Parameter data: Raw error response data.
    /// - Returns: Localized error message if available.
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
