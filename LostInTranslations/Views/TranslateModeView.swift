import SwiftUI

/// Translate mode UI.
struct TranslateModeView: View {
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel

    /// View body.
    var body: some View {
        HSplitView {
            inputPanel
            outputPanel
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("translate.copyAllOutputs") {
                    copyAllOutputs()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .opacity(0)
                .frame(width: 0, height: 0)
            }
        }
    }

    /// Input panel for translation.
    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("translate.input.title")
                .font(.headline)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $appModel.translateInputText)
                    .font(.body)
                if appModel.translateInputText.isEmpty {
                    Text("translate.input.placeholder")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }
            .frame(minHeight: 200)
        }
        .padding()
    }

    /// Output panel for translation results.
    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("translate.output.title")
                .font(.headline)
            ScrollView {
                if appModel.translateOutputs.isEmpty {
                    emptyOutputState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(appModel.translateOutputs) { output in
                            TranslationOutputCard(
                                output: output,
                                hasInput: appModel.hasTranslateInput,
                                onCopy: { copyToPasteboard(output.text) },
                                onReplace: { appModel.translateInputText = output.text },
                                onRegenerate: { appModel.performTranslate() }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
    }

    /// Copies all translation outputs to the pasteboard.
    private func copyAllOutputs() {
        let combined = appModel.translateOutputs
            .map { $0.text }
            .joined(separator: "\n\n")
        copyToPasteboard(combined)
    }

    /// Copies text to the pasteboard.
    /// - Parameter text: Text to copy.
    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    @ViewBuilder
    /// Empty state shown when there are no outputs.
    private var emptyOutputState: some View {
        ContentUnavailableView {
            Text("translate.output.empty.title")
        } description: {
            Text("translate.output.empty.subtitle")
        }
    }
}

/// Preview for TranslateModeView.
#Preview {
    let model = AppModel()
    model.translateInputText = "Hello! How are you today?"
    model.translateOutputs = [
        TranslationOutput(
            language: .english,
            text: "Hello! How are you today?",
            purpose: .chat,
            tone: .neutral
        ),
        TranslationOutput(
            language: .portuguese,
            text: "Ola! Como voce esta hoje?",
            purpose: .chat,
            tone: .neutral
        ),
    ]
    return TranslateModeView()
        .environmentObject(model)
        .frame(width: 1000, height: 600)
}

/// Output card for a single translation result.
private struct TranslationOutputCard: View {
    /// Output data for the card.
    let output: TranslationOutput
    /// Whether there is input text to allow regeneration.
    let hasInput: Bool
    /// Copy action callback.
    let onCopy: () -> Void
    /// Replace input action callback.
    let onReplace: () -> Void
    /// Regenerate action callback.
    let onRegenerate: () -> Void

    /// Whether the card has output text.
    private var hasOutput: Bool {
        !output.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// View body.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(
                    "\(output.language.title) (\(output.language.code)) · \(output.purposeTitle) · \(output.toneTitle)"
                )
                .font(.subheadline)
                Spacer()
                Button("actions.copy", action: onCopy)
                    .disabled(!hasOutput)
                Button("actions.replaceInput", action: onReplace)
                    .disabled(!hasOutput)
                Button("actions.regenerate", action: onRegenerate)
                    .disabled(!hasInput)
            }
            .buttonStyle(.bordered)

            if output.isLoading {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("translate.output.loading")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let errorMessage = output.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                ScrollView {
                    Text(output.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
                .frame(minHeight: 80, maxHeight: 140)
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(6)
            }
        }
        .padding(10)
        .background(Color.secondary.opacity(0.06))
        .cornerRadius(8)
    }
}
