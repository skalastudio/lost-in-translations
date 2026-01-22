import Foundation

struct TaskSpecBuilder {
    func systemPrompt(for spec: TaskSpec) -> String {
        var instructions = [
            "You are a writing assistant for macOS.",
            """
            Return a strict JSON object with a top-level key "results" that is an array of \
            {"language":"CODE","text":"..."}.
            """,
            "Preserve names, numbers, and meaning. Avoid hallucinations.",
        ]

        switch spec.mode {
        case .translate:
            instructions.append("Translate into 2-3 target languages.")
            instructions.append("Respect the intent and tone. Keep meaning.")
        case .improve:
            instructions.append("Rewrite to improve clarity in the same language unless targets are provided.")
            instructions.append("Respect intent and tone.")
        case .synonyms:
            instructions.append("Provide synonyms with short usage notes.")
            instructions.append("Preserve register and avoid rare words unless asked.")
        }

        return instructions.joined(separator: " ")
    }

    func userPrompt(for spec: TaskSpec) -> String {
        let languageCodes = spec.languages.map(\.code).joined(separator: ", ")
        return """
            Mode: \(spec.mode.rawValue)
            Intent: \(spec.intent.rawValue)
            Tone: \(spec.tone.rawValue)
            Target Languages: \(languageCodes)

            Input:
            \(spec.inputText)
            """
    }

    func estimateTokens(for text: String) -> Int {
        max(24, text.count / 4)
    }
}
