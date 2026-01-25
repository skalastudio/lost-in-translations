import SwiftUI

/// Diagnostics disclosure view for provider runs.
struct DiagnosticsView: View {
    /// Diagnostics state to display.
    let diagnostics: DiagnosticsState

    /// View body.
    var body: some View {
        let placeholder = String(localized: "diagnostics.placeholder")

        DisclosureGroup("diagnostics.title") {
            VStack(alignment: .leading, spacing: 4) {
                Text(
                    String(
                        format: String(localized: "diagnostics.lastProvider"),
                        diagnostics.lastProvider?.localizedName ?? placeholder
                    )
                )
                Text(
                    String(
                        format: String(localized: "diagnostics.lastModel"),
                        diagnostics.lastModel ?? placeholder
                    )
                )
                Text(
                    String(
                        format: String(localized: "diagnostics.tokenEstimate"),
                        diagnostics.tokenEstimate.map(String.init) ?? placeholder
                    )
                )
                Text(
                    String(
                        format: String(localized: "diagnostics.latency"),
                        diagnostics.latencyMs.map { String(format: String(localized: "compare.latency"), $0) }
                            ?? placeholder
                    )
                )
                if let error = diagnostics.lastError {
                    Text(String(format: String(localized: "diagnostics.lastError"), error))
                        .foregroundStyle(.red)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
    }
}

/// Preview for DiagnosticsView.
#Preview {
    DiagnosticsView(
        diagnostics: DiagnosticsState(
            lastProvider: .openAI,
            lastModel: "gpt-4o-mini",
            tokenEstimate: 120,
            latencyMs: 640,
            lastError: nil
        )
    )
}
