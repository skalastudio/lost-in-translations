import Foundation

struct ModelCatalog {
    static let advancedModels: [Provider: [String]] = [
        .openAI: ["gpt-4o-mini", "gpt-4o", "gpt-4.1"],
        .claude: [
            "claude-3-haiku-20240307",
            "claude-3-5-sonnet-20240620",
            "claude-3-opus-20240229",
        ],
        .gemini: ["gemini-1.5-flash", "gemini-1.5-pro"],
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
                return "gpt-4.1"
            }
        case .claude:
            switch tier {
            case .fast:
                return "claude-3-haiku-20240307"
            case .balanced:
                return "claude-3-5-sonnet-20240620"
            case .best:
                return "claude-3-opus-20240229"
            }
        case .gemini:
            return tier == .fast ? "gemini-1.5-flash" : "gemini-1.5-pro"
        case .auto:
            return "auto"
        }
    }
}
