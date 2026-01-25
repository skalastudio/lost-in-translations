import Foundation

/// Provider client interface for executing tasks.
protocol ProviderClient: Sendable {
    /// Provider identifier.
    var provider: Provider { get }
    /// Executes a task for the provider.
    /// - Parameters:
    ///   - spec: The task specification.
    ///   - apiKey: API key for the provider.
    /// - Returns: Parsed provider result.
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult
}

/// Provider response result payload.
struct ProviderResult: Sendable {
    /// Output results from the provider.
    let results: [OutputResult]
    /// Model identifier returned by the provider.
    let model: String
}

/// Helper for performing provider requests with retry policy.
enum ProviderRequestHelper {
    /// Performs a URL request with retry for transient network errors.
    /// - Parameter request: The URL request to execute.
    /// - Returns: Data and URL response.
    static func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        var attempt = 1
        while true {
            do {
                return try await URLSession.shared.data(for: request)
            } catch {
                guard attempt < ProviderRetryPolicy.maxAttempts else {
                    throw error
                }
                if error is URLError {
                    let delay = ProviderRetryPolicy.delay(forAttempt: attempt)
                    try? await Task.sleep(nanoseconds: delay)
                    attempt += 1
                    continue
                }
                throw error
            }
        }
    }
}
