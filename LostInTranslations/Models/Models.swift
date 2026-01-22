import Foundation

enum WritingMode: String, CaseIterable, Identifiable {
    case translate = "Translate"
    case improve = "Improve"
    case synonyms = "Synonyms"

    var id: String { rawValue }
}

enum WritingIntent: String, CaseIterable, Identifiable {
    case email = "Email"
    case sms = "SMS"
    case chat = "Chat"
    case plainText = "Plain Text"

    var id: String { rawValue }
}

enum Tone: String, CaseIterable, Identifiable {
    case neutral = "Neutral"
    case formal = "Formal"
    case informal = "Informal"
    case professional = "Professional"
    case friendly = "Friendly"
    case direct = "Direct"

    var id: String { rawValue }
}

enum Provider: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case openAI = "OpenAI"
    case claude = "Claude"
    case gemini = "Gemini"

    var id: String { rawValue }
}

enum ModelTier: String, CaseIterable, Identifiable {
    case fast = "Fast"
    case balanced = "Balanced"
    case best = "Best"

    var id: String { rawValue }
}

struct LanguageOption: Identifiable, Hashable {
    let id: String
    let name: String
    let code: String

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

struct OutputResult: Identifiable, Hashable {
    let id = UUID()
    let language: LanguageOption
    let text: String
}

struct CompareResult: Identifiable, Hashable {
    let id = UUID()
    let provider: Provider
    let model: String?
    let results: [OutputResult]
    let errorMessage: String?
    let isLoading: Bool
    let isSuccess: Bool
    let latencyMs: Int?
}

struct DiagnosticsState: Hashable {
    var lastProvider: Provider?
    var lastModel: String?
    var tokenEstimate: Int?
    var latencyMs: Int?
    var lastError: String?
}
