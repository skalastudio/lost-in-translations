import Foundation

struct GeminiRequest: Encodable {
    let contents: [GeminiContent]
}

struct GeminiContent: Encodable {
    let role: String
    let parts: [GeminiPart]
}

struct GeminiPart: Encodable {
    let text: String
}

struct GeminiResponse: Decodable {
    let candidates: [GeminiCandidate]
}

struct GeminiCandidate: Decodable {
    let content: GeminiCandidateContent
}

struct GeminiCandidateContent: Decodable {
    let parts: [GeminiCandidatePart]
}

struct GeminiCandidatePart: Decodable {
    let text: String
}

struct GeminiErrorResponse: Decodable {
    let error: GeminiErrorBody
}

struct GeminiErrorBody: Decodable {
    let message: String
    let status: String?
}
