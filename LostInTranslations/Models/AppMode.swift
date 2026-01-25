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
            return "Translate"
        case .improve:
            return "Improve"
        case .rephrase:
            return "Rephrase"
        case .synonyms:
            return "Synonyms"
        case .history:
            return "History"
        }
    }
}
