import Foundation
import NaturalLanguage

#if canImport(Translation)
    import Translation
#endif

/// Provider client for Apple Translation services.
struct AppleTranslationClient: ProviderClient {
    /// Provider identifier.
    let provider: Provider = .appleTranslation

    /// Executes a task using Apple Translation.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - apiKey: Ignored for Apple Translation.
    /// - Returns: Provider result payload.
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        guard #available(macOS 15.0, *) else {
            throw ProviderError.serviceError(String(localized: "error.apple.unavailable"))
        }
        guard spec.mode == .translate else {
            throw ProviderError.serviceError(String(localized: "error.apple.unsupportedMode"))
        }
        let sourceLanguage = try resolveSourceLanguage(from: spec)
        let results = try await translateAll(
            text: spec.inputText,
            sourceLanguage: sourceLanguage,
            targetLanguages: spec.languages
        )
        return ProviderResult(results: results, model: "apple-translation")
    }

    @available(macOS 15.0, *)
    private func resolveSourceLanguage(from spec: TaskSpec) throws -> Locale.Language {
        if let explicit = spec.sourceLanguage,
            let language = localeLanguage(from: explicit)
        {
            return language
        }
        guard let detected = detectLanguage(for: spec.inputText) else {
            throw ProviderError.serviceError(String(localized: "error.apple.unableToIdentifyLanguage"))
        }
        return detected
    }

    @available(macOS 15.0, *)
    private func detectLanguage(for text: String) -> Locale.Language? {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        guard let dominant = recognizer.dominantLanguage else {
            return nil
        }
        return Locale.Language(identifier: dominant.rawValue)
    }

    @available(macOS 15.0, *)
    private func localeLanguage(from code: String) -> Locale.Language? {
        let normalized = code.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty, normalized != "auto" else {
            return nil
        }
        return Locale.Language(identifier: normalized)
    }

    @available(macOS 15.0, *)
    private func translateAll(
        text: String,
        sourceLanguage: Locale.Language,
        targetLanguages: [LanguageOption]
    ) async throws -> [OutputResult] {
        try await withThrowingTaskGroup(of: OutputResult.self) { group in
            for language in targetLanguages {
                group.addTask {
                    let targetLocale = self.localeLanguage(from: language.id)
                    guard let targetLocale else {
                        throw ProviderError.serviceError(String(localized: "error.apple.unsupportedLanguage"))
                    }
                    let translated = try await self.translate(
                        text: text,
                        sourceLanguage: sourceLanguage,
                        targetLanguage: targetLocale
                    )
                    return OutputResult(language: language, text: translated)
                }
            }

            var outputs: [OutputResult] = []
            for try await item in group {
                outputs.append(item)
            }
            return outputs
        }
    }

    @available(macOS 15.0, *)
    private func translate(
        text: String,
        sourceLanguage: Locale.Language,
        targetLanguage: Locale.Language
    ) async throws -> String {
        guard #available(macOS 26.0, *) else {
            throw ProviderError.serviceError(String(localized: "error.apple.requiresNewerOS"))
        }
        #if canImport(Translation)
            let availability = LanguageAvailability()
            let status = await availability.status(from: sourceLanguage, to: targetLanguage)
            guard status != .unsupported else {
                throw ProviderError.serviceError(String(localized: "error.apple.unsupportedLanguagePair"))
            }
            let session = TranslationSession(installedSource: sourceLanguage, target: targetLanguage)
            do {
                try await session.prepareTranslation()
                let response = try await session.translate(text)
                return response.targetText
            } catch {
                throw mapTranslationError(error)
            }
        #else
            throw ProviderError.serviceError(String(localized: "error.apple.unavailable"))
        #endif
    }

    @available(macOS 15.0, *)
    private func mapTranslationError(_ error: Error) -> ProviderError {
        #if canImport(Translation)
            if TranslationError.unsupportedLanguagePairing ~= error {
                return ProviderError.serviceError(String(localized: "error.apple.unsupportedLanguagePair"))
            }
            if TranslationError.unsupportedSourceLanguage ~= error
                || TranslationError.unsupportedTargetLanguage ~= error
            {
                return ProviderError.serviceError(String(localized: "error.apple.unsupportedLanguage"))
            }
            if TranslationError.unableToIdentifyLanguage ~= error {
                return ProviderError.serviceError(String(localized: "error.apple.unableToIdentifyLanguage"))
            }
            if TranslationError.nothingToTranslate ~= error {
                return ProviderError.serviceError(String(localized: "error.apple.nothingToTranslate"))
            }
            if #available(macOS 26.0, *), TranslationError.notInstalled ~= error {
                return ProviderError.serviceError(String(localized: "error.apple.notInstalled"))
            }
        #endif
        return ProviderError.serviceError(String(localized: "error.apple.generic"))
    }
}
