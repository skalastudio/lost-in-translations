import Foundation
import SwiftData

/// Simple SwiftData store for history entries.
@MainActor
final class HistoryStore {
    /// SwiftData container used for persistence.
    private let container: ModelContainer

    /// Creates a history store backed by a model container.
    /// - Parameter container: The SwiftData container.
    init(container: ModelContainer) {
        self.container = container
    }

    /// Saves a history entry.
    /// - Parameter entry: The entry to save.
    func save(entry: HistoryEntry) throws {
        let context = container.mainContext
        context.insert(entry)
        try context.save()
    }

    /// Clears all stored history entries.
    func clearAll() throws {
        let context = container.mainContext
        let descriptor = FetchDescriptor<HistoryEntry>()
        let entries = try context.fetch(descriptor)
        for entry in entries {
            context.delete(entry)
        }
        try context.save()
    }
}
