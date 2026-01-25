import Foundation

/// Request payload for Gemini content generation.
struct GeminiRequest: Encodable {
    /// Request contents.
    let contents: [GeminiContent]
}

/// Content entry in a Gemini request.
struct GeminiContent: Encodable {
    /// Role identifier.
    let role: String
    /// Content parts.
    let parts: [GeminiPart]
}

/// Content part in a Gemini request.
struct GeminiPart: Encodable {
    /// Part text.
    let text: String
}

/// Response payload for Gemini content generation.
struct GeminiResponse: Decodable {
    /// Candidate responses.
    let candidates: [GeminiCandidate]
}

/// Candidate wrapper in a Gemini response.
struct GeminiCandidate: Decodable {
    /// Candidate content.
    let content: GeminiCandidateContent
}

/// Candidate content in a Gemini response.
struct GeminiCandidateContent: Decodable {
    /// Content parts.
    let parts: [GeminiCandidatePart]
}

/// Content part in a Gemini response.
struct GeminiCandidatePart: Decodable {
    /// Part text.
    let text: String
}

/// Error response wrapper for Gemini.
struct GeminiErrorResponse: Decodable {
    /// Error body payload.
    let error: GeminiErrorBody
}

/// Error body returned by Gemini.
struct GeminiErrorBody: Decodable {
    /// Error message.
    let message: String
    /// Error status identifier.
    let status: String?
}
