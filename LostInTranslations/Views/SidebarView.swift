import SwiftUI

/// Sidebar navigation for app modes.
struct SidebarView: View {
    /// Binding for the selected mode.
    @Binding var selectedMode: AppMode
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel

    /// View body.
    var body: some View {
        List(selection: $selectedMode) {
            Section("Actions") {
                sidebarRow(for: .translate)
                sidebarRow(for: .improve)
                sidebarRow(for: .rephrase)
                sidebarRow(for: .synonyms)
            }

            Section("Library") {
                sidebarRow(for: .history)
                    .badge(appModel.historyItems.count)
            }
        }
        .listStyle(.sidebar)
    }

    @ViewBuilder
    /// Builds a row label for a given mode.
    /// - Parameter mode: App mode to render.
    private func sidebarRow(for mode: AppMode) -> some View {
        Label(mode.title, systemImage: mode.systemImageName)
            .tag(mode)
    }
}

extension AppMode {
    /// Sidebar title for a mode.
    fileprivate var title: String {
        switch self {
        case .translate:
            return "Translate"
        case .improve:
            return "Improve Text"
        case .rephrase:
            return "Rephrase"
        case .synonyms:
            return "Synonyms"
        case .history:
            return "History"
        }
    }

    /// Sidebar system image name for a mode.
    fileprivate var systemImageName: String {
        switch self {
        case .translate:
            return "globe"
        case .improve:
            return "wand.and.stars"
        case .rephrase:
            return "arrow.triangle.2.circlepath"
        case .synonyms:
            return "text.book.closed"
        case .history:
            return "clock.arrow.circlepath"
        }
    }
}

/// Preview wrapper for SidebarView.
private struct SidebarPreview: View {
    /// Preview selection state.
    @State private var mode: AppMode = .translate

    /// Preview body.
    var body: some View {
        SidebarView(selectedMode: $mode)
            .environmentObject(AppModel())
            .frame(width: 240, height: 400)
    }
}

#Preview {
    SidebarPreview()
}
