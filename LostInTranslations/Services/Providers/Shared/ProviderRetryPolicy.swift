import Foundation

enum ProviderRetryPolicy {
    static let maxAttempts = 2
    static let baseDelaySeconds: Double = 0.4

    static func delay(forAttempt attempt: Int) -> UInt64 {
        let multiplier = pow(2.0, Double(max(0, attempt - 1)))
        let seconds = baseDelaySeconds * multiplier
        return UInt64(seconds * 1_000_000_000)
    }
}
