import Foundation

extension AppModel {
    /// Adds a target language if it is valid and within limits.
    /// - Parameter language: The language to add.
    func addTargetLanguage(_ language: Language) {
        guard language != .auto else { return }
        guard !translateTargetLanguages.contains(language) else { return }
        guard translateTargetLanguages.count < maxTargetLanguages else { return }
        translateTargetLanguages.append(language)
    }

    /// Removes a target language from the selection.
    /// - Parameter language: The language to remove.
    func removeTargetLanguage(_ language: Language) {
        translateTargetLanguages.removeAll { $0 == language }
    }

    /// Clears state for the currently selected mode.
    func clearCurrentMode() {
        switch selectedMode {
        case .translate:
            translateInputText = ""
            translateOutputs = []
        case .improve:
            improveInputText = ""
            improveOutputText = ""
            improveErrorMessage = nil
        case .rephrase:
            rephraseInputText = ""
            rephraseOutputs = []
            rephraseErrorMessage = nil
        case .synonyms:
            synonymsQuery = ""
            synonymsResults = []
            synonymsUsageNotes = ""
            synonymsExamples = []
            synonymsErrorMessage = nil
        case .history:
            break
        }
    }
}
