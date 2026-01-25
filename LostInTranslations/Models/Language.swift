import Foundation

enum Language: String, CaseIterable, Identifiable, Codable, Sendable {
    case auto
    case english
    case portuguese
    case german

    var id: String { rawValue }

    var title: String {
        switch self {
        case .auto:
            return "Auto"
        case .english:
            return "English"
        case .portuguese:
            return "Portuguese"
        case .german:
            return "German"
        }
    }

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
