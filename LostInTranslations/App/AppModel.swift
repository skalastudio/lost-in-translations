import Foundation

/// Central observable state for the app UI.
@MainActor
final class AppModel: ObservableObject {
    /// The currently selected navigation mode.
    @Published var selectedMode: AppMode = .translate
    /// The selected purpose used to shape output.
    @Published var selectedPurpose: Purpose = .chat
    /// The selected tone used to shape output.
    @Published var selectedTone: Tone = .neutral
    /// The selected provider used for requests.
    @Published var selectedProvider: Provider = .auto {
        didSet {
            refreshProviderAvailability()
        }
    }
    /// Selected source language for translation.
    @Published var translateFromLanguage: Language = .auto
    /// Selected target languages for translation.
    @Published var translateTargetLanguages: [Language] = [.english]
    /// Input text for translation mode.
    @Published var translateInputText: String = ""
    /// Translation outputs for the current request.
    @Published var translateOutputs: [TranslationOutput] = []
    /// Whether translation work is in progress.
    @Published var translateIsRunning: Bool = false
    /// Input text for improve mode.
    @Published var improveInputText: String = ""
    /// Output text for improve mode.
    @Published var improveOutputText: String = ""
    /// Whether improve work is in progress.
    @Published var improveIsRunning: Bool = false
    /// Error message for improve mode.
    @Published var improveErrorMessage: String?
    /// Input text for rephrase mode.
    @Published var rephraseInputText: String = ""
    /// Whether rephrase variants are enabled.
    @Published var rephraseVariantsEnabled: Bool = false
    /// Rephrase outputs.
    @Published var rephraseOutputs: [String] = []
    /// Whether rephrase work is in progress.
    @Published var rephraseIsRunning: Bool = false
    /// Error message for rephrase mode.
    @Published var rephraseErrorMessage: String?
    /// Query text for synonyms lookup.
    @Published var synonymsQuery: String = ""
    /// Synonyms returned for the query.
    @Published var synonymsResults: [String] = []
    /// Usage notes returned for synonyms.
    @Published var synonymsUsageNotes: String = ""
    /// Example sentences returned for synonyms.
    @Published var synonymsExamples: [String] = []
    /// Whether synonyms lookup is in progress.
    @Published var synonymsIsRunning: Bool = false
    /// Error message for synonyms mode.
    @Published var synonymsErrorMessage: String?
    /// In-memory history items.
    @Published var historyItems: [HistoryItem] = []
    /// Toggles local history persistence.
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

    /// Maximum number of target languages allowed.
    let maxTargetLanguages = 3
    /// Shared task runner for provider calls.
    let taskRunner = TaskRunner()
    /// Triggers view updates when provider availability changes.
    @Published private(set) var providerAvailabilityVersion: Int = 0
    /// Current translation task, if any.
    var translateTask: Task<Void, Never>?
    /// Current improve task, if any.
    var improveTask: Task<Void, Never>?
    /// Current rephrase task, if any.
    var rephraseTask: Task<Void, Never>?
    /// Current synonyms task, if any.
    var synonymsTask: Task<Void, Never>?

    /// Creates the app model and loads persisted history.
    init() {
        loadHistory()
    }

    /// Whether the translation input has content.
    var hasTranslateInput: Bool {
        !translateInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether translation can be initiated.
    var canTranslate: Bool {
        hasTranslateInput
    }

    /// Whether the improve input has content.
    var hasImproveInput: Bool {
        !improveInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether improve can be initiated.
    var canImprove: Bool {
        hasImproveInput
    }

    /// Whether the rephrase input has content.
    var hasRephraseInput: Bool {
        !rephraseInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether rephrase can be initiated.
    var canRephrase: Bool {
        hasRephraseInput
    }

    /// Whether the synonyms query has content.
    var hasSynonymsQuery: Bool {
        !synonymsQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether synonyms lookup can be initiated.
    var canLookupSynonyms: Bool {
        hasSynonymsQuery
    }

    /// Whether there are history items.
    var hasHistory: Bool {
        !historyItems.isEmpty
    }

    /// Whether the provider selection supports the given mode.
    /// - Parameter mode: App mode to validate.
    /// - Returns: True when the mode is available.
    func isModeSupported(_ mode: AppMode) -> Bool {
        guard let capability = mode.requiredCapability else { return true }
        return availableCapabilities.contains(capability)
    }

    /// Forces a refresh of provider availability.
    func refreshProviderAvailability() {
        providerAvailabilityVersion += 1
    }

    /// Available capabilities based on provider selection and keys.
    private var availableCapabilities: Set<ProviderCapability> {
        if selectedProvider != .auto {
            return selectedProvider.capabilities
        }
        return hasAnyAPIKey ? Provider.fullCapabilities : Provider.appleTranslation.capabilities
    }

    /// Returns true when any API key is stored.
    private var hasAnyAPIKey: Bool {
        [Provider.openAI, Provider.claude, Provider.gemini].contains { provider in
            KeychainStore.readKey(for: provider) != nil
        }
    }

}
