import Foundation

/// Provider model identifiers used for selection.
enum ModelCatalogConstants {
    /// Provider-specific advanced model identifiers.
    static let advancedModels: [Provider: [String]] = [
        .openAI: ["gpt-4o-mini", "gpt-4o", "gpt-4-turbo"],
        .claude: [
            "claude-3-5-haiku-latest",
            "claude-3-5-sonnet-latest",
            "claude-3-5-opus-latest",
        ],
        .gemini: ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-2.0-flash"],
        .appleTranslation: [],
    ]

    /// Default model identifiers per provider and tier.
    static let defaultModels: [Provider: [ModelTier: String]] = [
        .openAI: [
            .fast: "gpt-4o-mini",
            .balanced: "gpt-4o",
            .best: "gpt-4-turbo",
        ],
        .claude: [
            .fast: "claude-3-5-haiku-latest",
            .balanced: "claude-3-5-sonnet-latest",
            .best: "claude-3-5-opus-latest",
        ],
        .gemini: [
            .fast: "gemini-1.5-flash",
            .balanced: "gemini-2.0-flash",
            .best: "gemini-2.0-flash",
        ],
        .appleTranslation: [
            .fast: "apple-translation",
            .balanced: "apple-translation",
            .best: "apple-translation",
        ],
    ]

    /// Placeholder used when model selection is automatic.
    static let autoModelPlaceholder = "auto"
}
