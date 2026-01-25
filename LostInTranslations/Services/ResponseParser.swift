import Foundation

/// Decodable wrapper for provider JSON responses.
private struct TaskResponse: Decodable {
    /// Parsed results payload.
    let results: [TaskResponseItem]
}

/// Decodable item for a single language output.
private struct TaskResponseItem: Decodable {
    /// Language code in the response.
    let language: String
    /// Output text for the language.
    let text: String
}

/// Parses provider responses into app output models.
struct ResponseParser {
    /// Parses provider response content into output results.
    /// - Parameter content: Raw response content string.
    /// - Returns: Parsed output results.
    static func parse(_ content: String) throws -> [OutputResult] {
        guard let data = content.data(using: .utf8) else {
            throw ProviderError.decodingFailed
        }
        let response = try JSONDecoder().decode(TaskResponse.self, from: data)
        return response.results.compactMap { item in
            let language = LanguageOption.all.first { option in
                option.code.caseInsensitiveCompare(item.language) == .orderedSame
            }
            guard let matched = language else { return nil }
            return OutputResult(language: matched, text: item.text)
        }
    }
}
