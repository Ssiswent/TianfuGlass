import Foundation
import Security

/// The cookie remains on-device in Keychain. Never put credentials in
/// AppShortcut parameters, source control, UserDefaults, or diagnostics.
enum TransitCookieStore {
    private static let service = "com.ssiswent.TianfuGlass.transit"
    private static let account = "code-api-cookie"

    enum StoreError: LocalizedError {
        case missing, invalidFormat, keychainFailure

        var errorDescription: String? {
            switch self {
            case .missing:
                "请先打开天府通 Glass，在「登录会话」里保存 Cookie。"
            case .invalidFormat:
                "Cookie 格式有误：请输入包含 TGT 的完整 Cookie 字符串，不要包含换行。"
            case .keychainFailure:
                "无法访问设备钥匙串。请解锁 iPhone 后重试。"
            }
        }
    }

    static func validate(_ value: String) throws -> String {
        let cookie = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cookie.isEmpty,
              cookie.utf8.count <= 8192,
              !cookie.contains("\r"),
              !cookie.contains("\n"),
              !cookie.lowercased().hasPrefix("cookie:") else {
            throw StoreError.invalidFormat
        }
        let fields = cookie.split(separator: ";").map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        guard fields.contains(where: { field in
            let parts = field.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            return parts.count == 2 && parts[0] == "TGT" && !parts[1].isEmpty
        }) else {
            throw StoreError.invalidFormat
        }
        return cookie
    }

    private static var query: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    static func save(_ rawValue: String) throws {
        let cookie = try validate(rawValue)
        guard let data = cookie.data(using: .utf8) else {
            throw StoreError.invalidFormat
        }
        let status = SecItemUpdate(
            query as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )
        if status == errSecSuccess { return }
        guard status == errSecItemNotFound else { throw StoreError.keychainFailure }

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        guard SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess else {
            throw StoreError.keychainFailure
        }
    }

    static func load() throws -> String {
        var attributes = query
        attributes[kSecReturnData as String] = true
        attributes[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(attributes as CFDictionary, &result)
        if status == errSecItemNotFound { throw StoreError.missing }
        guard status == errSecSuccess,
              let data = result as? Data,
              let cookie = String(data: data, encoding: .utf8) else {
            throw StoreError.keychainFailure
        }
        return try validate(cookie)
    }

    static func hasCookie() -> Bool {
        (try? load()) != nil
    }

    static func clear() throws {
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw StoreError.keychainFailure
        }
    }
}
