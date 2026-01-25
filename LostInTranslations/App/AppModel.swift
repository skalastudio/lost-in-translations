import Foundation

@MainActor
final class AppModel: ObservableObject {
    @Published var selectedMode: AppMode = .translate
    @Published var selectedPurpose: Purpose = .chat
    @Published var selectedTone: Tone = .neutral
    @Published var translateFromLanguage: Language = .auto
    @Published var translateTargetLanguages: [Language] = [.english]
    @Published var translateInputText: String = ""
    @Published var translateOutputs: [TranslationOutput] = []
    @Published var historyItems: [HistoryItem] = []
    @Published var storeHistoryLocally: Bool = true {
        didSet {
            if storeHistoryLocally {
                persistHistory()
            } else {
                historyItems = []
                deleteHistoryFile()
            }
        }
    }

    let maxTargetLanguages = 3

    init() {
        loadHistory()
    }

    var hasTranslateInput: Bool {
        !translateInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canTranslate: Bool {
        hasTranslateInput
    }

    var hasHistory: Bool {
        !historyItems.isEmpty
    }

    func addTargetLanguage(_ language: Language) {
        guard language != .auto else { return }
        guard !translateTargetLanguages.contains(language) else { return }
        guard translateTargetLanguages.count < maxTargetLanguages else { return }
        translateTargetLanguages.append(language)
    }

    func removeTargetLanguage(_ language: Language) {
        translateTargetLanguages.removeAll { $0 == language }
    }

    func performTranslateStub() {
        let trimmed = translateInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            translateOutputs = []
            return
        }
        guard !translateTargetLanguages.isEmpty else {
            translateOutputs = []
            return
        }
        let snippet = String(trimmed.prefix(120))
        translateOutputs = translateTargetLanguages.map { language in
            let headerPrefix =
                "[\(selectedPurpose.title) | \(selectedTone.localizedName) | \(translateFromLanguage.code) -> "
            let header = headerPrefix + "\(language.code)]"
            return TranslationOutput(
                language: language,
                text: """
                    \(header)
                    (Stub) Translated text: \(snippet)
                    """,
                purpose: selectedPurpose,
                tone: selectedTone
            )
        }

        let preview = String(trimmed.prefix(80))
        let historyItem = HistoryItem(
            mode: .translate,
            inputText: trimmed,
            inputPreview: preview,
            date: Date(),
            targetLanguages: translateTargetLanguages,
            purpose: selectedPurpose,
            tone: selectedTone
        )
        if storeHistoryLocally {
            historyItems.insert(historyItem, at: 0)
            persistHistory()
        }
    }

    func clearCurrentMode() {
        switch selectedMode {
        case .translate:
            translateInputText = ""
            translateOutputs = []
        case .improve, .rephrase, .synonyms, .history:
            break
        }
    }

    func clearHistory() {
        historyItems = []
        persistHistory()
    }

    private var historyFileURL: URL {
        let supportURL =
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory
        return
            supportURL
            .appendingPathComponent("LostInTranslations", isDirectory: true)
            .appendingPathComponent("history.json")
    }

    private func loadHistory() {
        guard storeHistoryLocally else { return }
        do {
            let data = try Data(contentsOf: historyFileURL)
            historyItems = try JSONDecoder().decode([HistoryItem].self, from: data)
        } catch {
            historyItems = []
        }
    }

    private func persistHistory() {
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

    private func deleteHistoryFile() {
        do {
            try FileManager.default.removeItem(at: historyFileURL)
        } catch {
            // Ignore missing files or delete failures.
        }
    }
}
