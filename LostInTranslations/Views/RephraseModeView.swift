import SwiftUI

struct RephraseModeView: View {
    @State private var inputText = ""
    @State private var variantsEnabled = false
    @State private var outputs: [String] = []

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
                TextEditor(text: $inputText)
                    .font(.body)
                if inputText.isEmpty {
                    Text("Paste or type text...")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }
            .frame(minHeight: 200)

            Toggle("Variants", isOn: $variantsEnabled)
                .toggleStyle(.switch)

            Button("Rephrase") {
                outputs = stubResults()
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rephrased")
                .font(.headline)
            ScrollView {
                if outputs.isEmpty {
                    emptyOutputState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(outputs.indices, id: \.self) { index in
                            RephraseVariantCard(
                                title: variantsEnabled ? "Variant \(index + 1)" : "Result",
                                text: outputs[index],
                                onCopy: { copyToPasteboard(outputs[index]) },
                                onReplace: { inputText = outputs[index] }
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

    private func stubResults() -> [String] {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let snippet = String(trimmed.prefix(160))
        if variantsEnabled {
            return [
                "(Stub) Variant 1: \(snippet)",
                "(Stub) Variant 2: \(snippet)",
                "(Stub) Variant 3: \(snippet)",
            ]
        }
        return ["(Stub) Rephrase: \(snippet)"]
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
