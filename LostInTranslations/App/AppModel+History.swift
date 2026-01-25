import Foundation

extension AppModel {
    /// Clears all history entries and persists the change.
    func clearHistory() {
        historyItems = []
        persistHistory()
    }

    /// Appends a translate history item and persists it.
    /// - Parameters:
    ///   - inputText: Full input text.
    ///   - targets: Target languages used.
    ///   - purpose: Purpose used.
    ///   - tone: Tone used.
    func appendHistory(
        inputText: String,
        targets: [Language],
        purpose: Purpose,
        tone: Tone
    ) {
        guard storeHistoryLocally else { return }
        let preview = String(inputText.prefix(80))
        let historyItem = HistoryItem(
            mode: .translate,
            inputText: inputText,
            inputPreview: preview,
            date: Date(),
            targetLanguages: targets,
            purpose: purpose,
            tone: tone
        )
        historyItems.insert(historyItem, at: 0)
        persistHistory()
    }

    /// File location used for local history storage.
    private var historyFileURL: URL {
        let supportURL =
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory
        return
            supportURL
            .appendingPathComponent("LostInTranslations", isDirectory: true)
            .appendingPathComponent("history.json")
    }

    /// Loads history from disk if enabled.
    func loadHistory() {
        guard storeHistoryLocally else { return }
        do {
            let data = try Data(contentsOf: historyFileURL)
            historyItems = try JSONDecoder().decode([HistoryItem].self, from: data)
        } catch {
            historyItems = []
        }
    }

    /// Persists current history to disk if enabled.
    func persistHistory() {
        guard storeHistoryLocally else { return }
        do {
            let folderURL = historyFileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(historyItems)
            try data.write(to: historyFileURL, options: .atomic)
        } catch {
            // Silent failure for local-only history persistence.
        }
    }

    /// Deletes the on-disk history file if present.
    func deleteHistoryFile() {
        do {
            try FileManager.default.removeItem(at: historyFileURL)
        } catch {
            // Ignore missing files or delete failures.
        }
    }
}
