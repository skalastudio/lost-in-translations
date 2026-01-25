import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var openAIKey = ""
    @State private var claudeKey = ""
    @State private var geminiKey = ""
    @State private var openAIStatus: String?
    @State private var claudeStatus: String?
    @State private var geminiStatus: String?

    var body: some View {
        TabView {
            generalTab
                .tabItem { Text("General") }
            providersTab
                .tabItem { Text("Providers") }
            modelsTab
                .tabItem { Text("Models") }
            outputTab
                .tabItem { Text("Output") }
            privacyTab
                .tabItem { Text("Privacy") }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 380)
        .onAppear(perform: loadKeys)
    }

    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("General")
                .font(.title2)
            Text("Basic app preferences will appear here.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var providersTab: some View {
        Form {
            providerSection(title: "OpenAI", key: $openAIKey, status: openAIStatus) {
                saveKey(openAIKey, provider: .openAI, status: &openAIStatus)
            }
            providerSection(title: "Claude", key: $claudeKey, status: claudeStatus) {
                saveKey(claudeKey, provider: .claude, status: &claudeStatus)
            }
            providerSection(title: "Gemini", key: $geminiKey, status: geminiStatus) {
                saveKey(geminiKey, provider: .gemini, status: &geminiStatus)
            }
        }
    }

    private var modelsTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Models")
                .font(.title2)
            Text("Model defaults and performance options will appear here.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var outputTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Output")
                .font(.title2)
            Text("Formatting and output preferences will appear here.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    private var privacyTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Privacy")
                .font(.title2)
            Text("Translations run locally in this app unless you use an external provider.")
                .foregroundStyle(.secondary)
            Text("Your history stays on this Mac.")
                .foregroundStyle(.secondary)

            Toggle("Store History locally", isOn: $appModel.storeHistoryLocally)
            Spacer()
        }
    }

    private func providerSection(
        title: String,
        key: Binding<String>,
        status: String?,
        onSave: @escaping () -> Void
    ) -> some View {
        Section(title) {
            SecureField("\(title) API Key", text: key)
            Button("Save", action: onSave)
            if let status {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func loadKeys() {
        openAIKey = KeychainStore.readKey(for: .openAI) ?? ""
        claudeKey = KeychainStore.readKey(for: .claude) ?? ""
        geminiKey = KeychainStore.readKey(for: .gemini) ?? ""
    }

    private func saveKey(_ key: String, provider: Provider, status: inout String?) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            if trimmed.isEmpty {
                try KeychainStore.deleteKey(for: provider)
                status = "Key removed."
            } else {
                try KeychainStore.saveKey(trimmed, for: provider)
                status = "Saved."
            }
        } catch {
            status = "Unable to save."
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppModel())
}
