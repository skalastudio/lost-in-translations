import Foundation

struct TaskSpec: Sendable {
    let inputText: String
    let mode: WritingMode
    let intent: WritingIntent
    let tone: Tone
    let provider: Provider
    let modelTier: ModelTier
    let languages: [LanguageOption]
    let sourceLanguage: String?
}

struct TaskRunOutput: Sendable {
    let results: [OutputResult]
    let provider: Provider
    let model: String
    let tokenEstimate: Int?
}

struct CompareRunOutput: Sendable {
    let results: [CompareResult]
    let tokenEstimate: Int?
}
