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
    @Published var translateIsRunning: Bool = false
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
    private let taskRunner = TaskRunner()
    private var translateTask: Task<Void, Never>?

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
    }

    func performTranslate() {
        cancelTranslate()
        let trimmed = translateInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            translateOutputs = []
            return
        }
        let targets = translateTargetLanguages.filter { $0 != .auto }
        guard !targets.isEmpty else {
            translateOutputs = []
            return
        }
        translateIsRunning = true
        translateOutputs = targets.map { language in
            TranslationOutput(
                language: language,
                text: "",
                purpose: selectedPurpose,
                tone: selectedTone,
                isLoading: true,
                errorMessage: nil
            )
        }

        translateTask = Task { [weak self] in
            await self?.runTranslate(
                inputText: trimmed,
                targets: targets,
                purpose: self?.selectedPurpose ?? .chat,
                tone: self?.selectedTone ?? .neutral
            )
        }
    }

    func cancelTranslate() {
        translateTask?.cancel()
        translateTask = nil
        translateIsRunning = false
        translateOutputs = translateOutputs.map { output in
            TranslationOutput(
                id: output.id,
                language: output.language,
                text: output.text,
                purpose: output.purpose,
                tone: output.tone,
                isLoading: false,
                errorMessage: output.errorMessage
            )
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

extension AppModel {
    fileprivate func runTranslate(
        inputText: String,
        targets: [Language],
        purpose: Purpose,
        tone: Tone
    ) async {
        let succeeded = await translateTargets(
            inputText: inputText,
            targets: targets,
            purpose: purpose,
            tone: tone
        )
        translateIsRunning = false
        translateTask = nil
        if succeeded {
            appendHistory(inputText: inputText, targets: targets, purpose: purpose, tone: tone)
        }
    }

    fileprivate func translateTargets(
        inputText: String,
        targets: [Language],
        purpose: Purpose,
        tone: Tone
    ) async -> Bool {
        let context = TranslateContext(
            inputText: inputText,
            intent: writingIntent(for: purpose),
            tone: tone,
            provider: .auto,
            modelTier: .balanced,
            sourceCode: translateFromLanguage.code
        )
        return await runTranslateGroup(context: context, targets: targets, purpose: purpose, tone: tone)
    }

    fileprivate func runTranslateGroup(
        context: TranslateContext,
        targets: [Language],
        purpose: Purpose,
        tone: Tone
    ) async -> Bool {
        var succeeded = false
        await withTaskGroup(of: TranslationTaskResult.self) { group in
            for language in targets {
                group.addTask {
                    do {
                        try Task.checkCancellation()
                        let result = try await self.runTranslateTask(language: language, context: context)
                        return TranslationTaskResult(language: language, output: result, errorMessage: nil)
                    } catch {
                        let message = Self.mapErrorMessage(error)
                        return TranslationTaskResult(language: language, output: nil, errorMessage: message)
                    }
                }
            }

            for await result in group {
                guard !Task.isCancelled else { return }
                if let output = result.output {
                    succeeded = true
                    updateOutput(
                        TranslationOutput(
                            language: result.language,
                            text: output.text.trimmingCharacters(in: .whitespacesAndNewlines),
                            purpose: purpose,
                            tone: tone,
                            isLoading: false,
                            errorMessage: nil
                        )
                    )
                } else {
                    updateOutput(
                        TranslationOutput(
                            language: result.language,
                            text: "",
                            purpose: purpose,
                            tone: tone,
                            isLoading: false,
                            errorMessage: result.errorMessage
                        )
                    )
                }
            }
        }
        return succeeded
    }

    fileprivate func runTranslateTask(
        language: Language,
        context: TranslateContext
    ) async throws -> OutputResult {
        guard let option = language.asLanguageOption else {
            throw ProviderError.invalidResponse
        }
        let spec = TaskSpec(
            inputText: context.inputText,
            mode: .translate,
            intent: context.intent,
            tone: context.tone,
            provider: context.provider,
            modelTier: context.modelTier,
            languages: [option],
            sourceLanguage: context.sourceCode
        )
        let output = try await taskRunner.run(spec: spec)
        guard let result = output.results.first else {
            throw ProviderError.invalidResponse
        }
        return result
    }

    fileprivate func updateOutput(_ update: TranslationOutput) {
        translateOutputs = translateOutputs.map { output in
            guard output.language == update.language else { return output }
            return TranslationOutput(
                id: output.id,
                language: update.language,
                text: update.text,
                purpose: update.purpose,
                tone: update.tone,
                isLoading: update.isLoading,
                errorMessage: update.errorMessage
            )
        }
    }

    fileprivate func appendHistory(
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

    nonisolated static func mapErrorMessage(_ error: Error) -> String {
        if let providerError = error as? ProviderError {
            switch providerError {
            case .missingKey(let provider):
                return "API key not set for \(provider.localizedName). Open Settings → Providers."
            case .network:
                return "Network error. Try again."
            case .serviceError(let message):
                let lower = message.lowercased()
                if lower.contains("401") || lower.contains("unauthorized") {
                    return "Invalid API key."
                }
                if lower.contains("429") || lower.contains("rate") {
                    return "Rate limit hit. Try again."
                }
                return "Something went wrong."
            case .invalidResponse, .decodingFailed:
                return "Something went wrong."
            }
        }
        let lower = String(describing: error).lowercased()
        if lower.contains("cancel") {
            return "Cancelled."
        }
        return "Something went wrong."
    }

    fileprivate func writingIntent(for purpose: Purpose) -> WritingIntent {
        switch purpose {
        case .email:
            return .email
        case .sms:
            return .sms
        case .chat:
            return .chat
        case .notes:
            return .plainText
        }
    }
}

private struct TranslateContext: Sendable {
    let inputText: String
    let intent: WritingIntent
    let tone: Tone
    let provider: Provider
    let modelTier: ModelTier
    let sourceCode: String
}

private struct TranslationTaskResult: Sendable {
    let language: Language
    let output: OutputResult?
    let errorMessage: String?
}
