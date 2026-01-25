import SwiftUI

#Preview {
    let viewModel = MainViewModel()
    viewModel.inputText = "Preview input text"
    viewModel.results = [
        OutputResult(language: .english, text: "Hello there"),
        OutputResult(language: .portuguese, text: "Ola, tudo bem?"),
    ]
    viewModel.compareResults = [
        CompareResult(
            provider: .openAI,
            model: "gpt-4o-mini",
            results: viewModel.results,
            errorMessage: nil,
            isLoading: false,
            isSuccess: true,
            latencyMs: 420
        ),
        CompareResult(
            provider: .claude,
            model: nil,
            results: [],
            errorMessage: "Rate limited",
            isLoading: false,
            isSuccess: false,
            latencyMs: 980
        ),
    ]
    return MainView(viewModel: viewModel)
}
