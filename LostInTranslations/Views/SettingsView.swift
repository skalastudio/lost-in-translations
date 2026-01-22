import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)

            Toggle("Keep History", isOn: $viewModel.keepHistory)
            Button("Clear History") {
                viewModel.clearHistory()
            }
            .disabled(!viewModel.keepHistory)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Provider Access")
                    .font(.headline)
                Text("Connect each provider through a dedicated consent flow. Keys are stored in Keychain.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Manage Provider Access") {
                    viewModel.showConsentFlow = true
                }
            }

            Spacer()
        }
        .padding(20)
        .frame(minWidth: 420, minHeight: 280)
        .sheet(isPresented: $viewModel.showConsentFlow) {
            ConsentFlowView()
        }
    }
}

#Preview {
    let viewModel = MainViewModel()
    viewModel.keepHistory = true
    return SettingsView(viewModel: viewModel)
}
