import SwiftUI

struct RootSplitView: View {
    @ObservedObject var viewModel: MainViewModel
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        NavigationSplitView {
            SidebarView(selectedMode: $appModel.selectedMode)
        } detail: {
            detailView
                .toolbar {
                    detailToolbar
                }
        }
    }

    @ViewBuilder
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
    private var detailToolbar: some ToolbarContent {
        if appModel.selectedMode == .translate {
            ToolbarItemGroup {
                Picker("From", selection: $appModel.translateFromLanguage) {
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
                    Label("Add Language", systemImage: "plus")
                }
                .disabled(appModel.translateTargetLanguages.count >= appModel.maxTargetLanguages)

                Picker("Purpose", selection: $appModel.selectedPurpose) {
                    ForEach(Purpose.allCases) { purpose in
                        Text(purpose.title).tag(purpose)
                    }
                }
                .pickerStyle(.menu)

                Picker("Tone", selection: $appModel.selectedTone) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.localizedName).tag(tone)
                    }
                }
                .pickerStyle(.menu)

                Button("Translate") {
                    appModel.performTranslate()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!appModel.canTranslate)
                .keyboardShortcut(.return, modifiers: .command)
            }
        } else {
            ToolbarItem {
                Button("Clear") {
                    appModel.clearCurrentMode()
                }
            }
        }
    }
}

private struct TargetLanguagePillsView: View {
    let languages: [Language]
    let onRemove: (Language) -> Void

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
                    .accessibilityLabel("Remove \(language.title)")
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.secondary.opacity(0.2)))
            }
        }
    }
}
