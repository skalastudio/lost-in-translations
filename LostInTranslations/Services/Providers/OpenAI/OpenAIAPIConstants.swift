import Foundation

/// OpenAI API constants used by the client.
enum OpenAIAPIConstants {
    /// Chat completions endpoint.
    static let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    /// HTTP method used for requests.
    static let httpMethod = "POST"
    /// Authorization header name.
    static let authorizationHeader = "Authorization"
    /// Content type header name.
    static let contentTypeHeader = "Content-Type"
    /// JSON content type value.
    static let contentTypeJSON = "application/json"
    /// Bearer prefix for authorization header.
    static let bearerPrefix = "Bearer "

    /// Default temperature for responses.
    static let temperature: Double = 0.2
    /// Response format type for JSON output.
    static let responseFormatType = "json_object"
}
