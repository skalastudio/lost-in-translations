import Foundation

protocol ProviderClient: Sendable {
    var provider: Provider { get }
    func run(spec: TaskSpec, apiKey: String) async throws -> ProviderResult
}

struct ProviderResult: Sendable {
    let results: [OutputResult]
    let model: String
}

enum ProviderRequestHelper {
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
