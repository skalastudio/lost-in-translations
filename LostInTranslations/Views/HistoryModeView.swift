import SwiftUI

/// History mode UI.
struct HistoryModeView: View {
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel
    /// Selected history item identifier.
    @State private var selection: HistoryItemID?
    /// Search query for history filtering.
    @State private var searchText: String = ""
    /// Selected mode filter for history.
    @State private var selectedModeFilter: AppMode?
    /// Selected tone filter for history.
    @State private var selectedToneFilter: Tone?

    /// View body.
    var body: some View {
        VStack(spacing: 12) {
            historyFilters
            List(selection: $selection) {
                ForEach(filteredItems) { item in
                    Button {
                        restore(item)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Text(item.mode.displayName)
                                Text("•")
                                Text(item.subtitle)
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .padding(.bottom, 2)

                            Text(item.inputPreview)
                                .font(.headline)
                                .lineLimit(2)
                                .padding(.bottom, 2)

                            Text(dateTimeString(from: item.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .tag(item.id)
                }
            }
            .overlay {
                if appModel.historyItems.isEmpty {
                    historyEmptyState
                } else if filteredItems.isEmpty {
                    noResultsState
                }
            }
        }
        .padding(.top, 4)
        .toolbar {
            ToolbarItem {
                Button("history.clear") {
                    appModel.clearHistory()
                }
                .disabled(!appModel.hasHistory)
            }
        }
    }

    /// Restores state from a history item.
    /// - Parameter item: History item to restore.
    private func restore(_ item: HistoryItem) {
        appModel.translateInputText = item.inputText
        appModel.translateTargetLanguages = item.targetLanguages
        appModel.selectedPurpose = item.purpose
        appModel.selectedTone = item.tone
        appModel.performTranslate()
        Task { @MainActor in
            appModel.selectedMode = .translate
        }
    }

    /// Formats a date for list display.
    /// - Parameter date: Date to format.
    /// - Returns: Localized date/time string.
    private func dateTimeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Filtered history items based on search and quick filters.
    private var filteredItems: [HistoryItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return appModel.historyItems.filter { item in
            let matchesMode = selectedModeFilter.map { $0 == item.mode } ?? true
            let matchesTone = selectedToneFilter.map { $0 == item.tone } ?? true
            let matchesSearch =
                query.isEmpty
                || item.inputText.range(of: query, options: [.caseInsensitive, .diacriticInsensitive])
                    != nil
            return matchesMode && matchesTone && matchesSearch
        }
    }

    /// Search and filter controls for the history list.
    private var historyFilters: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("history.search.placeholder", text: $searchText)
                .textFieldStyle(.roundedBorder)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text("history.filter.actions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    filterButton(title: String(localized: "history.filter.all")) {
                        selectedModeFilter = nil
                    }
                    .disabled(selectedModeFilter == nil)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(AppMode.allCases.filter { $0 != .history }) { mode in
                            filterButton(title: mode.displayName, isSelected: selectedModeFilter == mode) {
                                selectedModeFilter = selectedModeFilter == mode ? nil : mode
                            }
                        }
                    }
                }

                HStack(spacing: 6) {
                    Text("history.filter.tone")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    filterButton(title: String(localized: "history.filter.all")) {
                        selectedToneFilter = nil
                    }
                    .disabled(selectedToneFilter == nil)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(Tone.allCases) { tone in
                            filterButton(title: tone.localizedName, isSelected: selectedToneFilter == tone) {
                                selectedToneFilter = selectedToneFilter == tone ? nil : tone
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    /// Empty state shown when there is no history.
    @ViewBuilder
    private var historyEmptyState: some View {
        if #available(macOS 14.0, *) {
            ContentUnavailableView {
                Label("history.empty.title", systemImage: "clock.arrow.circlepath")
            } description: {
                Text("history.empty.subtitle")
            } actions: {
                Text("history.empty.tip")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(spacing: 8) {
                Label("history.empty.title", systemImage: "clock.arrow.circlepath")
                    .font(.title3)
                Text("history.empty.subtitle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text("history.empty.tip")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Empty state shown when filters return no results.
    @ViewBuilder
    private var noResultsState: some View {
        if #available(macOS 14.0, *) {
            ContentUnavailableView {
                Text("history.search.empty.title")
            } description: {
                Text("history.search.empty.subtitle")
            }
        } else {
            VStack(spacing: 6) {
                Text("history.search.empty.title")
                    .font(.headline)
                Text("history.search.empty.subtitle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Builds a filter button with selection styling.
    @ViewBuilder
    private func filterButton(
        title: String,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        if isSelected {
            Button(title, action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
        } else {
            Button(title, action: action)
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
    }
}

/// Preview for HistoryModeView.
#Preview {
    let model = AppModel()
    model.historyItems = [
        HistoryItem(
            mode: .translate,
            inputText: "Hello, how are you?",
            inputPreview: "Hello, how are you?",
            date: Date(),
            targetLanguages: [.portuguese, .german],
            purpose: .chat,
            tone: .neutral
        )
    ]
    return HistoryModeView()
        .environmentObject(model)
        .frame(width: 900, height: 520)
}
