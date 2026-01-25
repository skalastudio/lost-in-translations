import SwiftUI

/// Synonyms mode UI.
struct SynonymsModeView: View {
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel
    /// Current selection in the synonyms list.
    @State private var selectedSynonym: String?

    /// View body.
    var body: some View {
        HSplitView {
            inputPanel
            detailPanel
        }
    }

    /// Input panel for synonyms lookup.
    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lookup")
                .font(.headline)
            TextField("Word or short phrase", text: $appModel.synonymsQuery)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 320)
                .onSubmit { appModel.performSynonyms() }
            Button("Find Synonyms") {
                appModel.performSynonyms()
            }
            .disabled(!appModel.canLookupSynonyms)
            Spacer()
        }
        .padding()
    }

    /// Detail panel showing synonyms and notes.
    private var detailPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Synonyms")
                .font(.headline)
            if appModel.synonymsIsRunning {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Looking up...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else if let error = appModel.synonymsErrorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            List(selection: $selectedSynonym) {
                ForEach(appModel.synonymsResults, id: \.self) { synonym in
                    Text(synonym)
                        .tag(synonym)
                }
            }
            .frame(minHeight: 160)

            GroupBox("Usage Notes") {
                Text(
                    appModel.synonymsUsageNotes.isEmpty
                        ? "Usage notes will appear here."
                        : appModel.synonymsUsageNotes
                )
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox("Examples") {
                VStack(alignment: .leading, spacing: 6) {
                    if appModel.synonymsExamples.isEmpty {
                        Text("Examples will appear here.")
                    } else {
                        ForEach(appModel.synonymsExamples, id: \.self) { example in
                            Text(example)
                        }
                    }
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 8) {
                Button("Copy Selected") {
                    copyToPasteboard(selectedSynonym ?? "")
                }
                .disabled((selectedSynonym ?? "").isEmpty)
                Button("Insert into Clipboard") {
                    copyToPasteboard(selectedSynonym ?? "")
                }
                .disabled((selectedSynonym ?? "").isEmpty)
                Spacer()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    /// Copies text to the pasteboard.
    /// - Parameter text: Text to copy.
    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

/// Preview for SynonymsModeView.
#Preview {
    let model = AppModel()
    model.synonymsQuery = "remarkable"
    model.synonymsResults = ["impressive", "notable", "extraordinary"]
    model.synonymsUsageNotes = "Use the synonym that best fits your tone."
    model.synonymsExamples = [
        "The result was remarkable.",
        "She made an impressive improvement.",
    ]
    return SynonymsModeView()
        .environmentObject(model)
        .frame(width: 900, height: 520)
}
