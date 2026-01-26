import SwiftUI

/// Synonyms mode UI.
struct SynonymsModeView: View {
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel
    /// Current selection in the synonyms list.
    @State private var selectedSynonym: String?

    /// Whether the current provider supports synonyms mode.
    private var isSupported: Bool {
        appModel.isModeSupported(.synonyms)
    }

    /// View body.
    var body: some View {
        ZStack {
            HSplitView {
                inputPanel
                detailPanel
            }
            .disabled(!isSupported)

            if !isSupported {
                unsupportedOverlay
            }
        }
    }

    /// Input panel for synonyms lookup.
    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("synonyms.input.title")
                .font(.headline)
            TextField("synonyms.input.placeholder", text: $appModel.synonymsQuery)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 320)
                .onSubmit { appModel.performSynonyms() }
            Button("synonyms.action") {
                appModel.performSynonyms()
            }
            .disabled(!appModel.canLookupSynonyms || !isSupported)
            Spacer()
        }
        .padding()
    }

    /// Detail panel showing synonyms and notes.
    private var detailPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("synonyms.output.title")
                .font(.headline)
            if appModel.synonymsIsRunning {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("synonyms.output.loading")
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

            GroupBox("synonyms.usageNotes.title") {
                Text(
                    appModel.synonymsUsageNotes.isEmpty
                        ? String(localized: "synonyms.usageNotes.placeholder")
                        : appModel.synonymsUsageNotes
                )
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox("synonyms.examples.title") {
                VStack(alignment: .leading, spacing: 6) {
                    if appModel.synonymsExamples.isEmpty {
                        Text("synonyms.examples.placeholder")
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
                Button("synonyms.action.copySelected") {
                    copyToPasteboard(selectedSynonym ?? "")
                }
                .disabled((selectedSynonym ?? "").isEmpty)
                Button("synonyms.action.insertClipboard") {
                    copyToPasteboard(selectedSynonym ?? "")
                }
                .disabled((selectedSynonym ?? "").isEmpty)
                Spacer()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    /// Overlay shown when the provider does not support synonyms mode.
    private var unsupportedOverlay: some View {
        ContentUnavailableView {
            Text(
                String(
                    format: String(localized: "provider.capability.unavailable.title"),
                    appModel.selectedProvider.localizedName
                )
            )
        } description: {
            Text(
                String(
                    format: String(localized: "provider.capability.unavailable.subtitle"),
                    appModel.selectedProvider.localizedName
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
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
