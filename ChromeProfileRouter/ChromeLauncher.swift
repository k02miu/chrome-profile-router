import AppKit
import Foundation

enum ChromeLaunchMethod: String, CaseIterable, Codable, Identifiable {
    case directExecutable
    case openCommand

    var id: String { rawValue }

    var title: String {
        switch self {
        case .directExecutable:
            return "Chrome を直接起動"
        case .openCommand:
            return "macOS open コマンド"
        }
    }

    var description: String {
        switch self {
        case .directExecutable:
            return "Chrome の実行ファイルへ直接 --profile-directory を渡します。通常はこちらを使ってください。"
        case .openCommand:
            return "従来方式です。環境によっては最後に操作したプロファイルで開くことがあります。"
        }
    }
}

struct ChromeLauncher {
    enum LaunchError: LocalizedError {
        case chromeNotFound
        case chromeExecutableNotFound
        case openToolNotFound

        var errorDescription: String? {
            switch self {
            case .chromeNotFound:
                return "Google Chrome.app が見つかりません。"
            case .chromeExecutableNotFound:
                return "Google Chrome の実行ファイルが見つかりません。"
            case .openToolNotFound:
                return "macOS の open コマンドが見つかりません。"
            }
        }
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func open(
        _ url: URL,
        profileDirectory: String,
        launchMethod: ChromeLaunchMethod = .directExecutable
    ) throws {
        switch launchMethod {
        case .directExecutable:
            try openDirectly(url, profileDirectory: profileDirectory)
        case .openCommand:
            try openWithOpenCommand(url, profileDirectory: profileDirectory)
        }
    }

    private func openDirectly(_ url: URL, profileDirectory: String) throws {
        guard let chromeExecutableURL else {
            throw LaunchError.chromeExecutableNotFound
        }

        try run(
            executableURL: chromeExecutableURL,
            arguments: [
                "--profile-directory=\(profileDirectory)",
                url.absoluteString
            ]
        )
    }

    private func openWithOpenCommand(_ url: URL, profileDirectory: String) throws {
        guard chromeAppURL != nil else {
            throw LaunchError.chromeNotFound
        }

        let openToolURL = URL(fileURLWithPath: "/usr/bin/open", isDirectory: false)

        guard fileManager.isExecutableFile(atPath: openToolURL.path) else {
            throw LaunchError.openToolNotFound
        }

        // Existing Chrome instances can route URLs to the last active profile.
        // `open -n` gives Chrome a fresh argv so `--profile-directory` is honored.
        try run(
            executableURL: openToolURL,
            arguments: [
                "-n",
                "-b",
                "com.google.Chrome",
                "--args",
                "--profile-directory=\(profileDirectory)",
                url.absoluteString
            ]
        )
    }

    private func run(executableURL: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments
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

    private var chromeExecutableURL: URL? {
        guard let chromeAppURL else {
            return nil
        }

        if let bundle = Bundle(url: chromeAppURL),
           let executableURL = bundle.executableURL,
           fileManager.isExecutableFile(atPath: executableURL.path) {
            return executableURL
        }

        let fallbackURL = chromeAppURL
            .appendingPathComponent("Contents", isDirectory: true)
            .appendingPathComponent("MacOS", isDirectory: true)
            .appendingPathComponent("Google Chrome", isDirectory: false)

        return fileManager.isExecutableFile(atPath: fallbackURL.path) ? fallbackURL : nil
    }
}
