import SwiftUI

struct StatusBadge: View {
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
