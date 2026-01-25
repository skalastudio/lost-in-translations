import Foundation

/// High-level purpose presets for shaping output.
enum Purpose: String, CaseIterable, Identifiable, Codable {
    case email
    case sms
    case chat
    case notes

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// User-facing title.
    var title: String {
        switch self {
        case .email:
            return String(localized: "purpose.email")
        case .sms:
            return String(localized: "purpose.sms")
        case .chat:
            return String(localized: "purpose.chat")
        case .notes:
            return String(localized: "purpose.notes")
        }
    }
}
