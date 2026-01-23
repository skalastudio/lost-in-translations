import Foundation

struct ModelCatalog {
    static let advancedModels: [Provider: [String]] = [
        .openAI: ["gpt-4o-mini", "gpt-4o", "gpt-4-turbo"],
        .claude: [
            "claude-3-5-haiku-latest",
            "claude-3-5-sonnet-latest",
            "claude-3-5-opus-latest",
        ],
        .gemini: ["gemini-1.5-flash", "gemini-1.5-pro", "gemini-2.0-flash"],
    ]

    static func defaultModel(for provider: Provider, tier: ModelTier) -> String {
        switch provider {
        case .openAI:
            switch tier {
            case .fast:
                return "gpt-4o-mini"
            case .balanced:
                return "gpt-4o"
            case .best:
                return "gpt-4-turbo"
            }
        case .claude:
            switch tier {
            case .fast:
                return "claude-3-5-haiku-latest"
            case .balanced:
                return "claude-3-5-sonnet-latest"
            case .best:
                return "claude-3-5-opus-latest"
            }
        case .gemini:
            return tier == .fast ? "gemini-1.5-flash" : "gemini-2.0-flash"
        case .auto:
            return "auto"
        }
    }
}
