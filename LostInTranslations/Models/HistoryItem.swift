import Foundation

/// Unique identifier type for history items.
typealias HistoryItemID = UUID

/// Snapshot of a past translation action.
struct HistoryItem: Identifiable, Hashable, Codable {
    /// Stable identifier for selection.
    let id: HistoryItemID
    /// The mode that produced the history item.
    let mode: AppMode
    /// Full input text.
    let inputText: String
    /// Short input preview for list display.
    let inputPreview: String
    /// Timestamp of the action.
    let date: Date
    /// Target languages used.
    let targetLanguages: [Language]
    /// Purpose used for the action.
    let purpose: Purpose
    /// Tone used for the action.
    let tone: Tone

    /// Creates a history item.
    /// - Parameters:
    ///   - id: Stable identifier for selection.
    ///   - mode: The mode that produced the history item.
    ///   - inputText: Full input text.
    ///   - inputPreview: Short input preview for list display.
    ///   - date: Timestamp of the action.
    ///   - targetLanguages: Target languages used.
    ///   - purpose: Purpose used for the action.
    ///   - tone: Tone used for the action.
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
    /// Composed subtitle for list display.
    var subtitle: String {
        let languages = targetLanguages.map(\.code).joined(separator: ", ")
        return "\(purpose.title) · \(tone.localizedName) · \(languages)"
    }
}
