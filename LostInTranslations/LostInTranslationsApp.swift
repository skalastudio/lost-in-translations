import SwiftUI

@main
struct LostInTranslationsApp: App {
    var body: some Scene {
        MenuBarExtra("Lost In Translations", systemImage: "text.bubble") {
            ContentView()
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lost In Translations")
                .font(.headline)
            Text("Menubar app scaffold is ready.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(minWidth: 240)
    }
}

struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .font(.headline)
            Text("Add preferences here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(minWidth: 360)
    }
}
