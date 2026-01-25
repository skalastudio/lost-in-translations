import SwiftUI

/// Settings UI for the app.
struct SettingsView: View {
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel
    /// OpenAI API key input.
    @State private var openAIKey = ""
    /// Claude API key input.
    @State private var claudeKey = ""
    /// Gemini API key input.
    @State private var geminiKey = ""
    /// Status text for OpenAI key actions.
    @State private var openAIStatus: String?
    /// Status text for Claude key actions.
    @State private var claudeStatus: String?
    /// Status text for Gemini key actions.
    @State private var geminiStatus: String?

    /// View body.
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

    /// General settings tab.
    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("General")
                .font(.title2)
            Text("Basic app preferences will appear here.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Provider settings tab.
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

    /// Models settings tab.
    private var modelsTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Models")
                .font(.title2)
            Text("Model defaults and performance options will appear here.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Output settings tab.
    private var outputTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Output")
                .font(.title2)
            Text("Formatting and output preferences will appear here.")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Privacy settings tab.
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

    /// Builds a provider settings section.
    /// - Parameters:
    ///   - title: Section title.
    ///   - key: Bound API key field.
    ///   - status: Status message.
    ///   - onSave: Action when saving.
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

    /// Loads API keys from the keychain.
    private func loadKeys() {
        openAIKey = KeychainStore.readKey(for: .openAI) ?? ""
        claudeKey = KeychainStore.readKey(for: .claude) ?? ""
        geminiKey = KeychainStore.readKey(for: .gemini) ?? ""
    }

    /// Saves or deletes the API key for a provider.
    /// - Parameters:
    ///   - key: Raw key input.
    ///   - provider: Provider to update.
    ///   - status: Status string to update.
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

/// Preview for SettingsView.
#Preview {
    SettingsView()
        .environmentObject(AppModel())
}
