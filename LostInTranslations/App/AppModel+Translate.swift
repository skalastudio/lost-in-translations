import Foundation

extension AppModel {
    /// Generates stub translation outputs for UI previews.
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

    /// Starts a provider-backed translation run.
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

    /// Cancels the current translation task and clears loading state.
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

    /// Runs translation tasks and updates history on success.
    /// - Parameters:
    ///   - inputText: The source input text.
    ///   - targets: Target languages to translate into.
    ///   - purpose: The selected purpose.
    ///   - tone: The selected tone.
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

    /// Translates to multiple target languages concurrently.
    /// - Parameters:
    ///   - inputText: The source input text.
    ///   - targets: Target languages to translate into.
    ///   - purpose: The selected purpose.
    ///   - tone: The selected tone.
    /// - Returns: Whether at least one translation succeeded.
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
            provider: selectedProvider,
            modelTier: .balanced,
            sourceCode: translateFromLanguage.code
        )
        return await runTranslateGroup(context: context, targets: targets, purpose: purpose, tone: tone)
    }

    /// Executes the translation task group and updates outputs as results arrive.
    /// - Parameters:
    ///   - context: Shared translation context.
    ///   - targets: Target languages to translate into.
    ///   - purpose: The selected purpose.
    ///   - tone: The selected tone.
    /// - Returns: Whether at least one translation succeeded.
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

    /// Runs a single translation task.
    /// - Parameters:
    ///   - language: Target language.
    ///   - context: Shared translation context.
    /// - Returns: Output result for the language.
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
            sourceLanguage: context.sourceCode,
            extraInstruction: nil
        )
        let output = try await taskRunner.run(spec: spec)
        guard let result = output.results.first else {
            throw ProviderError.invalidResponse
        }
        return result
    }

    /// Updates a translation output in-place.
    /// - Parameter update: The updated output value.
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
}

/// Shared translation context for provider calls.
private struct TranslateContext: Sendable {
    /// Source input text.
    let inputText: String
    /// Writing intent for the request.
    let intent: WritingIntent
    /// Tone for the request.
    let tone: Tone
    /// Provider selection.
    let provider: Provider
    /// Model tier selection.
    let modelTier: ModelTier
    /// Source language code.
    let sourceCode: String
}

/// Result wrapper for translation task group execution.
private struct TranslationTaskResult: Sendable {
    /// Target language for the result.
    let language: Language
    /// Output result when successful.
    let output: OutputResult?
    /// Error message when failed.
    let errorMessage: String?
}
