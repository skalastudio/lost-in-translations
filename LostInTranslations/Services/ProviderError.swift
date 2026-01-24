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
