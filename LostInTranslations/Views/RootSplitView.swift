import SwiftUI

/// Root navigation shell for the app.
struct RootSplitView: View {
    /// Legacy view model used by the diagnostics UI.
    @ObservedObject var viewModel: MainViewModel
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel

    /// Root view body.
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedMode: sidebarSelection)
        } detail: {
            detailView
                .toolbar {
                    detailToolbar
                }
        }
    }

    /// Selection binding that avoids publishing during a view update pass.
    private var sidebarSelection: Binding<AppMode> {
        Binding(
            get: { appModel.selectedMode },
            set: { newValue in
                guard appModel.selectedMode != newValue else { return }
                Task { @MainActor in
                    appModel.selectedMode = newValue
                }
            }
        )
    }

    @ViewBuilder
    /// Detail content for the selected mode.
    private var detailView: some View {
        switch appModel.selectedMode {
        case .translate:
            TranslateModeView()
        case .improve:
            ImproveModeView()
        case .rephrase:
            RephraseModeView()
        case .synonyms:
            SynonymsModeView()
        case .history:
            HistoryModeView()
        }
    }

    @ToolbarContentBuilder
    /// Mode-specific toolbar content.
    private var detailToolbar: some ToolbarContent {
        if appModel.selectedMode == .translate {
            ToolbarItemGroup {
                Picker("toolbar.from", selection: $appModel.translateFromLanguage) {
                    ForEach(Language.allCases) { language in
                        Text(language.title).tag(language)
                    }
                }
                .frame(maxWidth: 140)

                TargetLanguagePillsView(languages: appModel.translateTargetLanguages) { language in
                    appModel.removeTargetLanguage(language)
                }

                Menu {
                    ForEach(Language.allCases.filter { $0 != .auto }) { language in
                        Button(language.title) {
                            appModel.addTargetLanguage(language)
                        }
                        .disabled(appModel.translateTargetLanguages.contains(language))
                    }
                } label: {
                    Label("toolbar.addLanguage", systemImage: "plus")
                }
                .disabled(appModel.translateTargetLanguages.count >= appModel.maxTargetLanguages)

                Picker("toolbar.purpose", selection: $appModel.selectedPurpose) {
                    ForEach(Purpose.allCases) { purpose in
                        Text(purpose.title).tag(purpose)
                    }
                }
                .pickerStyle(.menu)

                Picker("toolbar.tone", selection: $appModel.selectedTone) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.localizedName).tag(tone)
                    }
                }
                .pickerStyle(.menu)

                Button("toolbar.translate") {
                    appModel.performTranslate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appModel.canTranslate)
                .keyboardShortcut(.return, modifiers: .command)
            }
        } else {
            ToolbarItem {
                Button("toolbar.clear") {
                    appModel.clearCurrentMode()
                }
            }
        }
    }
}

/// Displays selected target languages as removable pills.
private struct TargetLanguagePillsView: View {
    /// Target languages to display.
    let languages: [Language]
    /// Callback for removal.
    let onRemove: (Language) -> Void

    /// View body.
    var body: some View {
        HStack(spacing: 6) {
            ForEach(languages) { language in
                HStack(spacing: 4) {
                    Text(language.code)
                    Button {
                        onRemove(language)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption2)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        Text(
                            String(
                                format: String(localized: "actions.removeLanguage"),
                                language.title
                            )
                        )
                    )
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.secondary.opacity(0.2)))
            }
        }
    }
}

#Preview {
    RootSplitView(viewModel: MainViewModel())
        .environmentObject(AppModel())
        .frame(width: 1100, height: 700)
}
