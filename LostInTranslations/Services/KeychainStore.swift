import Foundation
import Security

/// Keychain helper for storing provider API keys.
struct KeychainStore {
    /// Keychain service name.
    private static let service = "LostInTranslations"

    /// Saves an API key for a provider.
    /// - Parameters:
    ///   - key: API key string.
    ///   - provider: Provider to associate with the key.
    static func saveKey(_ key: String, for provider: Provider) throws {
        let data = Data(key.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.id,
            kSecValueData: data,
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw ProviderError.serviceError(
                String(format: String(localized: "error.keychain.save"), provider.localizedName)
            )
        }
    }

    /// Reads the API key for a provider.
    /// - Parameter provider: Provider to read.
    /// - Returns: Key string if present.
    static func readKey(for provider: Provider) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.id,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Deletes the API key for a provider.
    /// - Parameter provider: Provider to delete.
    static func deleteKey(for provider: Provider) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: provider.id,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw ProviderError.serviceError(
                String(format: String(localized: "error.keychain.delete"), provider.localizedName)
            )
        }
    }
}
