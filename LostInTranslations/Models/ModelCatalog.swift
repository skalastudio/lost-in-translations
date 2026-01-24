import Foundation

struct ModelCatalog {
    static let advancedModels: [Provider: [String]] = ModelCatalogConstants.advancedModels

    static func defaultModel(for provider: Provider, tier: ModelTier) -> String {
        if provider == .auto {
            return ModelCatalogConstants.autoModelPlaceholder
        }
        return ModelCatalogConstants.defaultModels[provider]?[tier] ?? ModelCatalogConstants.autoModelPlaceholder
    }
}
