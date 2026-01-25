import Foundation

/// Builds system and user prompts for provider requests.
struct TaskSpecBuilder {
    /// Returns the system prompt for the given spec.
    /// - Parameter spec: The task specification.
    /// - Returns: System prompt string.
    func systemPrompt(for spec: TaskSpec) -> String {
        var instructions = [
            AIPrompts.systemBase,
            AIPrompts.systemJSONFormat,
            AIPrompts.systemSafety,
        ]

        switch spec.mode {
        case .translate:
            instructions.append(AIPrompts.translateInstruction)
            instructions.append(AIPrompts.translateToneInstruction)
        case .improve:
            instructions.append(AIPrompts.improveInstruction)
            instructions.append(AIPrompts.improveToneInstruction)
        case .rephrase:
            instructions.append(AIPrompts.rephraseInstruction)
            instructions.append(AIPrompts.rephraseToneInstruction)
        case .synonyms:
            instructions.append(AIPrompts.synonymsInstruction)
            instructions.append(AIPrompts.synonymsRegisterInstruction)
        }

        return instructions.joined(separator: " ")
    }

    /// Returns the user prompt for the given spec.
    /// - Parameter spec: The task specification.
    /// - Returns: User prompt string.
    func userPrompt(for spec: TaskSpec) -> String {
        let languageCodes = spec.languages.map(\.code).joined(separator: ", ")
        let sourceLanguage = spec.sourceLanguage ?? "Auto"
        let extra = spec.extraInstruction?.trimmingCharacters(in: .whitespacesAndNewlines)
        let extraLine = extra?.isEmpty == false ? "Extra: \(extra!)\n" : ""
        return """
            \(AIPrompts.userModeLabel) \(spec.mode.rawValue)
            \(AIPrompts.userIntentLabel) \(spec.intent.rawValue)
            \(AIPrompts.userToneLabel) \(spec.tone.rawValue)
            Source: \(sourceLanguage)
            \(AIPrompts.userTargetsLabel) \(languageCodes)

            \(AIPrompts.userInputLabel)
            \(extraLine)
            \(spec.inputText)
            """
    }

    /// Estimates token count based on text length.
    /// - Parameter text: Input text.
    /// - Returns: Estimated token count.
    func estimateTokens(for text: String) -> Int {
        max(24, text.count / 4)
    }
}
