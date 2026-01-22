import SwiftData
import SwiftUI

@main
struct LostInTranslationsApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var viewModel: MainViewModel

    init() {
        do {
            let container = try ModelContainer(for: HistoryEntry.self)
            modelContainer = container
            _viewModel = StateObject(wrappedValue: MainViewModel(historyStore: HistoryStore(container: container)))
        } catch {
            fatalError("Unable to initialize SwiftData: \(error)")
        }
    }

    var body: some Scene {
        MenuBarExtra("Lost In Translations", systemImage: "text.bubble") {
            MenuBarContentView(viewModel: viewModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(viewModel: viewModel)
        }
        .modelContainer(modelContainer)
    }
}
