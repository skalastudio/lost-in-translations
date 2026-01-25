import Foundation

extension AppModel {
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

    func cancelSynonyms() {
        synonymsTask?.cancel()
        synonymsTask = nil
        synonymsIsRunning = false
    }

    private var synonymsInstruction: String {
        """
        Return sections labeled \"Synonyms:\", \"Usage:\", and \"Examples:\"
        with concise content suitable for a macOS UI.
        """
    }

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

struct SynonymsParseResult: Sendable {
    let synonyms: [String]
    let usage: String
    let examples: [String]
}
