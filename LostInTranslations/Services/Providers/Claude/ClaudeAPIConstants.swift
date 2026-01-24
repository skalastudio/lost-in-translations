import Foundation

enum ClaudeAPIConstants {
    static let endpoint = URL(string: "https://api.anthropic.com/v1/messages")!
    static let httpMethod = "POST"
    static let apiKeyHeader = "x-api-key"
    static let versionHeader = "anthropic-version"
    static let versionValue = "2023-06-01"
    static let contentTypeHeader = "Content-Type"
    static let contentTypeJSON = "application/json"

    static let maxTokens = 1024
}
