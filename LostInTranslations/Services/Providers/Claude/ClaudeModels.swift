import Foundation

struct ClaudeRequest: Encodable {
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

struct ClaudeMessage: Encodable {
    let role: String
    let content: String
}

struct ClaudeResponse: Decodable {
    let content: [ClaudeContent]
}

struct ClaudeContent: Decodable {
    let text: String
}

struct ClaudeErrorResponse: Decodable {
    let error: ClaudeErrorBody
}

struct ClaudeErrorBody: Decodable {
    let message: String
    let type: String?
}
