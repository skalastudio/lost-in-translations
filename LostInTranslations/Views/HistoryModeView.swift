import SwiftUI

struct HistoryModeView: View {
    @EnvironmentObject private var appModel: AppModel
    @State private var selection: HistoryItemID?

    var body: some View {
        List(selection: $selection) {
            ForEach(appModel.historyItems) { item in
                Button {
                    restore(item)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.inputPreview)
                            .font(.headline)
                            .lineLimit(2)
                        HStack(spacing: 6) {
                            Text(item.mode.displayName)
                            Text("•")
                            Text(item.subtitle)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                }
                .buttonStyle(.plain)
                .tag(item.id)
                .overlay(alignment: .trailing) {
                    Text(dateTimeString(from: item.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay {
            if appModel.historyItems.isEmpty {
                if #available(macOS 14.0, *) {
                    ContentUnavailableView {
                        Label("No History Yet", systemImage: "clock.arrow.circlepath")
                    } description: {
                        Text("Run a translation to see recent items here.")
                    } actions: {
                        Text("Tip: Press \u{2318}\u{21A9} to translate.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 8) {
                        Label("No History Yet", systemImage: "clock.arrow.circlepath")
                            .font(.title3)
                        Text("Run a translation to see recent items here.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        Text("Tip: Press \u{2318}\u{21A9} to translate.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Clear History") {
                    appModel.clearHistory()
                }
                .disabled(!appModel.hasHistory)
            }
        }
    }

    private func restore(_ item: HistoryItem) {
        appModel.translateInputText = item.inputText
        appModel.translateTargetLanguages = item.targetLanguages
        appModel.selectedPurpose = item.purpose
        appModel.selectedTone = item.tone
        appModel.performTranslate()
        appModel.selectedMode = .translate
    }

    private func dateTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
