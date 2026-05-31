import AppKit
import CoreServices
import Foundation

struct DefaultBrowserRegistrar {
    enum RegistrarError: LocalizedError {
        case missingBundleIdentifier
        case registrationFailed(scheme: String, status: OSStatus)

        var errorDescription: String? {
            switch self {
            case .missingBundleIdentifier:
                return "このアプリに bundle identifier が設定されていません。"
            case .registrationFailed(let scheme, let status):
                return "\(scheme) ハンドラの登録に失敗しました。OSStatus: \(status)"
            }
        }
    }

    static let schemes = ["http", "https"]

    static func registerCurrentApp() throws {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier, !bundleIdentifier.isEmpty else {
            throw RegistrarError.missingBundleIdentifier
        }

        for scheme in schemes {
            let status = LSSetDefaultHandlerForURLScheme(scheme as CFString, bundleIdentifier as CFString)
            guard status == noErr else {
                throw RegistrarError.registrationFailed(scheme: scheme, status: status)
            }
        }
    }

    static func isCurrentAppDefault() -> Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return false
        }

        return schemes.allSatisfy { scheme in
            currentHandler(for: scheme) == bundleIdentifier
        }
    }

    static func currentHandler(for scheme: String) -> String? {
        guard
            let url = URL(string: "\(scheme)://example.com"),
            let appURL = NSWorkspace.shared.urlForApplication(toOpen: url)
        else {
            return nil
        }

        return Bundle(url: appURL)?.bundleIdentifier
    }
}
