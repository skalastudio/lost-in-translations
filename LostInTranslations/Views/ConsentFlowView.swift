import SwiftUI

struct ConsentFlowView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("consent.title")
                .font(.title2)

            Text("consent.description")
                .font(.body)

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                ProviderCredentialRow(provider: .openAI)
                ProviderCredentialRow(provider: .claude)
                ProviderCredentialRow(provider: .gemini)
            }

            Spacer()

            HStack {
                Spacer()
                Button("consent.done") {
                    dismiss()
                }
            }
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 320)
    }
}

private struct ProviderCredentialRow: View {
    let provider: Provider
    @State private var apiKey = ""
    @State private var isStored = false
    @State private var statusMessage: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                let statusKey: LocalizedStringKey = isStored ? "consent.keyStored" : "consent.keyRequired"
                Text(provider.localizedName)
                    .font(.headline)
                Text(statusKey)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            SecureField("consent.apiKey.placeholder", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .frame(width: 220)
            Button("consent.save") {
                do {
                    guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        statusMessage = String(localized: "consent.enterKeyFirst")
                        return
                    }
                    try KeychainStore.saveKey(apiKey, for: provider)
                    apiKey = ""
                    isStored = true
                    statusMessage = String(localized: "consent.saved")
                } catch {
                    statusMessage = error.localizedDescription
                }
            }
            Button("consent.clear") {
                do {
                    try KeychainStore.deleteKey(for: provider)
                    isStored = false
                    statusMessage = String(localized: "consent.removed")
                } catch {
                    statusMessage = error.localizedDescription
                }
            }
        }
        .padding(8)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(8)
        .onAppear {
            isStored = KeychainStore.readKey(for: provider) != nil
        }
        if let statusMessage {
            Text(statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ConsentFlowView()
}
