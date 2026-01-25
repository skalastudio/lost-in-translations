import Foundation

/// Convenience accessors for model catalog data.
struct ModelCatalog {
    /// Provider-specific advanced model identifiers.
    static let advancedModels: [Provider: [String]] = ModelCatalogConstants.advancedModels

    /// Returns the default model identifier for a provider and tier.
    /// - Parameters:
    ///   - provider: The provider selection.
    ///   - tier: The requested tier.
    /// - Returns: A model identifier string.
    static func defaultModel(for provider: Provider, tier: ModelTier) -> String {
        if provider == .auto {
            return ModelCatalogConstants.autoModelPlaceholder
        }
        return ModelCatalogConstants.defaultModels[provider]?[tier] ?? ModelCatalogConstants.autoModelPlaceholder
    }
}
