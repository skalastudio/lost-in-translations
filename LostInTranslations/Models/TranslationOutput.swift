import Foundation

/// Represents a translation output for a single target language.
struct TranslationOutput: Identifiable, Hashable {
    /// Stable identifier for list rendering.
    let id: UUID
    /// The output language.
    let language: Language
    /// The translated text.
    let text: String
    /// The purpose used to shape the translation.
    let purpose: Purpose
    /// The tone used to shape the translation.
    let tone: Tone
    /// Whether the output is currently loading.
    let isLoading: Bool
    /// Optional error message for the output.
    let errorMessage: String?

    /// Creates a translation output value.
    /// - Parameters:
    ///   - id: Stable identifier for list rendering.
    ///   - language: The output language.
    ///   - text: The translated text.
    ///   - purpose: The purpose used to shape the translation.
    ///   - tone: The tone used to shape the translation.
    ///   - isLoading: Whether the output is currently loading.
    ///   - errorMessage: Optional error message for the output.
    init(
        id: UUID = UUID(),
        language: Language,
        text: String,
        purpose: Purpose,
        tone: Tone,
        isLoading: Bool = false,
        errorMessage: String? = nil
    ) {
        self.id = id
        self.language = language
        self.text = text
        self.purpose = purpose
        self.tone = tone
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
}

extension TranslationOutput {
    /// Display title for the purpose.
    var purposeTitle: String { purpose.title }
    /// Display title for the tone.
    var toneTitle: String { tone.localizedName }
}
