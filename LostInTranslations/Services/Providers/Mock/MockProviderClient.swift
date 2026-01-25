import Foundation

struct MockProviderClient: ProviderClient {
    let provider: Provider

    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult {
        let results = buildResults(for: spec)
        let model = "mock-\(spec.modelTier.rawValue.lowercased())"
        return ProviderResult(results: results, model: model)
    }

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

    private func mockTranslation(for spec: TaskSpec, language: LanguageOption) -> String {
        let toneLine = toneFlavor(for: spec.tone)
        let samples = [
            "Translation (\(language.code)) — \(toneLine): \(spec.inputText)",
            "\(language.name) version, \(toneLine): \(spec.inputText)",
            "In \(language.name) (\(toneLine)): \(spec.inputText)",
        ]
        return samples.randomElement() ?? "\(language.name): \(spec.inputText)"
    }

    private func mockImprovement(for spec: TaskSpec) -> String {
        let toneLine = toneFlavor(for: spec.tone)
        let templates = [
            "\(toneLine) rewrite: \(spec.inputText)",
            "Improved (\(toneLine)): \(spec.inputText)",
            "\(toneLine) phrasing: \(spec.inputText)",
        ]
        return templates.randomElement() ?? spec.inputText
    }

    private func mockRephrase(for spec: TaskSpec) -> String {
        let toneLine = toneFlavor(for: spec.tone)
        let templates = [
            "Rephrase (\(toneLine)): \(spec.inputText)",
            "Same meaning, new phrasing (\(toneLine)): \(spec.inputText)",
            "Alternate phrasing (\(toneLine)): \(spec.inputText)",
        ]
        return templates.randomElement() ?? spec.inputText
    }

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
