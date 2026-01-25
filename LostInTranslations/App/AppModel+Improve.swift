import Foundation

extension AppModel {
    func performImprove(preset: ImprovePreset? = nil) {
        cancelImprove()
        let trimmed = improveInputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            improveOutputText = ""
            improveErrorMessage = nil
            return
        }
        improveIsRunning = true
        improveErrorMessage = nil
        improveOutputText = ""
        let instruction = preset?.instruction
        improveTask = Task { [weak self] in
            await self?.runImprove(inputText: trimmed, extraInstruction: instruction)
        }
    }

    func cancelImprove() {
        improveTask?.cancel()
        improveTask = nil
        improveIsRunning = false
    }

    fileprivate func runImprove(
        inputText: String,
        extraInstruction: String?
    ) async {
        defer {
            improveIsRunning = false
            improveTask = nil
        }
        do {
            let result = try await runSingleTask(
                mode: .improve,
                inputText: inputText,
                extraInstruction: extraInstruction
            )
            guard !Task.isCancelled else { return }
            improveOutputText = result.text.trimmingCharacters(in: .whitespacesAndNewlines)
            improveErrorMessage = nil
        } catch is CancellationError {
            // Ignore cancellation.
        } catch {
            guard !Task.isCancelled else { return }
            improveErrorMessage = Self.mapErrorMessage(error)
        }
    }
}
