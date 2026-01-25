import Foundation

/// Describes a provider-agnostic task request.
struct TaskSpec: Sendable {
    /// The raw user input to process.
    let inputText: String
    /// The requested writing mode.
    let mode: WritingMode
    /// The intent that shapes the output style.
    let intent: WritingIntent
    /// The desired tone for the output.
    let tone: Tone
    /// The provider selection strategy.
    let provider: Provider
    /// The desired model tier.
    let modelTier: ModelTier
    /// Target languages for the task.
    let languages: [LanguageOption]
    /// Optional source language code for translation tasks.
    let sourceLanguage: String?
    /// Optional extra instruction to refine the request.
    let extraInstruction: String?
}

/// Captures the result of a single task run.
struct TaskRunOutput: Sendable {
    /// Output results returned by the provider.
    let results: [OutputResult]
    /// The provider used to generate the result.
    let provider: Provider
    /// The model identifier returned by the provider.
    let model: String
    /// A rough token estimate for the request.
    let tokenEstimate: Int?
}

/// Captures the results of a compare run across multiple providers.
struct CompareRunOutput: Sendable {
    /// Per-provider results.
    let results: [CompareResult]
    /// A rough token estimate for the request.
    let tokenEstimate: Int?
}
