import SwiftUI

/// Sidebar navigation for app modes.
struct SidebarView: View {
    /// Binding for the selected mode.
    @Binding var selectedMode: AppMode?
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel

    /// View body.
    var body: some View {
        List(selection: $selectedMode) {
            Section("sidebar.actions") {
                sidebarRow(for: .translate, count: nil)
                sidebarRow(for: .improve, count: nil)
                sidebarRow(for: .rephrase, count: nil)
                sidebarRow(for: .synonyms, count: nil)
            }

            Section("sidebar.library") {
                sidebarRow(for: .history, count: appModel.historyItems.count)
            }
        }
        .listStyle(.sidebar)
    }

    @ViewBuilder
    /// Builds a row label for a given mode.
    /// - Parameter mode: App mode to render.
    private func sidebarRow(for mode: AppMode, count: Int?) -> some View {
        HStack {
            Label(mode.displayName, systemImage: mode.systemImageName)
            Spacer()
            if let count, count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
            }
        }
        .tag(mode)
    }
}

extension AppMode {
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
    @State private var mode: AppMode? = .translate

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
