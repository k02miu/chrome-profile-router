import AppKit
import Foundation

struct ChromeLauncher {
    enum LaunchError: LocalizedError {
        case chromeNotFound
        case openToolNotFound

        var errorDescription: String? {
            switch self {
            case .chromeNotFound:
                return "Google Chrome.app が見つかりません。"
            case .openToolNotFound:
                return "macOS の open コマンドが見つかりません。"
            }
        }
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func open(_ url: URL, profileDirectory: String) throws {
        guard let chromeAppURL = chromeAppURL else {
            throw LaunchError.chromeNotFound
        }

        let openToolURL = URL(fileURLWithPath: "/usr/bin/open", isDirectory: false)

        guard fileManager.isExecutableFile(atPath: openToolURL.path) else {
            throw LaunchError.openToolNotFound
        }

        let process = Process()
        process.executableURL = openToolURL
        // Existing Chrome instances can route URLs to the last active profile.
        // `open -n` gives Chrome a fresh argv so `--profile-directory` is honored.
        process.arguments = [
            "-n",
            "-a",
            chromeAppURL.path,
            "--args",
            "--profile-directory=\(profileDirectory)",
            url.absoluteString
        ]

        try process.run()
    }

    private var chromeAppURL: URL? {
        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.google.Chrome") {
            return url
        }

        let applicationURLs = [
            URL(fileURLWithPath: "/Applications/Google Chrome.app", isDirectory: true),
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Applications", isDirectory: true)
                .appendingPathComponent("Google Chrome.app", isDirectory: true)
        ]

        return applicationURLs.first { fileManager.fileExists(atPath: $0.path) }
    }
}
