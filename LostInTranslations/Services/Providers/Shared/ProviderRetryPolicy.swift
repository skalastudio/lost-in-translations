import Foundation

/// Retry policy for provider network requests.
enum ProviderRetryPolicy {
    /// Maximum retry attempts.
    static let maxAttempts = 2
    /// Base delay in seconds before retrying.
    static let baseDelaySeconds: Double = 0.4

    /// Returns the delay duration for a given attempt.
    /// - Parameter attempt: The current attempt number.
    /// - Returns: Delay duration in nanoseconds.
    static func delay(forAttempt attempt: Int) -> UInt64 {
        let multiplier = pow(2.0, Double(max(0, attempt - 1)))
        let seconds = baseDelaySeconds * multiplier
        return UInt64(seconds * 1_000_000_000)
    }
}
