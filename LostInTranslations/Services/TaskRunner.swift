import Foundation
import OSLog

/// Coordinates provider selection and executes tasks.
actor TaskRunner {
    /// Prompt builder used for token estimation.
    private let builder = TaskSpecBuilder()
    /// Internal compare task wrapper.
    private struct CompareTask {
        /// Provider identifier.
        let provider: Provider
        /// Provider client instance.
        let client: ProviderClient
        /// API key for the provider.
        let key: String
    }

    /// Whether the mock provider is enabled via launch arguments.
    private static let useMockProvider: Bool = {
        #if DEBUG
            let arguments = ProcessInfo.processInfo.arguments
            let enabled =
                arguments.contains(AppConstants.LaunchArguments.useMockProvider)
                || arguments.contains("-\(AppConstants.LaunchArguments.useMockProvider)")
            if enabled {
                Logger(
                    subsystem: AppConstants.Logging.subsystem,
                    category: AppConstants.Logging.mockProviderCategory
                )
                .info("Mock provider enabled via \(AppConstants.LaunchArguments.useMockProvider) launch argument.")
            }
            return enabled
        #else
            return false
        #endif
    }()

    /// Provider client registry.
    private let clients: [Provider: ProviderClient] = [
        .openAI: OpenAIClient(),
        .claude: ClaudeClient(),
        .gemini: GeminiClient(),
        .appleTranslation: AppleTranslationClient(),
    ]

    /// Runs a single provider task.
    /// - Parameter spec: The task specification.
    /// - Returns: Task output from the selected provider.
    func run(spec: TaskSpec) async throws -> TaskRunOutput {
        let provider = try resolveProvider(from: spec.provider)
        let apiKey = try readKey(for: provider)
        let client = try client(for: provider)
        let result = try await client.run(spec: spec, apiKey: apiKey)
        let tokenEstimate = builder.estimateTokens(for: spec.inputText)
        return TaskRunOutput(
            results: result.results,
            provider: provider,
            model: result.model,
            tokenEstimate: tokenEstimate
        )
    }

    /// Runs a compare task across all available providers.
    /// - Parameter spec: The task specification.
    /// - Returns: Compare output with per-provider results.
    func runCompare(spec: TaskSpec) async throws -> CompareRunOutput {
        let tasks = compareTasks(for: availableProviders())
        guard !tasks.isEmpty else {
            throw ProviderError.missingKey(.openAI)
        }
        return try await runCompare(spec: spec, tasks: tasks)
    }

    /// Runs a compare task across specific providers.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - providers: Providers to include.
    /// - Returns: Compare output with per-provider results.
    func runCompare(spec: TaskSpec, providers: [Provider]) async throws -> CompareRunOutput {
        let tasks = compareTasks(for: providers)
        guard !tasks.isEmpty else {
            throw ProviderError.missingKey(.openAI)
        }
        return try await runCompare(spec: spec, tasks: tasks)
    }

    private func runCompare(
        spec: TaskSpec,
        tasks: [CompareTask]
    ) async throws -> CompareRunOutput {
        let results = try await withThrowingTaskGroup(of: CompareResult.self) { group in
            for task in tasks {
                group.addTask {
                    let start = Date()
                    do {
                        let result = try await task.client.run(spec: spec, apiKey: task.key)
                        return CompareResult(
                            provider: task.provider,
                            model: result.model,
                            results: result.results,
                            errorMessage: nil,
                            isLoading: false,
                            isSuccess: true,
                            latencyMs: Int(Date().timeIntervalSince(start) * 1000)
                        )
                    } catch {
                        return CompareResult(
                            provider: task.provider,
                            model: nil,
                            results: [],
                            errorMessage: error.localizedDescription,
                            isLoading: false,
                            isSuccess: false,
                            latencyMs: Int(Date().timeIntervalSince(start) * 1000)
                        )
                    }
                }
            }

            var collected: [CompareResult] = []
            for try await item in group {
                collected.append(item)
            }
            return collected
        }
        let tokenEstimate = builder.estimateTokens(for: spec.inputText)
        return CompareRunOutput(results: results, tokenEstimate: tokenEstimate)
    }

    /// Builds compare tasks for the given providers.
    /// - Parameter providers: Providers to include.
    /// - Returns: Compare task descriptors.
    private func compareTasks(for providers: [Provider]) -> [CompareTask] {
        if Self.useMockProvider {
            return providers.map { provider in
                CompareTask(
                    provider: provider,
                    client: MockProviderClient(provider: provider),
                    key: "mock"
                )
            }
        }
        return providers.compactMap { provider in
            guard let client = clients[provider] else { return nil }
            if provider.requiresAPIKey {
                guard let key = KeychainStore.readKey(for: provider) else {
                    return nil
                }
                return CompareTask(provider: provider, client: client, key: key)
            }
            return CompareTask(provider: provider, client: client, key: "system")
        }
    }

    /// Resolves the provider to use from the selection.
    /// - Parameter selection: The user-selected provider.
    /// - Returns: A concrete provider.
    private func resolveProvider(from selection: Provider) throws -> Provider {
        if Self.useMockProvider {
            return selection == .auto ? .openAI : selection
        }
        if selection != .auto {
            return selection
        }
        for provider in [Provider.openAI, Provider.claude, Provider.gemini]
        where KeychainStore.readKey(for: provider) != nil {
            return provider
        }
        return .appleTranslation
    }

    /// Returns providers that are currently available.
    private func availableProviders() -> [Provider] {
        if Self.useMockProvider {
            return [.openAI, .claude, .gemini, .appleTranslation]
        }
        let keyedProviders = [Provider.openAI, Provider.claude, Provider.gemini].filter { provider in
            KeychainStore.readKey(for: provider) != nil
        }
        return keyedProviders + [.appleTranslation]
    }

    /// Reads the API key for a provider or throws.
    /// - Parameter provider: Provider to read the key for.
    /// - Returns: API key string.
    private func readKey(for provider: Provider) throws -> String {
        if Self.useMockProvider {
            return "mock"
        }
        if !provider.requiresAPIKey {
            return "system"
        }
        guard let key = KeychainStore.readKey(for: provider) else {
            throw ProviderError.missingKey(provider)
        }
        return key
    }

    /// Returns a provider client for the given provider.
    /// - Parameter provider: Provider to use.
    /// - Returns: Provider client instance.
    private func client(for provider: Provider) throws -> ProviderClient {
        if Self.useMockProvider {
            return MockProviderClient(provider: provider)
        }
        guard let client = clients[provider] else {
            throw ProviderError.invalidResponse
        }
        return client
    }
}
