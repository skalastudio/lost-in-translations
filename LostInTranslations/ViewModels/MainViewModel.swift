import AppKit
import Combine
import SwiftUI

/// Legacy view model backing the compare/providers UI.
@MainActor
final class MainViewModel: ObservableObject {
    /// Current input text.
    @Published var inputText = ""
    /// Latest output results.
    @Published var results: [OutputResult] = []
    /// Compare results across providers.
    @Published var compareResults: [CompareResult] = []
    /// Diagnostics for the last run.
    @Published var diagnostics = DiagnosticsState()
    /// Whether a task is currently running.
    @Published var isRunning = false
    /// Inline error string for UI display.
    @Published var lastInlineError: String?
    /// Whether to present the consent flow.
    @Published var showConsentFlow = false

    /// Selected writing mode.
    @Published var mode: WritingMode {
        didSet { persist(Keys.defaultMode, value: mode.rawValue) }
    }
    /// Selected writing intent.
    @Published var intent: WritingIntent {
        didSet { persist(Keys.defaultIntent, value: intent.rawValue) }
    }
    /// Selected tone.
    @Published var tone: Tone {
        didSet { persist(Keys.defaultTone, value: tone.rawValue) }
    }
    /// Selected provider.
    @Published var provider: Provider {
        didSet { persist(Keys.defaultProvider, value: provider.rawValue) }
    }
    /// Selected model tier.
    @Published var modelTier: ModelTier {
        didSet { persist(Keys.defaultModelTier, value: modelTier.rawValue) }
    }
    /// Whether to persist history.
    @Published var keepHistory: Bool {
        didSet { defaults.set(keepHistory, forKey: Keys.keepHistory) }
    }

    /// Persisted language identifiers.
    @Published private var storedLanguageIds: [String] {
        didSet {
            let value = storedLanguageIds.joined(separator: ",")
            persist(Keys.defaultLanguages, value: value)
        }
    }

    /// Selected language options.
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

    /// Task runner used for provider requests.
    private let taskRunner = TaskRunner()
    /// Optional history store.
    let historyStore: HistoryStore?
    /// User defaults for persistence.
    private let defaults: UserDefaults
    /// Current in-flight task.
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

    /// Creates a view model with optional history storage.
    /// - Parameters:
    ///   - historyStore: Optional history store.
    ///   - defaults: User defaults instance.
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

    /// Toggles a language selection and enforces limits.
    /// - Parameter option: Language option to toggle.
    func toggleLanguage(_ option: LanguageOption) {
        var current = selectedLanguages
        if current.contains(option) {
            if current.count <= 2 {
                lastInlineError = String(localized: "error.languages.min")
                return
            }
            current.removeAll { $0 == option }
        } else {
            if current.count >= 3 {
                lastInlineError = String(localized: "error.languages.max")
                return
            }
            current.append(option)
        }
        lastInlineError = nil
        selectedLanguages = current
    }

    /// Applies the default preset languages.
    func applyPresetLanguages() {
        selectedLanguages = LanguageOption.presets
    }

    /// Runs the current task using the selected provider settings.
    func runTask() {
        lastInlineError = nil
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            lastInlineError = String(localized: "error.input.empty")
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

    /// Retries failed providers when compare mode is enabled.
    func retryFailedCompare() {
        guard provider == .auto else { return }
        let failedProviders = failedCompareProviders()
        guard !failedProviders.isEmpty else { return }

        markProvidersForRetry(failedProviders)

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
                applyRetryResults(output: output, start: start)
            } catch is CancellationError {
                // Task was cancelled, no need to show error
            } catch {
                guard !Task.isCancelled else { return }
                applyRetryFailure(error: error, providers: failedProviders)
            }
        }
    }

    /// Copies all results to the pasteboard.
    func copyAllResults() {
        let combined = results.map { result in
            String(
                format: String(localized: "results.copyAll.line"),
                result.language.localizedName,
                result.text
            )
        }
        .joined(separator: "\n\n")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(combined, forType: .string)
    }

    /// Replaces the input text with a selected result.
    /// - Parameter result: The result to use as input.
    func useResult(_ result: OutputResult) {
        inputText = result.text
    }

    /// Promotes a compare result into the primary results view.
    /// - Parameter result: The compare result to use.
    func useCompareResult(_ result: CompareResult) {
        guard !result.isLoading else {
            lastInlineError = String(localized: "error.provider.running")
            return
        }
        guard !result.results.isEmpty else {
            lastInlineError = result.errorMessage ?? String(localized: "error.result.none")
            return
        }
        results = result.results
        compareResults = []
        diagnostics.lastProvider = result.provider
        diagnostics.lastModel = result.model
    }

    /// Clears input and results.
    func clearAll() {
        inputText = ""
        results = []
        compareResults = []
        lastInlineError = nil
    }

    /// Persists a string value to user defaults.
    /// - Parameters:
    ///   - key: Defaults key.
    ///   - value: Value to store.
    private func persist(_ key: String, value: String) {
        defaults.set(value, forKey: key)
    }

    /// Returns providers that failed in the last compare run.
    private func failedCompareProviders() -> [Provider] {
        compareResults
            .filter { $0.errorMessage != nil }
            .map(\.provider)
    }

    /// Marks providers as loading for a retry pass.
    /// - Parameter providers: Providers to mark.
    private func markProvidersForRetry(_ providers: [Provider]) {
        compareResults = compareResults.map { result in
            guard providers.contains(result.provider) else { return result }
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
    }

    /// Applies retry results to the compare list.
    /// - Parameters:
    ///   - output: Retry output payload.
    ///   - start: Start timestamp for latency measurement.
    private func applyRetryResults(output: CompareRunOutput, start: Date) {
        var updated = compareResults.filter { $0.isLoading == false }
        updated.append(contentsOf: output.results)
        compareResults = updated
        diagnostics.tokenEstimate = output.tokenEstimate
        diagnostics.latencyMs = Int(Date().timeIntervalSince(start) * 1000)
        diagnostics.lastError = nil
    }

    /// Applies retry failure results to the compare list.
    /// - Parameters:
    ///   - error: Error encountered.
    ///   - providers: Providers that failed.
    private func applyRetryFailure(error: Error, providers: [Provider]) {
        compareResults = compareResults.map { result in
            guard providers.contains(result.provider) else { return result }
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
