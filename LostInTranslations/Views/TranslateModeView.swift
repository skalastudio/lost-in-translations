import SwiftUI

struct TranslateModeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        HSplitView {
            inputPanel
            outputPanel
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button("Copy All Outputs") {
                    copyAllOutputs()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .opacity(0)
                .frame(width: 0, height: 0)
            }
        }
    }

    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Input")
                .font(.headline)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $appModel.translateInputText)
                    .font(.body)
                if appModel.translateInputText.isEmpty {
                    Text("Paste or type text...")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }
            .frame(minHeight: 200)
        }
        .padding()
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Outputs")
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
                                onRegenerate: { appModel.performTranslateStub() }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
    }

    private func copyAllOutputs() {
        let combined = appModel.translateOutputs
            .map { $0.text }
            .joined(separator: "\n\n")
        copyToPasteboard(combined)
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    @ViewBuilder
    private var emptyOutputState: some View {
        if #available(macOS 14.0, *) {
            ContentUnavailableView {
                Text("Results will appear here")
            } description: {
                Text("Paste or type text, then press \u{2318}\u{21A9}")
            }
        } else {
            VStack(spacing: 6) {
                Text("Results will appear here")
                    .font(.headline)
                Text("Paste or type text, then press \u{2318}\u{21A9}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct TranslationOutputCard: View {
    let output: TranslationOutput
    let hasInput: Bool
    let onCopy: () -> Void
    let onReplace: () -> Void
    let onRegenerate: () -> Void

    private var hasOutput: Bool {
        !output.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(
                    "\(output.language.title) (\(output.language.code)) · \(output.purposeTitle) · \(output.toneTitle)"
                )
                .font(.subheadline)
                Spacer()
                Button("Copy", action: onCopy)
                    .disabled(!hasOutput)
                Button("Replace Input", action: onReplace)
                    .disabled(!hasOutput)
                Button("Regenerate", action: onRegenerate)
                    .disabled(!hasInput)
            }
            .buttonStyle(.bordered)

            ScrollView {
                Text(output.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .frame(minHeight: 80, maxHeight: 140)
            .background(Color.secondary.opacity(0.08))
            .cornerRadius(6)
        }
        .padding(10)
        .background(Color.secondary.opacity(0.06))
        .cornerRadius(8)
    }
}
