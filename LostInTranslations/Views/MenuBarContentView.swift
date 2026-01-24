import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextEditor(text: $viewModel.inputText)
                .frame(minHeight: 90, maxHeight: 140)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                )

            ControlsRow(viewModel: viewModel)

            LanguagePickerRow(viewModel: viewModel)

            if let error = viewModel.lastInlineError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            ActionButtonsRow(viewModel: viewModel)

            ResultsSection(viewModel: viewModel)

            DiagnosticsView(diagnostics: viewModel.diagnostics)
        }
        .padding(12)
        .frame(width: 520)
    }
}

private struct ControlsRow: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Picker("controls.mode", selection: $viewModel.mode) {
                    ForEach(WritingMode.allCases) { mode in
                        Text(mode.localizedName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker("controls.intent", selection: $viewModel.intent) {
                    ForEach(WritingIntent.allCases) { intent in
                        Text(intent.localizedName).tag(intent)
                    }
                }
                .frame(maxWidth: 130)

                Picker("controls.tone", selection: $viewModel.tone) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.localizedName).tag(tone)
                    }
                }
                .frame(maxWidth: 150)
            }

            HStack(spacing: 8) {
                Picker("controls.provider", selection: $viewModel.provider) {
                    ForEach(Provider.allCases) { provider in
                        Text(provider.localizedName).tag(provider)
                    }
                }
                .frame(maxWidth: 140)

                Picker("controls.model", selection: $viewModel.modelTier) {
                    ForEach(ModelTier.allCases) { tier in
                        Text(tier.localizedName).tag(tier)
                    }
                }
                .frame(maxWidth: 140)

                Spacer()
            }

            DisclosureGroup("controls.advancedModels") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach([Provider.openAI, Provider.claude, Provider.gemini], id: \.self) { provider in
                        if let models = viewModel.advancedModels[provider] {
                            Text(
                                String(
                                    format: String(localized: "controls.advancedModels.line"),
                                    provider.localizedName,
                                    models.joined(separator: ", ")
                                )
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

private struct LanguagePickerRow: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text("controls.languages")
                    .font(.subheadline)
                Button("controls.preset") {
                    viewModel.applyPresetLanguages()
                }
                .buttonStyle(.link)
            }

            HStack(spacing: 8) {
                ForEach(LanguageOption.all) { option in
                    Button {
                        viewModel.toggleLanguage(option)
                    } label: {
                        Text(option.code)
                            .frame(minWidth: 36)
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.selectedLanguages.contains(option) ? .accentColor : .gray)
                }
            }
        }
    }
}

private struct ActionButtonsRow: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        HStack(spacing: 10) {
            let runTitle: LocalizedStringKey = viewModel.isRunning ? "actions.running" : "actions.run"
            Button(runTitle) {
                viewModel.runTask()
            }
            .disabled(viewModel.isRunning)

            Button("actions.copyAll") {
                viewModel.copyAllResults()
            }
            .disabled(viewModel.results.isEmpty)

            Button("actions.clear") {
                viewModel.clearAll()
            }

            Button("actions.settings") {
                openSettings()
            }
            Spacer()
        }
    }
}

private struct ResultsSection: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("results.title")
                    .font(.headline)
                Spacer()
            }

            if viewModel.provider == .auto {
                if viewModel.compareResults.isEmpty {
                    Text("results.comparePlaceholder")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    CompareResultsGrid(viewModel: viewModel)
                }
            }

            ForEach(viewModel.results) { result in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(result.language.localizedName)
                            .font(.subheadline)
                        Spacer()
                        Button("results.copy") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(result.text, forType: .string)
                        }
                        Button("results.useThis") {
                            viewModel.useResult(result)
                        }
                    }
                    Text(result.text)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
    }
}

private struct CompareResultsGrid: View {
    @ObservedObject var viewModel: MainViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]

    var body: some View {
        CompareSummaryRow(results: viewModel.compareResults)
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(viewModel.compareResults) { result in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(result.provider.localizedName)
                            .font(.headline)
                        Spacer()
                        StatusBadge(result: result)
                        if let latency = result.latencyMs {
                            Text(String(format: String(localized: "compare.latency"), latency))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(result.model ?? String(localized: "compare.modelUnavailable"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if result.isLoading {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text("compare.retrying")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if let errorMessage = result.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else {
                        ForEach(result.results) { item in
                            Text(
                                String(
                                    format: String(localized: "compare.itemSummary"),
                                    item.language.code,
                                    item.text
                                )
                            )
                            .font(.caption)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    Button("compare.useThisSet") {
                        viewModel.useCompareResult(result)
                    }
                    .disabled(result.isLoading || result.errorMessage != nil || result.results.isEmpty)
                }
                .padding(8)
                .background(Color.secondary.opacity(0.08))
                .cornerRadius(8)
            }
        }
        if viewModel.compareResults.contains(where: { $0.errorMessage != nil }) {
            Button("compare.retryFailed") {
                viewModel.retryFailedCompare()
            }
            .padding(.top, 8)
            .disabled(viewModel.isRunning)
        }
    }
}

private struct CompareSummaryRow: View {
    let results: [CompareResult]

    var body: some View {
        let running = results.filter(\.isLoading).count
        let success = results.filter(\.isSuccess).count
        let failed = results.filter { $0.errorMessage != nil }.count
        let total = results.count
        let latencies = results.compactMap(\.latencyMs)
        let latencySummary = formatLatencySummary(latencies)

        return HStack(spacing: 8) {
            Text("compare.summary.title")
                .font(.subheadline)
            Spacer()
            Text(String(format: String(localized: "compare.summary.total"), total))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(format: String(localized: "compare.summary.running"), running))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(format: String(localized: "compare.summary.success"), success))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(String(format: String(localized: "compare.summary.failed"), failed))
                .font(.caption)
                .foregroundStyle(.secondary)
            if let latencySummary {
                Text(latencySummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: running)
        .animation(.easeInOut(duration: 0.2), value: success)
        .animation(.easeInOut(duration: 0.2), value: failed)
        .padding(.vertical, 4)
    }

    private func formatLatencySummary(_ latencies: [Int]) -> String? {
        guard !latencies.isEmpty else { return nil }
        let minValue = latencies.min() ?? 0
        let maxValue = latencies.max() ?? 0
        let avgValue = latencies.reduce(0, +) / max(latencies.count, 1)
        return String(
            format: String(localized: "compare.summary.latency"),
            minValue,
            avgValue,
            maxValue
        )
    }
}
