import Foundation

/// Request payload for OpenAI chat completions.
struct OpenAIChatRequest: Encodable {
    /// Model identifier.
    let model: String
    /// Chat messages.
    let messages: [OpenAIChatMessage]
    /// Sampling temperature.
    let temperature: Double
    /// Response format settings.
    let responseFormat: OpenAIChatResponseFormat

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case responseFormat = "response_format"
    }
}

/// Chat message for the OpenAI API.
struct OpenAIChatMessage: Encodable {
    /// Role identifier.
    let role: String
    /// Message content.
    let content: String
}

/// Response format request wrapper.
struct OpenAIChatResponseFormat: Encodable {
    /// Response format type.
    let type: String
}

/// Response payload for OpenAI chat completions.
struct OpenAIChatResponse: Decodable {
    /// Response choices.
    let choices: [OpenAIChatChoice]
}

/// Single choice entry from the OpenAI response.
struct OpenAIChatChoice: Decodable {
    /// Message content wrapper.
    let message: OpenAIChatChoiceMessage
}

/// Message content for a choice.
struct OpenAIChatChoiceMessage: Decodable {
    /// Message content text.
    let content: String
}

/// Error response wrapper.
struct OpenAIErrorResponse: Decodable {
    /// Error body payload.
    let error: OpenAIErrorBody
}

/// Error response body.
struct OpenAIErrorBody: Decodable {
    /// Error message.
    let message: String
    /// Error type identifier.
    let type: String?
    /// Error code identifier.
    let code: String?
}
