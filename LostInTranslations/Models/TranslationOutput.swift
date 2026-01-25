import Foundation

struct TranslationOutput: Identifiable, Hashable {
    let id: UUID
    let language: Language
    let text: String
    let purpose: Purpose
    let tone: Tone
    let isLoading: Bool
    let errorMessage: String?

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
    var purposeTitle: String { purpose.title }
    var toneTitle: String { tone.localizedName }
}
