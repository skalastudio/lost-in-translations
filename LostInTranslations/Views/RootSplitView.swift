import SwiftUI

/// Root navigation shell for the app.
struct RootSplitView: View {
    /// Legacy view model used by the diagnostics UI.
    @ObservedObject var viewModel: MainViewModel
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel
    /// Sidebar selection stored locally to avoid publishing during view updates.
    @State private var sidebarMode: AppMode? = .translate

    /// Root view body.
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedMode: $sidebarMode)
        } detail: {
            detailView
                .toolbar {
                    detailToolbar
                }
        }
        .onAppear {
            sidebarMode = appModel.selectedMode
        }
        .onChange(of: sidebarMode) { _, newValue in
            guard let newValue, appModel.selectedMode != newValue else { return }
            Task { @MainActor in
                appModel.selectedMode = newValue
            }
        }
        .onChange(of: appModel.selectedMode) { _, newValue in
            guard sidebarMode != newValue else { return }
            sidebarMode = newValue
        }
    }

    @ViewBuilder
    /// Detail content for the selected mode.
    private var detailView: some View {
        switch sidebarMode ?? appModel.selectedMode {
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
        if (sidebarMode ?? appModel.selectedMode) != .translate {
            ToolbarItem {
                Button("toolbar.clear") {
                    appModel.clearCurrentMode()
                }
            }
        }
    }
}

#Preview {
    RootSplitView(viewModel: MainViewModel())
        .environmentObject(AppModel())
        .frame(width: 1100, height: 700)
}
