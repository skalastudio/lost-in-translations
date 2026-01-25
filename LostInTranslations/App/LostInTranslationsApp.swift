import SwiftData
import SwiftUI

/// App entry point and scene configuration.
@main
@MainActor
struct LostInTranslationsApp: App {
    /// SwiftData container used by history storage.
    private let modelContainer: ModelContainer
    /// View model used for the legacy provider compare UI.
    @StateObject private var viewModel: MainViewModel
    /// Shared application state for the SwiftUI UI.
    @StateObject private var appModel = AppModel()

    /// Creates the app and configures persistence.
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

    /// The app scenes for the main window and settings.
    var body: some Scene {
        WindowGroup {
            RootSplitView(viewModel: viewModel)
                .environmentObject(appModel)
        }
        .modelContainer(modelContainer)

        Settings {
            SettingsView()
                .environmentObject(appModel)
        }
        .modelContainer(modelContainer)
    }
}
