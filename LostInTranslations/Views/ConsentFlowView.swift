import SwiftUI

struct ConsentFlowView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Provider Consent")
                .font(.title2)

            Text(
                "Complete consent flows here for OpenAI, Claude, and Gemini. "
                    + "This is separate from any account-level login."
            )
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
                Button("Done") {
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
                Text(provider.rawValue)
                    .font(.headline)
                Text(isStored ? "Key stored in Keychain." : "Requires API key and explicit consent.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            SecureField("API key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .frame(width: 220)
            Button("Save") {
                do {
                    guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                        statusMessage = "Enter a key first."
                        return
                    }
                    try KeychainStore.saveKey(apiKey, for: provider)
                    apiKey = ""
                    isStored = true
                    statusMessage = "Saved."
                } catch {
                    statusMessage = error.localizedDescription
                }
            }
            Button("Clear") {
                do {
                    try KeychainStore.deleteKey(for: provider)
                    isStored = false
                    statusMessage = "Removed."
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
