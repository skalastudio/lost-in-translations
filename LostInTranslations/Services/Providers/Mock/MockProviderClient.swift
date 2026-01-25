import Foundation

/// Mock provider client used for development and tests.
struct MockProviderClient: ProviderClient {
    /// Provider identifier for labeling results.
    let provider: Provider

    /// Executes a task with mock responses.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - apiKey: API key placeholder (unused).
    /// - Returns: Mock provider result payload.
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let results = buildResults(for: spec)
        let model = "mock-\(spec.modelTier.rawValue.lowercased())"
        return ProviderResult(results: results, model: model)
    }

    /// Builds mock results for a given task specification.
    /// - Parameter spec: The task specification.
    /// - Returns: Mock output results.
    private func buildResults(for spec: TaskSpec) -> [OutputResult] {
        switch spec.mode {
        case .translate:
            let languages = spec.languages.isEmpty ? [.english] : spec.languages
            return languages.map { language in
                OutputResult(language: language, text: mockTranslation(for: spec, language: language))
            }
        case .improve:
            let language = spec.languages.first ?? .english
            return [OutputResult(language: language, text: mockImprovement(for: spec))]
        case .rephrase:
            let language = spec.languages.first ?? .english
            return [OutputResult(language: language, text: mockRephrase(for: spec))]
        case .synonyms:
            let language = spec.languages.first ?? .english
            return [OutputResult(language: language, text: mockSynonyms(for: spec))]
        }
    }

    /// Returns a mock translation string.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - language: Target language.
    /// - Returns: Mock translation text.
    private func mockTranslation(for spec: TaskSpec, language: LanguageOption) -> String {
        let toneLine = toneFlavor(for: spec.tone)
        let samples = [
            "Translation (\(language.code)) — \(toneLine): \(spec.inputText)",
            "\(language.name) version, \(toneLine): \(spec.inputText)",
            "In \(language.name) (\(toneLine)): \(spec.inputText)",
        ]
        return samples.randomElement() ?? "\(language.name): \(spec.inputText)"
    }

    /// Returns a mock improvement string.
    /// - Parameter spec: The task specification.
    /// - Returns: Mock improvement text.
    private func mockImprovement(for spec: TaskSpec) -> String {
        let toneLine = toneFlavor(for: spec.tone)
        let templates = [
            "\(toneLine) rewrite: \(spec.inputText)",
            "Improved (\(toneLine)): \(spec.inputText)",
            "\(toneLine) phrasing: \(spec.inputText)",
        ]
        return templates.randomElement() ?? spec.inputText
    }

    /// Returns a mock rephrase string.
    /// - Parameter spec: The task specification.
    /// - Returns: Mock rephrase text.
    private func mockRephrase(for spec: TaskSpec) -> String {
        let toneLine = toneFlavor(for: spec.tone)
        let templates = [
            "Rephrase (\(toneLine)): \(spec.inputText)",
            "Same meaning, new phrasing (\(toneLine)): \(spec.inputText)",
            "Alternate phrasing (\(toneLine)): \(spec.inputText)",
        ]
        return templates.randomElement() ?? spec.inputText
    }

    /// Returns a mock synonyms string.
    /// - Parameter spec: The task specification.
    /// - Returns: Mock synonyms text.
    private func mockSynonyms(for spec: TaskSpec) -> String {
        let toneLine = toneFlavor(for: spec.tone)
        let synonymSets = [
            ["clear", "plain", "direct"],
            ["polished", "refined", "elevated"],
            ["friendly", "warm", "approachable"],
            ["concise", "tight", "succinct"],
        ]
        let picks = synonymSets.randomElement() ?? ["clear", "direct", "plain"]
        return "Synonyms (\(toneLine)): \(picks.joined(separator: ", "))"
    }

    /// Maps a tone to a brief descriptor.
    /// - Parameter tone: Selected tone.
    /// - Returns: Human-readable tone label.
    private func toneFlavor(for tone: Tone) -> String {
        switch tone {
        case .neutral:
            return "neutral"
        case .formal:
            return "formal"
        case .informal:
            return "informal"
        case .professional:
            return "professional"
        case .friendly:
            return "friendly"
        case .direct:
            return "direct"
        }
    }
}
