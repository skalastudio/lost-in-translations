import Foundation

/// Core task modes supported by provider requests.
enum WritingMode: String, CaseIterable, Identifiable, Sendable {
    case translate = "Translate"
    case improve = "Improve"
    case rephrase = "Rephrase"
    case synonyms = "Synonyms"

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// Localized display name.
    var localizedName: String {
        switch self {
        case .translate:
            return String(localized: "writingMode.translate")
        case .improve:
            return String(localized: "writingMode.improve")
        case .rephrase:
            return String(localized: "writingMode.rephrase")
        case .synonyms:
            return String(localized: "writingMode.synonyms")
        }
    }
}

/// Intent presets used to shape output formatting.
enum WritingIntent: String, CaseIterable, Identifiable, Sendable {
    case email = "Email"
    case sms = "SMS"
    case chat = "Chat"
    case plainText = "Plain Text"

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// Localized display name.
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

/// Tone presets used to guide writing style.
enum Tone: String, CaseIterable, Identifiable, Sendable, Codable {
    case neutral = "Neutral"
    case formal = "Formal"
    case informal = "Informal"
    case professional = "Professional"
    case friendly = "Friendly"
    case direct = "Direct"

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// Localized display name.
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

/// Supported external providers.
enum Provider: String, CaseIterable, Identifiable, Sendable {
    case auto = "Auto"
    case openAI = "OpenAI"
    case claude = "Claude"
    case gemini = "Gemini"

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// Localized display name.
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

/// Model tier presets.
enum ModelTier: String, CaseIterable, Identifiable, Sendable {
    case fast = "Fast"
    case balanced = "Balanced"
    case best = "Best"

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// Localized display name.
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

/// Improve text presets for refinement.
enum ImprovePreset: String, CaseIterable, Identifiable, Sendable {
    case shorter
    case moreFormal
    case moreFriendly

    /// Stable identifier for list rendering.
    var id: String { rawValue }

    /// User-facing title.
    var title: String {
        switch self {
        case .shorter:
            return "Shorter"
        case .moreFormal:
            return "More formal"
        case .moreFriendly:
            return "More friendly"
        }
    }

    /// Provider instruction text for the preset.
    var instruction: String {
        switch self {
        case .shorter:
            return "Make the text shorter while preserving meaning."
        case .moreFormal:
            return "Make the text more formal while preserving meaning."
        case .moreFriendly:
            return "Make the text more friendly while preserving meaning."
        }
    }
}

/// Provider language option metadata.
struct LanguageOption: Identifiable, Hashable, Sendable {
    /// Stable identifier used in settings.
    let id: String
    /// Human-readable language name.
    let name: String
    /// Language code for provider requests.
    let code: String

    /// Localized display name for the option.
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

    /// English preset option.
    static let english = LanguageOption(id: "en", name: "English", code: "EN")
    /// Portuguese preset option.
    static let portuguese = LanguageOption(id: "pt", name: "Portuguese", code: "PT")
    /// German preset option.
    static let german = LanguageOption(id: "de", name: "German", code: "DE")
    /// French preset option.
    static let french = LanguageOption(id: "fr", name: "French", code: "FR")
    /// Spanish preset option.
    static let spanish = LanguageOption(id: "es", name: "Spanish", code: "ES")
    /// Italian preset option.
    static let italian = LanguageOption(id: "it", name: "Italian", code: "IT")
    /// Japanese preset option.
    static let japanese = LanguageOption(id: "ja", name: "Japanese", code: "JA")

    /// Default preset options used by the UI.
    static let presets: [LanguageOption] = [.portuguese, .english, .german]
    /// All supported provider language options.
    static let all: [LanguageOption] = [.english, .portuguese, .german, .french, .spanish, .italian, .japanese]
}

/// Single language output from a provider response.
struct OutputResult: Identifiable, Hashable, Sendable {
    /// Stable identifier for list rendering.
    let id = UUID()
    /// The output language.
    let language: LanguageOption
    /// The generated text.
    let text: String
}

/// Result from a provider in compare mode.
struct CompareResult: Identifiable, Hashable, Sendable {
    /// Stable identifier for list rendering.
    let id = UUID()
    /// Provider that produced the result.
    let provider: Provider
    /// Model identifier returned by the provider.
    let model: String?
    /// Output results for the provider.
    let results: [OutputResult]
    /// Optional error message for the provider.
    let errorMessage: String?
    /// Whether the provider is still running.
    let isLoading: Bool
    /// Whether the provider succeeded.
    let isSuccess: Bool
    /// Request latency in milliseconds.
    let latencyMs: Int?
}

/// Diagnostics captured from the latest run.
struct DiagnosticsState: Hashable, Sendable {
    /// Last provider used for a request.
    var lastProvider: Provider?
    /// Last model identifier returned.
    var lastModel: String?
    /// Estimated token count.
    var tokenEstimate: Int?
    /// Observed latency in milliseconds.
    var latencyMs: Int?
    /// Last error message, if any.
    var lastError: String?
}
