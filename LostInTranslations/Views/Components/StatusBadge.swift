import SwiftUI

/// Status badge for compare results.
struct StatusBadge: View {
    /// Compare result backing the badge.
    let result: CompareResult

    /// View body.
    var body: some View {
        let label: String
        let color: Color

        if result.isLoading {
            label = String(localized: "status.running")
            color = .gray
        } else if result.isSuccess {
            label = String(localized: "status.success")
            color = .green
        } else if result.errorMessage != nil {
            label = String(localized: "status.failed")
            color = .red
        } else {
            label = String(localized: "status.pending")
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

/// Preview for StatusBadge.
#Preview {
    StatusBadge(
        result: CompareResult(
            provider: .openAI,
            model: "gpt-4o-mini",
            results: [OutputResult(language: .english, text: "Hello")],
            errorMessage: nil,
            isLoading: false,
            isSuccess: true,
            latencyMs: 420
        )
    )
    .padding()
}
