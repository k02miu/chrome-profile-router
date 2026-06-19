import AppKit
import Foundation

struct DefaultBrowserRegistrar {
    enum RegistrarError: LocalizedError {
        case missingBundleIdentifier
        case registrationFailed(Error)

        var errorDescription: String? {
            switch self {
            case .missingBundleIdentifier:
                return "このアプリに bundle identifier が設定されていません。"
            case .registrationFailed(let error):
                return "デフォルトブラウザの登録に失敗しました: \(error.localizedDescription)"
            }
        }
    }

    private static let registrationScheme = "http"
    static let schemes = [registrationScheme, "https"]

    @MainActor
    static func registerCurrentApp() async throws {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier, !bundleIdentifier.isEmpty else {
            throw RegistrarError.missingBundleIdentifier
        }

        do {
            let _: Void = try await withCheckedThrowingContinuation { continuation in
                NSWorkspace.shared.setDefaultApplication(
                    at: Bundle.main.bundleURL,
                    toOpenURLsWithScheme: registrationScheme
                ) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        } catch {
            throw RegistrarError.registrationFailed(error)
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
