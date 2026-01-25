import SwiftUI

struct SidebarView: View {
    @Binding var selectedMode: AppMode
    @EnvironmentObject private var appModel: AppModel

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
    private func sidebarRow(for mode: AppMode) -> some View {
        Label(mode.title, systemImage: mode.systemImageName)
            .tag(mode)
    }
}

extension AppMode {
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

private struct SidebarPreview: View {
    @State private var mode: AppMode = .translate

    var body: some View {
        SidebarView(selectedMode: $mode)
            .environmentObject(AppModel())
            .frame(width: 240, height: 400)
    }
}

#Preview {
    SidebarPreview()
}
