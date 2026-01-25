import Foundation

/// Supported language selections for the UI.
enum Language: String, CaseIterable, Identifiable, Codable, Sendable {
    case auto
    case english
    case portuguese
    case german

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// User-facing language name.
    var title: String {
        switch self {
        case .auto:
            return String(localized: "language.auto")
        case .english:
            return String(localized: "language.english")
        case .portuguese:
            return String(localized: "language.portuguese")
        case .german:
            return String(localized: "language.german")
        }
    }

    /// ISO-style language code.
    var code: String {
        switch self {
        case .auto:
            return "AUTO"
        case .english:
            return "EN"
        case .portuguese:
            return "PT"
        case .german:
            return "DE"
        }
    }

    /// Maps to provider language options when available.
    var asLanguageOption: LanguageOption? {
        switch self {
        case .auto:
            return nil
        case .english:
            return .english
        case .portuguese:
            return .portuguese
        case .german:
            return .german
        }
    }
}
