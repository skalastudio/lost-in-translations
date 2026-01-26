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
                .tabItem { Text("settings.tab.general") }
            providersTab
                .tabItem { Text("settings.tab.providers") }
            modelsTab
                .tabItem { Text("settings.tab.models") }
            outputTab
                .tabItem { Text("settings.tab.output") }
            privacyTab
                .tabItem { Text("settings.tab.privacy") }
        }
        .padding(20)
        .frame(minWidth: 520, minHeight: 380)
        .onAppear(perform: loadKeys)
    }

    /// General settings tab.
    private var generalTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("settings.general.title")
                .font(.title2)
            Text("settings.general.subtitle")
                .foregroundStyle(.secondary)
            Picker("settings.general.provider", selection: $appModel.selectedProvider) {
                ForEach(Provider.allCases) { provider in
                    Text(provider.localizedName).tag(provider)
                }
            }
            .pickerStyle(.menu)
            Text("settings.general.provider.help")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Provider settings tab.
    private var providersTab: some View {
        Form {
            providerSection(
                title: String(localized: "settings.providers.openai"),
                key: $openAIKey,
                status: openAIStatus
            ) {
                saveKey(openAIKey, provider: .openAI, status: &openAIStatus)
            }
            providerSection(
                title: String(localized: "settings.providers.claude"),
                key: $claudeKey,
                status: claudeStatus
            ) {
                saveKey(claudeKey, provider: .claude, status: &claudeStatus)
            }
            providerSection(
                title: String(localized: "settings.providers.gemini"),
                key: $geminiKey,
                status: geminiStatus
            ) {
                saveKey(geminiKey, provider: .gemini, status: &geminiStatus)
            }
            Section {
                Text("settings.providers.apple.note")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("settings.providers.apple")
            }
        }
    }

    /// Models settings tab.
    private var modelsTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("settings.models.title")
                .font(.title2)
            Text("settings.models.subtitle")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Output settings tab.
    private var outputTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("settings.output.title")
                .font(.title2)
            Text("settings.output.subtitle")
                .foregroundStyle(.secondary)
            Spacer()
        }
    }

    /// Privacy settings tab.
    private var privacyTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("settings.privacy.title")
                .font(.title2)
            Text("settings.privacy.subtitle")
                .foregroundStyle(.secondary)
            Text("settings.privacy.historyNote")
                .foregroundStyle(.secondary)

            Toggle("settings.privacy.storeHistory", isOn: $appModel.storeHistoryLocally)
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
        Section {
            SecureField(
                String(format: String(localized: "settings.providers.apiKey.placeholder"), title),
                text: key
            )
            Button("actions.save", action: onSave)
            if let status {
                Text(status)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(title)
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
                status = String(localized: "settings.providers.status.removed")
            } else {
                try KeychainStore.saveKey(trimmed, for: provider)
                status = String(localized: "settings.providers.status.saved")
            }
            appModel.refreshProviderAvailability()
        } catch {
            status = String(localized: "settings.providers.status.failed")
        }
    }
}

/// Preview for SettingsView.
#Preview {
    SettingsView()
        .environmentObject(AppModel())
}
