import Foundation

extension AppModel {
    func addTargetLanguage(_ language: Language) {
        guard language != .auto else { return }
        guard !translateTargetLanguages.contains(language) else { return }
        guard translateTargetLanguages.count < maxTargetLanguages else { return }
        translateTargetLanguages.append(language)
    }

    func removeTargetLanguage(_ language: Language) {
        translateTargetLanguages.removeAll { $0 == language }
    }

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
