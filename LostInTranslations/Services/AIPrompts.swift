import Foundation

enum AIPrompts {
    static let systemBase = "You are a writing assistant for macOS."
    static let systemJSONFormat = """
        Return a strict JSON object with a top-level key \"results\" that is an array of \
        {\"language\":\"CODE\",\"text\":\"...\"}.
        """
    static let systemSafety = "Preserve names, numbers, and meaning. Avoid hallucinations."

    static let translateInstruction = "Translate into 2-3 target languages."
    static let translateToneInstruction = "Respect the intent and tone. Keep meaning."
    static let improveInstruction = "Rewrite to improve clarity in the same language unless targets are provided."
    static let improveToneInstruction = "Respect intent and tone."
    static let rephraseInstruction = "Rephrase with the same meaning in the same language."
    static let rephraseToneInstruction = "Respect intent and tone."
    static let synonymsInstruction = "Provide synonyms with short usage notes."
    static let synonymsRegisterInstruction = "Preserve register and avoid rare words unless asked."

    static let userModeLabel = "Mode:"
    static let userIntentLabel = "Intent:"
    static let userToneLabel = "Tone:"
    static let userTargetsLabel = "Target Languages:"
    static let userInputLabel = "Input:"
}
