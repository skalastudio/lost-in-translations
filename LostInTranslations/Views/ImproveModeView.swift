import SwiftUI

/// Improve text mode UI.
struct ImproveModeView: View {
    /// Shared application state.
    @EnvironmentObject private var appModel: AppModel

    /// Whether the current provider supports improve mode.
    private var isSupported: Bool {
        appModel.isModeSupported(.improve)
    }

    /// Whether the output has content.
    private var hasOutput: Bool {
        !appModel.improveOutputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// View body.
    var body: some View {
        ZStack {
            HSplitView {
                inputPanel
                outputPanel
            }
            .disabled(!isSupported)

            if !isSupported {
                unsupportedOverlay
            }
        }
    }

    /// Input panel for improvement.
    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("improve.input.title")
                .font(.headline)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $appModel.improveInputText)
                    .font(.body)
                if appModel.improveInputText.isEmpty {
                    Text("improve.input.placeholder")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }
            .frame(minHeight: 200)
        }
        .padding()
    }

    /// Output panel for improvements.
    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("improve.output.title")
                .font(.headline)
            HStack(spacing: 8) {
                Button(ImprovePreset.shorter.title) {
                    appModel.performImprove(preset: .shorter)
                }
                Button(ImprovePreset.moreFormal.title) {
                    appModel.performImprove(preset: .moreFormal)
                }
                Button(ImprovePreset.moreFriendly.title) {
                    appModel.performImprove(preset: .moreFriendly)
                }
            }
            .buttonStyle(.bordered)
            .disabled(!appModel.canImprove || !isSupported)

            ScrollView {
                if appModel.improveIsRunning {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("improve.output.loading")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                } else if let error = appModel.improveErrorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                } else if !hasOutput {
                    emptyOutputState
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                } else {
                    Text(appModel.improveOutputText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                }
            }
            .background(Color.secondary.opacity(0.08))
            .cornerRadius(6)
            .frame(minHeight: 160)

            HStack(spacing: 8) {
                Button("actions.copy") {
                    copyToPasteboard(appModel.improveOutputText)
                }
                .disabled(!hasOutput)
                Button("actions.replaceInput") {
                    appModel.improveInputText = appModel.improveOutputText
                }
                .disabled(!hasOutput)
                Spacer()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    /// Overlay shown when the provider does not support improve mode.
    private var unsupportedOverlay: some View {
        ContentUnavailableView {
            Text(
                String(
                    format: String(localized: "provider.capability.unavailable.title"),
                    appModel.selectedProvider.localizedName
                )
            )
        } description: {
            Text(
                String(
                    format: String(localized: "provider.capability.unavailable.subtitle"),
                    appModel.selectedProvider.localizedName
                )
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.background)
    }

    /// Empty state shown when there is no output.
    private var emptyOutputState: some View {
        VStack(spacing: 6) {
            Text("improve.output.empty.title")
                .font(.headline)
            Text("improve.output.empty.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// Copies text to the pasteboard.
    /// - Parameter text: Text to copy.
    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

/// Preview for ImproveModeView.
#Preview {
    let model = AppModel()
    model.improveInputText = "This is a draft that could be clearer."
    model.improveOutputText = "This draft is clearer and easier to read."
    return ImproveModeView()
        .environmentObject(model)
        .frame(width: 900, height: 520)
}
