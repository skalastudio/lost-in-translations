import Foundation

/// Request payload for the Claude messages API.
struct ClaudeRequest: Encodable {
    /// Model identifier.
    let model: String
    /// Maximum tokens for the response.
    let maxTokens: Int
    /// System prompt content.
    let system: String
    /// Message list.
    let messages: [ClaudeMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

/// Message item in a Claude request.
struct ClaudeMessage: Encodable {
    /// Role identifier.
    let role: String
    /// Message content.
    let content: String
}

/// Response payload for the Claude messages API.
struct ClaudeResponse: Decodable {
    /// Content items returned by the API.
    let content: [ClaudeContent]
}

/// Content item in a Claude response.
struct ClaudeContent: Decodable {
    /// Content text.
    let text: String
}

/// Error response wrapper for Claude.
struct ClaudeErrorResponse: Decodable {
    /// Error body payload.
    let error: ClaudeErrorBody
}

/// Error body returned by Claude.
struct ClaudeErrorBody: Decodable {
    /// Error message.
    let message: String
    /// Error type identifier.
    let type: String?
}
