import AppKit
import Combine
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    @Published var inputText = ""
    @Published var results: [OutputResult] = []
    @Published var compareResults: [CompareResult] = []
    @Published var diagnostics = DiagnosticsState()
    @Published var isRunning = false
    @Published var lastInlineError: String?
    @Published var showConsentFlow = false

    @Published var mode: WritingMode {
        didSet { persist(Keys.defaultMode, value: mode.rawValue) }
    }
    @Published var intent: WritingIntent {
        didSet { persist(Keys.defaultIntent, value: intent.rawValue) }
    }
    @Published var tone: Tone {
        didSet { persist(Keys.defaultTone, value: tone.rawValue) }
    }
    @Published var provider: Provider {
        didSet { persist(Keys.defaultProvider, value: provider.rawValue) }
    }
    @Published var modelTier: ModelTier {
        didSet { persist(Keys.defaultModelTier, value: modelTier.rawValue) }
    }
    @Published var keepHistory: Bool {
        didSet { defaults.set(keepHistory, forKey: Keys.keepHistory) }
    }

    @Published private var storedLanguageIds: [String] {
        didSet {
            let value = storedLanguageIds.joined(separator: ",")
            persist(Keys.defaultLanguages, value: value)
        }
    }

    var selectedLanguages: [LanguageOption] {
        get {
            let options = storedLanguageIds.compactMap { id in
                LanguageOption.all.first { $0.id == id }
            }
            return options.isEmpty ? LanguageOption.presets : options
        }
        set {
            let trimmed = newValue.prefix(3)
            storedLanguageIds = trimmed.map(\.id)
        }
    }

    let advancedModels = ModelCatalog.advancedModels

    private let taskRunner = TaskRunner()
    let historyStore: HistoryStore?
    private let defaults: UserDefaults
    private var currentTask: Task<Void, Never>?

    private enum Keys {
        static let defaultMode = "defaultMode"
        static let defaultIntent = "defaultIntent"
        static let defaultTone = "defaultTone"
        static let defaultProvider = "defaultProvider"
        static let defaultModelTier = "defaultModelTier"
        static let defaultLanguages = "defaultLanguages"
        static let keepHistory = "keepHistory"
    }

    init(historyStore: HistoryStore? = nil, defaults: UserDefaults = .standard) {
        self.historyStore = historyStore
        self.defaults = defaults

        mode = WritingMode(rawValue: defaults.string(forKey: Keys.defaultMode) ?? "") ?? .translate
        intent = WritingIntent(rawValue: defaults.string(forKey: Keys.defaultIntent) ?? "") ?? .plainText
        tone = Tone(rawValue: defaults.string(forKey: Keys.defaultTone) ?? "") ?? .neutral
        provider = Provider(rawValue: defaults.string(forKey: Keys.defaultProvider) ?? "") ?? .auto
        modelTier = ModelTier(rawValue: defaults.string(forKey: Keys.defaultModelTier) ?? "") ?? .balanced
        keepHistory = defaults.bool(forKey: Keys.keepHistory)

        let storedLanguages = defaults.string(forKey: Keys.defaultLanguages) ?? "pt,en,de"
        storedLanguageIds = storedLanguages.split(separator: ",").map(String.init)
    }

    func toggleLanguage(_ option: LanguageOption) {
        var current = selectedLanguages
        if current.contains(option) {
            if current.count <= 2 {
                lastInlineError = "Select at least two languages."
                return
            }
            current.removeAll { $0 == option }
        } else {
            if current.count >= 3 {
                lastInlineError = "You can choose up to three languages."
                return
            }
            current.append(option)
        }
        lastInlineError = nil
        selectedLanguages = current
    }

    func applyPresetLanguages() {
        selectedLanguages = LanguageOption.presets
    }

    func runTask() {
        lastInlineError = nil
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            lastInlineError = "Enter text before running."
            return
        }

        // Cancel any previous running task
        currentTask?.cancel()

        isRunning = true
        let start = Date()

        currentTask = Task {
            defer { isRunning = false }
            do {
                let spec = buildSpec()
                if provider == .auto {
                    let output = try await taskRunner.runCompare(spec: spec)
                    guard !Task.isCancelled else { return }
                    compareResults = output.results
                    results = []
                    diagnostics.lastProvider = nil
                    diagnostics.lastModel = nil
                    diagnostics.tokenEstimate = output.tokenEstimate
                    diagnostics.latencyMs = Int(Date().timeIntervalSince(start) * 1000)
                    diagnostics.lastError = nil
                    if keepHistory, let firstSuccess = output.results.first(where: { $0.isSuccess }) {
                        try saveCompareHistory(result: firstSuccess)
                    }
                } else {
                    let output = try await taskRunner.run(spec: spec)
                    guard !Task.isCancelled else { return }
                    compareResults = []
                    results = output.results
                    diagnostics.lastProvider = output.provider
                    diagnostics.lastModel = output.model
                    diagnostics.tokenEstimate = output.tokenEstimate
                    diagnostics.latencyMs = Int(Date().timeIntervalSince(start) * 1000)
                    diagnostics.lastError = nil
                    if keepHistory {
                        try saveHistory(output: output)
                    }
                }
            } catch is CancellationError {
                // Task was cancelled, no need to show error
            } catch {
                guard !Task.isCancelled else { return }
                diagnostics.lastError = error.localizedDescription
                lastInlineError = error.localizedDescription
                if case ProviderError.missingKey = error {
                    showConsentFlow = true
                }
            }
        }
    }

    func retryFailedCompare() {
        guard provider == .auto else { return }
        let failedProviders =
            compareResults
            .filter { $0.errorMessage != nil }
            .map(\.provider)
        guard !failedProviders.isEmpty else { return }

        compareResults = compareResults.map { result in
            guard failedProviders.contains(result.provider) else { return result }
            return CompareResult(
                provider: result.provider,
                model: nil,
                results: [],
                errorMessage: nil,
                isLoading: true,
                isSuccess: false,
                latencyMs: nil
            )
        }

        // Cancel any previous running task
        currentTask?.cancel()

        isRunning = true
        let start = Date()
        currentTask = Task {
            defer { isRunning = false }
            do {
                let spec = buildSpec()
                let output = try await taskRunner.runCompare(spec: spec, providers: failedProviders)
                guard !Task.isCancelled else { return }
                var updated = compareResults.filter { $0.isLoading == false }
                updated.append(contentsOf: output.results)
                compareResults = updated
                diagnostics.tokenEstimate = output.tokenEstimate
                diagnostics.latencyMs = Int(Date().timeIntervalSince(start) * 1000)
                diagnostics.lastError = nil
            } catch is CancellationError {
                // Task was cancelled, no need to show error
            } catch {
                guard !Task.isCancelled else { return }
                compareResults = compareResults.map { result in
                    guard failedProviders.contains(result.provider) else { return result }
                    return CompareResult(
                        provider: result.provider,
                        model: nil,
                        results: [],
                        errorMessage: error.localizedDescription,
                        isLoading: false,
                        isSuccess: false,
                        latencyMs: nil
                    )
                }
                diagnostics.lastError = error.localizedDescription
                lastInlineError = error.localizedDescription
            }
        }
    }

    func copyAllResults() {
        let combined = results.map { "\($0.language.name): \($0.text)" }.joined(separator: "\n\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(combined, forType: .string)
    }

    func useResult(_ result: OutputResult) {
        inputText = result.text
    }

    func useCompareResult(_ result: CompareResult) {
        guard !result.isLoading else {
            lastInlineError = "This provider is still running."
            return
        }
        guard !result.results.isEmpty else {
            lastInlineError = result.errorMessage ?? "No results to use."
            return
        }
        results = result.results
        compareResults = []
        diagnostics.lastProvider = result.provider
        diagnostics.lastModel = result.model
    }

    func clearAll() {
        inputText = ""
        results = []
        compareResults = []
        lastInlineError = nil
    }

    private func persist(_ key: String, value: String) {
        defaults.set(value, forKey: key)
    }
}
