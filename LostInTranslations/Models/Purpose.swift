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
            return "Email"
        case .sms:
            return "SMS"
        case .chat:
            return "Chat"
        case .notes:
            return "Notes"
        }
    }
}
