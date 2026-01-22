import Foundation

private struct TaskResponse: Decodable {
    let results: [TaskResponseItem]
}

private struct TaskResponseItem: Decodable {
    let language: String
    let text: String
}

struct ResponseParser {
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
