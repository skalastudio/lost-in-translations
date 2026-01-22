import Foundation

enum ProviderError: LocalizedError {
    case missingKey(Provider)
    case invalidResponse
    case decodingFailed
    case serviceError(String)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .missingKey(let provider):
            return "Missing API key for \(provider.rawValue). Add it in Settings."
        case .invalidResponse:
            return "The provider returned an invalid response."
        case .decodingFailed:
            return "Failed to parse the provider response."
        case .serviceError(let message):
            return message
        case .network(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
