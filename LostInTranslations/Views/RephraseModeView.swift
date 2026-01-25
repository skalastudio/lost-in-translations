import SwiftUI

/// Rephrase mode UI.
struct RephraseModeView: View {
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel

    /// View body.
    var body: some View {
        HSplitView {
            inputPanel
            outputPanel
        }
    }

    /// Input panel for rephrasing.
    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("rephrase.input.title")
                .font(.headline)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $appModel.rephraseInputText)
                    .font(.body)
                if appModel.rephraseInputText.isEmpty {
                    Text("rephrase.input.placeholder")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }
            .frame(minHeight: 200)

            Toggle("rephrase.variants", isOn: $appModel.rephraseVariantsEnabled)
                .toggleStyle(.switch)

            Button("rephrase.action") {
                appModel.performRephrase()
            }
            .disabled(!appModel.canRephrase)
        }
        .padding()
    }

    /// Output panel for rephrase results.
    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("rephrase.output.title")
                .font(.headline)
            ScrollView {
                if appModel.rephraseIsRunning {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("rephrase.output.loading")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                } else if let error = appModel.rephraseErrorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                } else if appModel.rephraseOutputs.isEmpty {
                    emptyOutputState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(appModel.rephraseOutputs.indices, id: \.self) { index in
                            let text = appModel.rephraseOutputs[index]
                            RephraseVariantCard(
                                title: appModel.rephraseVariantsEnabled
                                    ? String(
                                        format: String(localized: "rephrase.variant"),
                                        index + 1
                                    )
                                    : String(localized: "rephrase.result"),
                                text: text,
                                onCopy: { copyToPasteboard(text) },
                                onReplace: { appModel.rephraseInputText = text }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
    }

    /// Empty state shown when there are no outputs.
    private var emptyOutputState: some View {
        VStack(spacing: 6) {
            Text("rephrase.output.empty.title")
                .font(.headline)
            Text("rephrase.output.empty.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// Copies text to the pasteboard.
    /// - Parameter text: Text to copy.
    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

/// Preview for RephraseModeView.
#Preview {
    let model = AppModel()
    model.rephraseInputText = "We should meet tomorrow to review the plan."
    model.rephraseVariantsEnabled = true
    model.rephraseOutputs = [
        "Let's meet tomorrow to review the plan.",
        "Can we meet tomorrow to go over the plan?",
        "We should get together tomorrow to review the plan.",
    ]
    return RephraseModeView()
        .environmentObject(model)
        .frame(width: 900, height: 520)
}

/// Card view for a rephrase variant.
private struct RephraseVariantCard: View {
    /// Card title.
    let title: String
    /// Output text.
    let text: String
    /// Copy action callback.
    let onCopy: () -> Void
    /// Replace action callback.
    let onReplace: () -> Void

    /// Whether the card has output text.
    private var hasOutput: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// View body.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Button("actions.copy", action: onCopy)
                    .disabled(!hasOutput)
                Button("actions.replace", action: onReplace)
                    .disabled(!hasOutput)
            }
            .buttonStyle(.bordered)

            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(6)
        }
        .padding(10)
        .background(Color.secondary.opacity(0.06))
        .cornerRadius(8)
    }
}
