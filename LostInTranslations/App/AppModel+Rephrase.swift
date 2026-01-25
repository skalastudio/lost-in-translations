import Foundation

extension AppModel {
    /// Starts a rephrase task using current input and settings.
    func performRephrase() {
        cancelRephrase()
        let trimmed = rephraseInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            rephraseOutputs = []
            rephraseErrorMessage = nil
            return
        }
        rephraseIsRunning = true
        rephraseErrorMessage = nil
        rephraseTask = Task { [weak self] in
            guard let self else { return }
            await self.runRephrase(
                inputText: trimmed,
                extraInstruction: self.rephraseInstruction,
                variantsEnabled: self.rephraseVariantsEnabled
            )
        }
    }

    /// Cancels the current rephrase task.
    func cancelRephrase() {
        rephraseTask?.cancel()
        rephraseTask = nil
        rephraseIsRunning = false
    }

    /// Instruction for rephrase requests based on variant selection.
    private var rephraseInstruction: String {
        rephraseVariantsEnabled
            ? "Provide 3 variants as separate bullet points."
            : "Provide a single rephrase."
    }

    /// Runs the rephrase request and updates output state.
    /// - Parameters:
    ///   - inputText: The source input text.
    ///   - extraInstruction: Optional extra instruction.
    ///   - variantsEnabled: Whether multiple variants are expected.
    fileprivate func runRephrase(
        inputText: String,
        extraInstruction: String?,
        variantsEnabled: Bool
    ) async {
        defer {
            rephraseIsRunning = false
            rephraseTask = nil
        }
        do {
            let result = try await runSingleTask(
                mode: .rephrase,
                inputText: inputText,
                extraInstruction: extraInstruction
            )
            guard !Task.isCancelled else { return }
            let text = result.text.trimmingCharacters(in: .whitespacesAndNewlines)
            rephraseOutputs = parseRephraseOutputs(from: text, variantsEnabled: variantsEnabled)
            rephraseErrorMessage = nil
        } catch is CancellationError {
            // Ignore cancellation.
        } catch {
            guard !Task.isCancelled else { return }
            rephraseErrorMessage = Self.mapErrorMessage(error)
        }
    }

    /// Parses rephrase output into one or more variants.
    /// - Parameters:
    ///   - text: Raw response text.
    ///   - variantsEnabled: Whether to extract multiple variants.
    /// - Returns: An array of rephrase variants.
    fileprivate func parseRephraseOutputs(from text: String, variantsEnabled: Bool) -> [String] {
        if !variantsEnabled {
            return text.isEmpty ? [] : [text]
        }
        let lines =
            text
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let cleaned = lines.map { line -> String in
            var value = line
            if let range = value.range(of: #"^[\-\u{2022}\*\s]*"#, options: .regularExpression) {
                value.removeSubrange(range)
            }
            if let range = value.range(of: #"^\d+[.)]\s*"#, options: .regularExpression) {
                value.removeSubrange(range)
            }
            return value.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let variants = cleaned.filter { !$0.isEmpty }
        if variants.isEmpty {
            return text.isEmpty ? [] : [text]
        }
        return Array(variants.prefix(3))
    }
}
