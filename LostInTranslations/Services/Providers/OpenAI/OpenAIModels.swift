import Foundation

struct OpenAIChatRequest: Encodable {
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

struct OpenAIChatMessage: Encodable {
    let role: String
    let content: String
}

struct OpenAIChatResponseFormat: Encodable {
    let type: String
}

struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatChoiceMessage
}

struct OpenAIChatChoiceMessage: Decodable {
    let content: String
}

struct OpenAIErrorResponse: Decodable {
    let error: OpenAIErrorBody
}

struct OpenAIErrorBody: Decodable {
    let message: String
    let type: String?
    let code: String?
}
