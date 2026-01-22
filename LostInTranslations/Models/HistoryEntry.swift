import Foundation
import SwiftData

@Model
final class HistoryEntry {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var inputHash: String
    var mode: String
    var intent: String
    var tone: String
    var languages: String
    var provider: String
    var model: String
    var outputs: String

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        inputHash: String,
        mode: String,
        intent: String,
        tone: String,
        languages: String,
        provider: String,
        model: String,
        outputs: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.inputHash = inputHash
        self.mode = mode
        self.intent = intent
        self.tone = tone
        self.languages = languages
        self.provider = provider
        self.model = model
        self.outputs = outputs
    }
}
