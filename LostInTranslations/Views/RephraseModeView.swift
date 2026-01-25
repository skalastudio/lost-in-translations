import SwiftUI

struct RephraseModeView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        HSplitView {
            inputPanel
            outputPanel
        }
    }

    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Original")
                .font(.headline)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $appModel.rephraseInputText)
                    .font(.body)
                if appModel.rephraseInputText.isEmpty {
                    Text("Paste or type text...")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }
            .frame(minHeight: 200)

            Toggle("Variants", isOn: $appModel.rephraseVariantsEnabled)
                .toggleStyle(.switch)

            Button("Rephrase") {
                appModel.performRephrase()
            }
            .disabled(!appModel.canRephrase)
        }
        .padding()
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rephrased")
                .font(.headline)
            ScrollView {
                if appModel.rephraseIsRunning {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Rephrasing...")
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
                                    ? "Variant \(index + 1)"
                                    : "Result",
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

    private var emptyOutputState: some View {
        VStack(spacing: 6) {
            Text("Rephrased text will appear here")
                .font(.headline)
            Text("Paste or type text, then click Rephrase.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

private struct RephraseVariantCard: View {
    let title: String
    let text: String
    let onCopy: () -> Void
    let onReplace: () -> Void

    private var hasOutput: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                Spacer()
                Button("Copy", action: onCopy)
                    .disabled(!hasOutput)
                Button("Replace", action: onReplace)
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
