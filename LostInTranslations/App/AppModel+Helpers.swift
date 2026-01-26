import Foundation

extension AppModel {
    /// Runs a single provider task and returns its first output.
    /// - Parameters:
    ///   - mode: The writing mode for the request.
    ///   - inputText: The input text.
    ///   - extraInstruction: Optional extra instruction.
    /// - Returns: The first output result.
    func runSingleTask(
        mode: WritingMode,
        inputText: String,
        extraInstruction: String?
    ) async throws -> OutputResult {
        let spec = TaskSpec(
            inputText: inputText,
            mode: mode,
            intent: writingIntent(for: selectedPurpose),
            tone: selectedTone,
            provider: selectedProvider,
            modelTier: .balanced,
            languages: [preferredOutputLanguageOption],
            sourceLanguage: translateFromLanguage.code,
            extraInstruction: extraInstruction
        )
        let output = try await taskRunner.run(spec: spec)
        guard let result = output.results.first else {
            throw ProviderError.invalidResponse
        }
        return result
    }

    /// Maps a purpose preset to a provider intent.
    /// - Parameter purpose: The selected purpose.
    /// - Returns: The writing intent for provider requests.
    func writingIntent(for purpose: Purpose) -> WritingIntent {
        switch purpose {
        case .email:
            return .email
        case .sms:
            return .sms
        case .chat:
            return .chat
        case .notes:
            return .plainText
        }
    }

    /// Preferred language option for single-output tasks.
    var preferredOutputLanguageOption: LanguageOption {
        translateFromLanguage.asLanguageOption ?? .english
    }

    /// Maps provider errors to user-friendly messages.
    /// - Parameter error: The error to map.
    /// - Returns: A short user-facing message.
    nonisolated static func mapErrorMessage(_ error: Error) -> String {
        if let providerError = error as? ProviderError {
            switch providerError {
            case .missingKey(let provider):
                return String(
                    format: String(localized: "error.missingKey"),
                    provider.localizedName
                )
            case .network:
                return String(localized: "error.networkTryAgain")
            case .serviceError(let message):
                let lower = message.lowercased()
                if lower.contains("apple translation") {
                    return message
                }
                if lower.contains("401") || lower.contains("unauthorized") {
                    return String(localized: "error.invalidKey")
                }
                if lower.contains("429") || lower.contains("rate") {
                    return String(localized: "error.rateLimit")
                }
                return String(localized: "error.generic")
            case .invalidResponse, .decodingFailed:
                return String(localized: "error.generic")
            }
        }
        let lower = String(describing: error).lowercased()
        if lower.contains("cancel") {
            return String(localized: "error.cancelled")
        }
        return String(localized: "error.generic")
    }
}
