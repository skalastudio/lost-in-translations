import Foundation

struct TranslationOutput: Identifiable, Hashable {
    let id: UUID
    let language: Language
    let text: String
    let purpose: Purpose
    let tone: Tone

    init(
        id: UUID = UUID(),
        language: Language,
        text: String,
        purpose: Purpose,
        tone: Tone
    ) {
        self.id = id
        self.language = language
        self.text = text
        self.purpose = purpose
        self.tone = tone
    }
}

extension TranslationOutput {
    var purposeTitle: String { purpose.title }
    var toneTitle: String { tone.localizedName }
}
