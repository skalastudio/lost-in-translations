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
                Picker(
                    "Mode",
                    selection: Binding(
                        get: { viewModel.mode },
                        set: { newValue in
                            DispatchQueue.main.async {
                                if viewModel.mode != newValue {
                                    viewModel.mode = newValue
                                }
                            }
                        }
                    )
                ) {
                    ForEach(WritingMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Picker(
                    "Intent",
                    selection: Binding(
                        get: { viewModel.intent },
                        set: { newValue in
                            DispatchQueue.main.async {
                                if viewModel.intent != newValue {
                                    viewModel.intent = newValue
                                }
                            }
                        }
                    )
                ) {
                    ForEach(WritingIntent.allCases) { intent in
                        Text(intent.rawValue).tag(intent)
                    }
                }
                .frame(maxWidth: 130)

                Picker(
                    "Tone",
                    selection: Binding(
                        get: { viewModel.tone },
                        set: { newValue in
                            DispatchQueue.main.async {
                                if viewModel.tone != newValue {
                                    viewModel.tone = newValue
                                }
                            }
                        }
                    )
                ) {
                    ForEach(Tone.allCases) { tone in
                        Text(tone.rawValue).tag(tone)
                    }
                }
                .frame(maxWidth: 150)
            }

            HStack(spacing: 8) {
                Picker(
                    "Provider",
                    selection: Binding(
                        get: { viewModel.provider },
                        set: { newValue in
                            DispatchQueue.main.async {
                                if viewModel.provider != newValue {
                                    viewModel.provider = newValue
                                }
                            }
                        }
                    )
                ) {
                    ForEach(Provider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .frame(maxWidth: 140)

                Picker(
                    "Model",
                    selection: Binding(
                        get: { viewModel.modelTier },
                        set: { newValue in
                            DispatchQueue.main.async {
                                if viewModel.modelTier != newValue {
                                    viewModel.modelTier = newValue
                                }
                            }
                        }
                    )
                ) {
                    ForEach(ModelTier.allCases) { tier in
                        Text(tier.rawValue).tag(tier)
                    }
                }
                .frame(maxWidth: 140)

                Spacer()
            }

            DisclosureGroup("Advanced models") {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach([Provider.openAI, Provider.claude, Provider.gemini], id: \.self) { provider in
                        if let models = viewModel.advancedModels[provider] {
                            Text("\(provider.rawValue): \(models.joined(separator: ", "))")
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
                Text("Languages")
                    .font(.subheadline)
                Button("PT/EN/DE Preset") {
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

    var body: some View {
        HStack(spacing: 10) {
            Button(viewModel.isRunning ? "Running…" : "Run") {
                viewModel.runTask()
            }
            .disabled(viewModel.isRunning)

            Button("Copy All") {
                viewModel.copyAllResults()
            }
            .disabled(viewModel.results.isEmpty)

            Button("Clear") {
                viewModel.clearAll()
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
                Text("Results")
                    .font(.headline)
                Spacer()
            }

            if viewModel.provider == .auto {
                if viewModel.compareResults.isEmpty {
                    Text("Compare view will appear here when Auto is selected.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    CompareResultsGrid(viewModel: viewModel)
                }
            }

            ForEach(viewModel.results) { result in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(result.language.name)
                            .font(.subheadline)
                        Spacer()
                        Button("Copy") {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(result.text, forType: .string)
                        }
                        Button("Use this") {
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
                        Text(result.provider.rawValue)
                            .font(.headline)
                        Spacer()
                        StatusBadge(result: result)
                        if let latency = result.latencyMs {
                            Text("\(latency) ms")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text(result.model ?? "Unavailable")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if result.isLoading {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text("Retrying...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else if let errorMessage = result.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else {
                        ForEach(result.results) { item in
                            Text("\(item.language.code): \(item.text)")
                                .font(.caption)
                                .lineLimit(3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    Button("Use this set") {
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
            Button("Retry failed providers") {
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
            Text("Compare Summary")
                .font(.subheadline)
            Spacer()
            Text("Total \(total)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Running \(running)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Success \(success)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Failed \(failed)")
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
        return "Latency min \(minValue) ms | avg \(avgValue) ms | max \(maxValue) ms"
    }
}

private struct StatusBadge: View {
    let result: CompareResult

    var body: some View {
        let label: String
        let color: Color

        if result.isLoading {
            label = "Running"
            color = .gray
        } else if result.isSuccess {
            label = "Success"
            color = .green
        } else if result.errorMessage != nil {
            label = "Failed"
            color = .red
        } else {
            label = "Pending"
            color = .gray
        }

        return Text(label)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .cornerRadius(6)
            .animation(.easeInOut(duration: 0.2), value: label)
    }
}
