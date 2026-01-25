import Foundation

/// App-wide constant values.
enum AppConstants {
    /// Launch argument identifiers.
    enum LaunchArguments {
        /// Enables the mock provider in debug builds.
        static let useMockProvider = "UseMockProvider"
    }

    /// OSLog configuration values.
    enum Logging {
        /// Logger subsystem identifier.
        static let subsystem = "com.lostintranslations.app"
        /// Category used for mock provider logs.
        static let mockProviderCategory = "MockProvider"
    }
}
