import Foundation
import SwiftData

@MainActor
final class HistoryStore {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    func save(entry: HistoryEntry) throws {
        let context = container.mainContext
        context.insert(entry)
        try context.save()
    }

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
