import Foundation

enum AppMode: String, CaseIterable, Identifiable, Codable {
    case translate
    case improve
    case rephrase
    case synonyms
    case history

    var id: String { rawValue }

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
