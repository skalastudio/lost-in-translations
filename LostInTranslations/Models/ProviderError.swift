import Foundation

/// Errors returned by provider orchestration or clients.
enum ProviderError: LocalizedError {
    /// Provider API key is missing.
    case missingKey(Provider)
    /// Provider returned an invalid response.
    case invalidResponse
    /// JSON or payload decoding failed.
    case decodingFailed
    /// Provider returned a service error message.
    case serviceError(String)
    /// Network request failed.
    case network(Error)

    /// Localized description for the error.
    var errorDescription: String? {
        switch self {
        case .missingKey(let provider):
            return String(format: String(localized: "error.missingKey"), provider.localizedName)
        case .invalidResponse:
            return String(localized: "error.invalidResponse")
        case .decodingFailed:
            return String(localized: "error.decodingFailed")
        case .serviceError(let message):
            return message
        case .network(let error):
            return String(format: String(localized: "error.network"), error.localizedDescription)
        }
    }
}
