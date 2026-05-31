import AppKit
import Foundation

struct ChromeLauncher {
    enum LaunchError: LocalizedError {
        case chromeNotFound
        case chromeExecutableNotFound(URL)

        var errorDescription: String? {
            switch self {
            case .chromeNotFound:
                return "Google Chrome.app が見つかりません。"
            case .chromeExecutableNotFound(let appURL):
                return "\(appURL.path) 内に Chrome の実行ファイルが見つかりません。"
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

        let executableURL = chromeAppURL
            .appendingPathComponent("Contents", isDirectory: true)
            .appendingPathComponent("MacOS", isDirectory: true)
            .appendingPathComponent("Google Chrome", isDirectory: false)

        guard fileManager.isExecutableFile(atPath: executableURL.path) else {
            throw LaunchError.chromeExecutableNotFound(chromeAppURL)
        }

        let process = Process()
        process.executableURL = executableURL
        process.arguments = [
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
