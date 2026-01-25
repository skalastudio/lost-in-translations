import CryptoKit
import Foundation

/// History helpers for MainViewModel.
extension MainViewModel {
    /// Clears all stored history entries.
    func clearHistory() {
        guard let historyStore else { return }
        do {
            try historyStore.clearAll()
        } catch {
            lastInlineError = error.localizedDescription
        }
    }

    /// Builds a task specification for the current settings.
    func buildSpec() -> TaskSpec {
        TaskSpec(
            inputText: inputText,
            mode: mode,
            intent: intent,
            tone: tone,
            provider: provider,
            modelTier: modelTier,
            languages: selectedLanguages,
            sourceLanguage: nil,
            extraInstruction: nil
        )
    }

    /// Saves task output to history.
    /// - Parameter output: Task output to store.
    func saveHistory(output: TaskRunOutput) throws {
        guard let historyStore else { return }
        let outputsSerialized = output.results
            .map { "\($0.language.code):\($0.text)" }
            .joined(separator: "\n")
        let languageCodes = selectedLanguages.map(\.code).joined(separator: ",")
        let entry = HistoryEntry(
            inputHash: hashInput(inputText),
            mode: mode.rawValue,
            intent: intent.rawValue,
            tone: tone.rawValue,
            languages: languageCodes,
            provider: output.provider.rawValue,
            model: output.model,
            outputs: outputsSerialized
        )
        try historyStore.save(entry: entry)
    }

    /// Saves a compare result to history.
    /// - Parameter result: Compare result to store.
    func saveCompareHistory(result: CompareResult) throws {
        guard let historyStore else { return }
        let outputsSerialized = result.results
            .map { "\($0.language.code):\($0.text)" }
            .joined(separator: "\n")
        let languageCodes = selectedLanguages.map(\.code).joined(separator: ",")
        let entry = HistoryEntry(
            inputHash: hashInput(inputText),
            mode: mode.rawValue,
            intent: intent.rawValue,
            tone: tone.rawValue,
            languages: languageCodes,
            provider: result.provider.rawValue,
            model: result.model ?? "unknown",
            outputs: outputsSerialized
        )
        try historyStore.save(entry: entry)
    }

    /// Hashes input text for de-duplication.
    /// - Parameter text: Input text to hash.
    /// - Returns: SHA-256 hash string.
    func hashInput(_ text: String) -> String {
        let data = Data(text.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
