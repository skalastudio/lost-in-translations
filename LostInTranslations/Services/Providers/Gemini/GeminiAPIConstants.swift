import Foundation

enum GeminiAPIConstants {
    static let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/"
    static let generateContentPath = ":generateContent"
    static let apiKeyQueryName = "key"
    static let httpMethod = "POST"
    static let contentTypeHeader = "Content-Type"
    static let contentTypeJSON = "application/json"
}
