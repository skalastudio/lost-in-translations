import Foundation

enum OpenAIAPIConstants {
    static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    static let httpMethod = "POST"
    static let authorizationHeader = "Authorization"
    static let contentTypeHeader = "Content-Type"
    static let contentTypeJSON = "application/json"
    static let bearerPrefix = "Bearer "

    static let temperature: Double = 0.2
    static let responseFormatType = "json_object"
}
