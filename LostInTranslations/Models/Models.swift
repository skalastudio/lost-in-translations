import Foundation

enum WritingMode: String, CaseIterable, Identifiable, Sendable {
    case translate = "Translate"
    case improve = "Improve"
    case synonyms = "Synonyms"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .translate:
            return String(localized: "writingMode.translate")
        case .improve:
            return String(localized: "writingMode.improve")
        case .synonyms:
            return String(localized: "writingMode.synonyms")
        }
    }
}

enum WritingIntent: String, CaseIterable, Identifiable, Sendable {
    case email = "Email"
    case sms = "SMS"
    case chat = "Chat"
    case plainText = "Plain Text"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .email:
            return String(localized: "writingIntent.email")
        case .sms:
            return String(localized: "writingIntent.sms")
        case .chat:
            return String(localized: "writingIntent.chat")
        case .plainText:
            return String(localized: "writingIntent.plainText")
        }
    }
}

enum Tone: String, CaseIterable, Identifiable, Sendable, Codable {
    case neutral = "Neutral"
    case formal = "Formal"
    case informal = "Informal"
    case professional = "Professional"
    case friendly = "Friendly"
    case direct = "Direct"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .neutral:
            return String(localized: "tone.neutral")
        case .formal:
            return String(localized: "tone.formal")
        case .informal:
            return String(localized: "tone.informal")
        case .professional:
            return String(localized: "tone.professional")
        case .friendly:
            return String(localized: "tone.friendly")
        case .direct:
            return String(localized: "tone.direct")
        }
    }
}

enum Provider: String, CaseIterable, Identifiable, Sendable {
    case auto = "Auto"
    case openAI = "OpenAI"
    case claude = "Claude"
    case gemini = "Gemini"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .auto:
            return String(localized: "provider.auto")
        case .openAI:
            return String(localized: "provider.openai")
        case .claude:
            return String(localized: "provider.claude")
        case .gemini:
            return String(localized: "provider.gemini")
        }
    }
}

enum ModelTier: String, CaseIterable, Identifiable, Sendable {
    case fast = "Fast"
    case balanced = "Balanced"
    case best = "Best"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .fast:
            return String(localized: "modelTier.fast")
        case .balanced:
            return String(localized: "modelTier.balanced")
        case .best:
            return String(localized: "modelTier.best")
        }
    }
}

struct LanguageOption: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let code: String

    var localizedName: String {
        switch id {
        case "en":
            return String(localized: "language.english")
        case "pt":
            return String(localized: "language.portuguese")
        case "de":
            return String(localized: "language.german")
        case "fr":
            return String(localized: "language.french")
        case "es":
            return String(localized: "language.spanish")
        case "it":
            return String(localized: "language.italian")
        case "ja":
            return String(localized: "language.japanese")
        default:
            return name
        }
    }

    static let english = LanguageOption(id: "en", name: "English", code: "EN")
    static let portuguese = LanguageOption(id: "pt", name: "Portuguese", code: "PT")
    static let german = LanguageOption(id: "de", name: "German", code: "DE")
    static let french = LanguageOption(id: "fr", name: "French", code: "FR")
    static let spanish = LanguageOption(id: "es", name: "Spanish", code: "ES")
    static let italian = LanguageOption(id: "it", name: "Italian", code: "IT")
    static let japanese = LanguageOption(id: "ja", name: "Japanese", code: "JA")

    static let presets: [LanguageOption] = [.portuguese, .english, .german]
    static let all: [LanguageOption] = [.english, .portuguese, .german, .french, .spanish, .italian, .japanese]
}

struct OutputResult: Identifiable, Hashable, Sendable {
    let id = UUID()
    let language: LanguageOption
    let text: String
}

struct CompareResult: Identifiable, Hashable, Sendable {
    let id = UUID()
    let provider: Provider
    let model: String?
    let results: [OutputResult]
    let errorMessage: String?
    let isLoading: Bool
    let isSuccess: Bool
    let latencyMs: Int?
}

struct DiagnosticsState: Hashable, Sendable {
    var lastProvider: Provider?
    var lastModel: String?
    var tokenEstimate: Int?
    var latencyMs: Int?
    var lastError: String?
}
