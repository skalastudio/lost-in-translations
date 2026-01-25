import SwiftUI

struct ImproveModeView: View {
    @State private var inputText = ""
    @State private var outputText = ""

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
        }
        .padding()
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Improved")
                .font(.headline)
            HStack(spacing: 8) {
                Button("Shorter") {
                    outputText = stubResult(prefix: "Shorter")
                }
                Button("More formal") {
                    outputText = stubResult(prefix: "More formal")
                }
                Button("More friendly") {
                    outputText = stubResult(prefix: "More friendly")
                }
            }
            .buttonStyle(.bordered)

            ScrollView {
                if outputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    emptyOutputState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                } else {
                    Text(outputText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
            .background(Color.secondary.opacity(0.08))
            .cornerRadius(6)
            .frame(minHeight: 160)

            HStack(spacing: 8) {
                Button("Copy") {
                    copyToPasteboard(outputText)
                }
                .disabled(outputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Button("Replace Input") {
                    inputText = outputText
                }
                .disabled(outputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var emptyOutputState: some View {
        VStack(spacing: 6) {
            Text("Improved text will appear here")
                .font(.headline)
            Text("Choose a refinement to generate a stubbed result.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func stubResult(prefix: String) -> String {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let snippet = String(trimmed.prefix(160))
        return "(Stub) \(prefix): \(snippet)"
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
