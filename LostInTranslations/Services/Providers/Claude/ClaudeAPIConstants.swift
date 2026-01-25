import Foundation

/// Anthropic Claude API constants used by the client.
enum ClaudeAPIConstants {
    /// Messages endpoint.
    static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    /// HTTP method used for requests.
    static let httpMethod = "POST"
    /// API key header name.
    static let apiKeyHeader = "x-api-key"
    /// Version header name.
    static let versionHeader = "anthropic-version"
    /// API version value.
    static let versionValue = "2023-06-01"
    /// Content type header name.
    static let contentTypeHeader = "Content-Type"
    /// JSON content type value.
    static let contentTypeJSON = "application/json"

    /// Maximum tokens requested for responses.
    static let maxTokens = 1024
}
