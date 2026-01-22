import SwiftUI

struct DiagnosticsView: View {
    let diagnostics: DiagnosticsState

    var body: some View {
        DisclosureGroup("Diagnostics") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Last provider: \(diagnostics.lastProvider?.rawValue ?? "—")")
                Text("Last model: \(diagnostics.lastModel ?? "—")")
                Text("Token estimate: \(diagnostics.tokenEstimate.map(String.init) ?? "—")")
                Text("Latency: \(diagnostics.latencyMs.map { "\($0) ms" } ?? "—")")
                if let error = diagnostics.lastError {
                    Text("Last error: \(error)")
                        .foregroundStyle(.red)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding(.top, 6)
    }
}

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
