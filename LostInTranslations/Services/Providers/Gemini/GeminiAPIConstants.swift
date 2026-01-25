import Foundation

/// Gemini API constants used by the client.
enum GeminiAPIConstants {
    /// Base URL for Gemini models.
    static let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/"
    /// Path suffix for generate content calls.
    static let generateContentPath = ":generateContent"
    /// Query name used for the API key.
    static let apiKeyQueryName = "key"
    /// HTTP method used for requests.
    static let httpMethod = "POST"
    /// Content type header name.
    static let contentTypeHeader = "Content-Type"
    /// JSON content type value.
    static let contentTypeJSON = "application/json"
}
