import Foundation

/// App navigation modes shown in the sidebar.
enum AppMode: String, CaseIterable, Identifiable, Codable {
    case translate
    case improve
    case rephrase
    case synonyms
    case history

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// User-facing display name.
    var displayName: String {
        switch self {
        case .translate:
            return String(localized: "mode.translate")
        case .improve:
            return String(localized: "mode.improveText")
        case .rephrase:
            return String(localized: "mode.rephrase")
        case .synonyms:
            return String(localized: "mode.synonyms")
        case .history:
            return String(localized: "mode.history")
        }
    }
}

extension AppMode {
    /// Capability required to use the mode.
    var requiredCapability: ProviderCapability? {
        switch self {
        case .translate:
            return .translate
        case .improve:
            return .improve
        case .rephrase:
            return .rephrase
        case .synonyms:
            return .synonyms
        case .history:
            return nil
        }
    }
}
