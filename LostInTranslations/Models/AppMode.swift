import Foundation

enum AppMode: String, CaseIterable, Identifiable {
    case translate
    case improve
    case rephrase
    case synonyms
    case history

    var id: String { rawValue }
}
