import Foundation

struct TaskSpecBuilder {
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
        case .synonyms:
            instructions.append(AIPrompts.synonymsInstruction)
            instructions.append(AIPrompts.synonymsRegisterInstruction)
        }

        return instructions.joined(separator: " ")
    }

    func userPrompt(for spec: TaskSpec) -> String {
        let languageCodes = spec.languages.map(\.code).joined(separator: ", ")
        return """
            \(AIPrompts.userModeLabel) \(spec.mode.rawValue)
            \(AIPrompts.userIntentLabel) \(spec.intent.rawValue)
            \(AIPrompts.userToneLabel) \(spec.tone.rawValue)
            \(AIPrompts.userTargetsLabel) \(languageCodes)

            \(AIPrompts.userInputLabel)
            \(spec.inputText)
            """
    }

    func estimateTokens(for text: String) -> Int {
        max(24, text.count / 4)
    }
}
