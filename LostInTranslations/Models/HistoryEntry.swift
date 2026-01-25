import Foundation
import SwiftData

/// Persisted history entry stored by SwiftData.
@Model
final class HistoryEntry {
    /// Unique identifier for persistence.
    @Attribute(.unique) var id: UUID
    /// Creation timestamp.
    var createdAt: Date
    /// Hash of the input for de-duplication.
    var inputHash: String
    /// Stored mode identifier.
    var mode: String
    /// Stored intent identifier.
    var intent: String
    /// Stored tone identifier.
    var tone: String
    /// Stored language codes (comma-separated).
    var languages: String
    /// Stored provider identifier.
    var provider: String
    /// Stored model identifier.
    var model: String
    /// Stored outputs payload.
    var outputs: String

    /// Creates a SwiftData history entry.
    /// - Parameters:
    ///   - id: Unique identifier for persistence.
    ///   - createdAt: Creation timestamp.
    ///   - inputHash: Hash of the input for de-duplication.
    ///   - mode: Stored mode identifier.
    ///   - intent: Stored intent identifier.
    ///   - tone: Stored tone identifier.
    ///   - languages: Stored language codes (comma-separated).
    ///   - provider: Stored provider identifier.
    ///   - model: Stored model identifier.
    ///   - outputs: Stored outputs payload.
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
