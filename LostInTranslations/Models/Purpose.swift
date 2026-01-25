import Foundation

enum Purpose: String, CaseIterable, Identifiable, Codable {
    case email
    case sms
    case chat
    case notes

    var id: String { rawValue }

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
