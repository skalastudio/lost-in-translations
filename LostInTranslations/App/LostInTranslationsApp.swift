import SwiftData
import SwiftUI

@main
@MainActor
struct LostInTranslationsApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var viewModel: MainViewModel

    init() {
        #if DEBUG
            let arguments = ProcessInfo.processInfo.arguments
            if arguments.contains(AppConstants.LaunchArguments.useMockProvider)
                || arguments.contains("-\(AppConstants.LaunchArguments.useMockProvider)")
            {
                print("[MockProvider] Enabled via \(AppConstants.LaunchArguments.useMockProvider) launch argument.")
            }
        #endif
        do {
            let container = try ModelContainer(for: HistoryEntry.self)
            modelContainer = container
            _viewModel = StateObject(wrappedValue: MainViewModel(historyStore: HistoryStore(container: container)))
        } catch {
            fatalError(String(format: String(localized: "error.swiftdata.init"), error.localizedDescription))
        }
    }

    var body: some Scene {
        MenuBarExtra("app.title", systemImage: "text.bubble") {
            MenuBarContentView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(viewModel: viewModel)
        }
        .modelContainer(modelContainer)
    }
}
