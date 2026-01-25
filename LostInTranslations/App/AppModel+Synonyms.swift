import Foundation

extension AppModel {
    /// Starts a synonyms lookup task.
    func performSynonyms() {
        cancelSynonyms()
        let trimmed = synonymsQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            synonymsResults = []
            synonymsUsageNotes = ""
            synonymsExamples = []
            synonymsErrorMessage = nil
            return
        }
        synonymsIsRunning = true
        synonymsErrorMessage = nil
        synonymsResults = []
        synonymsUsageNotes = ""
        synonymsExamples = []
        synonymsTask = Task { [weak self] in
            guard let self else { return }
            await self.runSynonyms(inputText: trimmed, extraInstruction: self.synonymsInstruction)
        }
    }

    /// Cancels the current synonyms task.
    func cancelSynonyms() {
        synonymsTask?.cancel()
        synonymsTask = nil
        synonymsIsRunning = false
    }

    /// Instruction for synonyms requests.
    private var synonymsInstruction: String {
        """
        Return sections labeled \"Synonyms:\", \"Usage:\", and \"Examples:\"
        with concise content suitable for a macOS UI.
        """
    }

    /// Runs the synonyms request and updates output state.
    /// - Parameters:
    ///   - inputText: The query text.
    ///   - extraInstruction: Optional extra instruction.
    fileprivate func runSynonyms(
        inputText: String,
        extraInstruction: String?
    ) async {
        defer {
            synonymsIsRunning = false
            synonymsTask = nil
        }
        do {
            let result = try await runSingleTask(
                mode: .synonyms,
                inputText: inputText,
                extraInstruction: extraInstruction
            )
            guard !Task.isCancelled else { return }
            let text = result.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let parsed = parseSynonymsOutput(from: text)
            synonymsResults = parsed.synonyms
            synonymsUsageNotes = parsed.usage
            synonymsExamples = parsed.examples
            synonymsErrorMessage = nil
        } catch is CancellationError {
            // Ignore cancellation.
        } catch {
            guard !Task.isCancelled else { return }
            synonymsErrorMessage = Self.mapErrorMessage(error)
        }
    }

    /// Parses a synonyms response into structured data.
    /// - Parameter text: Raw response text.
    /// - Returns: Parsed synonyms response.
    fileprivate func parseSynonymsOutput(from text: String) -> SynonymsParseResult {
        let normalized = text.replacingOccurrences(of: "\r", with: "")
        let lower = normalized.lowercased()

        func section(_ label: String) -> String? {
            guard let start = lower.range(of: "\(label):") else { return nil }
            let startIndex = start.upperBound
            let remaining = lower[startIndex...]
            let nextLabels = ["synonyms:", "usage:", "examples:"]
                .compactMap { remaining.range(of: $0) }
                .map { $0.lowerBound }
            let endIndex = nextLabels.min() ?? normalized.endIndex
            let slice = normalized[startIndex..<endIndex]
            return slice.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let synonymsText = section("synonyms") ?? normalized
        let usageText = section("usage") ?? ""
        let examplesText = section("examples") ?? ""

        let synonyms = parseList(from: synonymsText)
        let examples = parseList(from: examplesText)
        return SynonymsParseResult(synonyms: synonyms, usage: usageText, examples: examples)
    }

    /// Parses a simple list from a text block.
    /// - Parameter text: Raw list text.
    /// - Returns: Cleaned list items.
    fileprivate func parseList(from text: String) -> [String] {
        let separators = CharacterSet(charactersIn: ",;\n")
        return
            text
            .components(separatedBy: separators)
            .map { item in
                var value = item.trimmingCharacters(in: .whitespacesAndNewlines)
                if let range = value.range(of: #"^[\-\u{2022}\*\s]*"#, options: .regularExpression) {
                    value.removeSubrange(range)
                }
                return value.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .filter { !$0.isEmpty }
    }
}

/// Parsed result for a synonyms response.
struct SynonymsParseResult: Sendable {
    /// Synonyms list.
    let synonyms: [String]
    /// Usage notes.
    let usage: String
    /// Example sentences.
    let examples: [String]
}
