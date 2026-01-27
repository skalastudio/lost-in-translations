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
            HStack {
                fromLanguageControl
                Spacer()
                Button("toolbar.translate") {
                    appModel.performTranslate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appModel.canTranslate)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding()
    }

    /// Output panel for translation results.
    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            translateControls
            GeometryReader { proxy in
                ScrollView {
                    if appModel.translateOutputs.isEmpty {
                        emptyOutputState
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                    } else {
                        let cardHeight = outputCardHeight(containerHeight: proxy.size.height)
                        VStack(spacing: 6) {
                            ForEach(appModel.translateOutputs) { output in
                                TranslationOutputCard(
                                    output: output,
                                    onCopy: { copyToPasteboard(output.text) },
                                    onReplace: { appModel.translateInputText = output.text }
                                )
                                .frame(minHeight: cardHeight)
                            }
                        }
                        .padding(.vertical, 2)
                    }
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

    /// Calculates per-card height based on available space.
    /// - Parameter containerHeight: Available height for outputs.
    /// - Returns: Minimum height per output card.
    private func outputCardHeight(containerHeight: CGFloat) -> CGFloat {
        let count = max(appModel.translateOutputs.count, 1)
        let spacing = 6.0 * Double(max(count - 1, 0))
        let available = max(containerHeight - spacing, 120)
        return max(120, available / Double(count))
    }

    /// Source language picker shown above the input editor.
    private var fromLanguageControl: some View {
        Picker("translate.sourceLanguage.label", selection: $appModel.translateFromLanguage) {
            ForEach(Language.allCases) { language in
                Text(language.title).tag(language)
            }
        }
        .frame(maxWidth: 220, alignment: .leading)
    }

    /// Translate controls shown above the input editor.
    private var translateControls: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Menu {
                        ForEach(Language.allCases.filter { $0 != .auto }) { language in
                            Button(language.title) {
                                appModel.addTargetLanguage(language)
                            }
                            .disabled(appModel.translateTargetLanguages.contains(language))
                        }
                    } label: {
                        Text("+ \(String(localized: "toolbar.addLanguage"))")
                    }
                    .disabled(appModel.translateTargetLanguages.count >= appModel.maxTargetLanguages)

                    TargetLanguagePillsView(languages: appModel.translateTargetLanguages) { language in
                        appModel.removeTargetLanguage(language)
                    }
                }

                HStack(spacing: 12) {
                    Picker("toolbar.purpose", selection: $appModel.selectedPurpose) {
                        ForEach(Purpose.allCases) { purpose in
                            Text(purpose.title).tag(purpose)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("toolbar.tone", selection: $appModel.selectedTone) {
                        ForEach(Tone.allCases) { tone in
                            Text(tone.localizedName).tag(tone)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .padding(.vertical, 2)
        }
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

/// Displays selected target languages as removable pills.
private struct TargetLanguagePillsView: View {
    /// Target languages to display.
    let languages: [Language]
    /// Callback for removal.
    let onRemove: (Language) -> Void

    /// View body.
    var body: some View {
        HStack(spacing: 6) {
            ForEach(languages) { language in
                HStack(spacing: 4) {
                    Text(language.code)
                    Button {
                        onRemove(language)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption2)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        Text(
                            String(
                                format: String(localized: "actions.removeLanguage"),
                                language.title
                            )
                        )
                    )
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.secondary.opacity(0.2)))
            }
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
    /// Copy action callback.
    let onCopy: () -> Void
    /// Replace input action callback.
    let onReplace: () -> Void

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
