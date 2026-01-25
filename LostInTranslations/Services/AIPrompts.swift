import Foundation

/// Prompt templates used to build provider requests.
enum AIPrompts {
    /// Base system prompt.
    static let systemBase = "You are a writing assistant for macOS."
    /// System prompt enforcing JSON response format.
    static let systemJSONFormat = """
        Return a strict JSON object with a top-level key \"results\" that is an array of \
        {\"language\":\"CODE\",\"text\":\"...\"}.
        """
    /// Safety instruction for system prompt.
    static let systemSafety = "Preserve names, numbers, and meaning. Avoid hallucinations."

    /// Instruction for translation tasks.
    static let translateInstruction = "Translate into 2-3 target languages."
    /// Instruction for translation tone.
    static let translateToneInstruction = "Respect the intent and tone. Keep meaning."
    /// Instruction for improve tasks.
    static let improveInstruction = "Rewrite to improve clarity in the same language unless targets are provided."
    /// Instruction for improve tone.
    static let improveToneInstruction = "Respect intent and tone."
    /// Instruction for rephrase tasks.
    static let rephraseInstruction = "Rephrase with the same meaning in the same language."
    /// Instruction for rephrase tone.
    static let rephraseToneInstruction = "Respect intent and tone."
    /// Instruction for synonyms tasks.
    static let synonymsInstruction = "Provide synonyms with short usage notes."
    /// Instruction for synonyms register.
    static let synonymsRegisterInstruction = "Preserve register and avoid rare words unless asked."

    /// User prompt label for mode.
    static let userModeLabel = "Mode:"
    /// User prompt label for intent.
    static let userIntentLabel = "Intent:"
    /// User prompt label for tone.
    static let userToneLabel = "Tone:"
    /// User prompt label for targets.
    static let userTargetsLabel = "Target Languages:"
    /// User prompt label for input.
    static let userInputLabel = "Input:"
}
