import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("settings.title")
                .font(.title2)

            Toggle("settings.keepHistory", isOn: $viewModel.keepHistory)
            Button("settings.clearHistory") {
                viewModel.clearHistory()
            }
            .disabled(!viewModel.keepHistory)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("settings.providerAccess.title")
                    .font(.headline)
                Text("settings.providerAccess.subtitle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("settings.providerAccess.manage") {
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
