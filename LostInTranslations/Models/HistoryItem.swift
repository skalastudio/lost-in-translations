import Foundation

typealias HistoryItemID = UUID

struct HistoryItem: Identifiable, Hashable {
    let id: HistoryItemID
    let mode: AppMode
    let inputText: String
    let inputPreview: String
    let date: Date
    let targetLanguages: [Language]
    let purpose: Purpose
    let tone: Tone

    init(
        id: HistoryItemID = HistoryItemID(),
        mode: AppMode,
        inputText: String,
        inputPreview: String,
        date: Date,
        targetLanguages: [Language],
        purpose: Purpose,
        tone: Tone
    ) {
        self.id = id
        self.mode = mode
        self.inputText = inputText
        self.inputPreview = inputPreview
        self.date = date
        self.targetLanguages = targetLanguages
        self.purpose = purpose
        self.tone = tone
    }
}

extension HistoryItem {
    var subtitle: String {
        let languages = targetLanguages.map(\.code).joined(separator: ", ")
        return "\(purpose.title) · \(tone.localizedName) · \(languages)"
    }
}
