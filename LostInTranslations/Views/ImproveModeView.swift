import SwiftUI

struct ImproveModeView: View {
    @EnvironmentObject private var appModel: AppModel

    private var hasOutput: Bool {
        !appModel.improveOutputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        HSplitView {
            inputPanel
            outputPanel
        }
    }

    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Original")
                .font(.headline)
            ZStack(alignment: .topLeading) {
                TextEditor(text: $appModel.improveInputText)
                    .font(.body)
                if appModel.improveInputText.isEmpty {
                    Text("Paste or type text...")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }
            }
            .frame(minHeight: 200)
        }
        .padding()
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Improved")
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
            .disabled(!appModel.canImprove)

            ScrollView {
                if appModel.improveIsRunning {
                    HStack(spacing: 6) {
                        ProgressView()
                            .controlSize(.small)
                        Text("Improving...")
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
                Button("Copy") {
                    copyToPasteboard(appModel.improveOutputText)
                }
                .disabled(!hasOutput)
                Button("Replace Input") {
                    appModel.improveInputText = appModel.improveOutputText
                }
                .disabled(!hasOutput)
                Spacer()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }

    private var emptyOutputState: some View {
        VStack(spacing: 6) {
            Text("Improved text will appear here")
                .font(.headline)
            Text("Choose a refinement to generate a result.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func copyToPasteboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

#Preview {
    let model = AppModel()
    model.improveInputText = "This is a draft that could be clearer."
    model.improveOutputText = "This draft is clearer and easier to read."
    return ImproveModeView()
        .environmentObject(model)
        .frame(width: 900, height: 520)
}
