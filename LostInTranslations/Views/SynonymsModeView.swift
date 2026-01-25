import SwiftUI

struct SynonymsModeView: View {
    @State private var query = ""
    @State private var selectedSynonym: String?

    var body: some View {
        HSplitView {
            inputPanel
            detailPanel
        }
    }

    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lookup")
                .font(.headline)
            TextField("Word or short phrase", text: $query)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 320)
            Spacer()
        }
        .padding()
    }

    private var detailPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Synonyms")
                .font(.headline)
            List(selection: $selectedSynonym) {
                ForEach(stubSynonyms, id: \.self) { synonym in
                    Text(synonym)
                        .tag(synonym)
                }
            }
            .frame(minHeight: 160)

            GroupBox("Usage Notes") {
                Text("Use the synonym that best matches the tone and formality of your text.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            GroupBox("Examples") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("“The result was remarkable.”")
                    Text("“She made an impressive improvement.”")
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

    private var stubSynonyms: [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return ["remarkable", "impressive", "notable", "extraordinary", "outstanding"]
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}
