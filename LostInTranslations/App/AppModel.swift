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
    @Published var improveInputText: String = ""
    @Published var improveOutputText: String = ""
    @Published var improveIsRunning: Bool = false
    @Published var improveErrorMessage: String?
    @Published var rephraseInputText: String = ""
    @Published var rephraseVariantsEnabled: Bool = false
    @Published var rephraseOutputs: [String] = []
    @Published var rephraseIsRunning: Bool = false
    @Published var rephraseErrorMessage: String?
    @Published var synonymsQuery: String = ""
    @Published var synonymsResults: [String] = []
    @Published var synonymsUsageNotes: String = ""
    @Published var synonymsExamples: [String] = []
    @Published var synonymsIsRunning: Bool = false
    @Published var synonymsErrorMessage: String?
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
    let taskRunner = TaskRunner()
    var translateTask: Task<Void, Never>?
    var improveTask: Task<Void, Never>?
    var rephraseTask: Task<Void, Never>?
    var synonymsTask: Task<Void, Never>?

    init() {
        loadHistory()
    }

    var hasTranslateInput: Bool {
        !translateInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canTranslate: Bool {
        hasTranslateInput
    }

    var hasImproveInput: Bool {
        !improveInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canImprove: Bool {
        hasImproveInput
    }

    var hasRephraseInput: Bool {
        !rephraseInputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canRephrase: Bool {
        hasRephraseInput
    }

    var hasSynonymsQuery: Bool {
        !synonymsQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canLookupSynonyms: Bool {
        hasSynonymsQuery
    }

    var hasHistory: Bool {
        !historyItems.isEmpty
    }
}
