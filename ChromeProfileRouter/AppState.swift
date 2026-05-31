import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var profiles: [ChromeProfile] = []
    @Published private(set) var lastOpenedURL: URL?
    @Published private(set) var lastError: String?
    @Published private(set) var launchAtLoginStatus: LoginItemManager.LoginItemStatus = .unknown
    @Published var defaultProfileDirectory: String?
    @Published var aliases: [String: String]

    private let scanner: ChromeProfileScanner
    private let launcher: ChromeLauncher
    private let loginItemManager: LoginItemManager
    private let settingsStore: SettingsStore
    private var urlObserver: NotificationToken?

    init(
        scanner: ChromeProfileScanner = ChromeProfileScanner(),
        launcher: ChromeLauncher = ChromeLauncher(),
        loginItemManager: LoginItemManager = LoginItemManager(),
        settingsStore: SettingsStore = SettingsStore()
    ) {
        self.scanner = scanner
        self.launcher = launcher
        self.loginItemManager = loginItemManager
        self.settingsStore = settingsStore

        let settings = settingsStore.load()
        self.defaultProfileDirectory = settings.defaultProfileDirectory
        self.aliases = settings.aliases

        refreshProfiles()
        refreshLaunchAtLoginStatus()

        urlObserver = NotificationToken(
            NotificationCenter.default.addObserver(
                forName: .routerReceivedURL,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let url = notification.object as? URL else {
                    return
                }

                Task { @MainActor in
                    self?.openIncomingURL(url)
                }
            }
        )
    }

    deinit {
        urlObserver?.invalidate()
    }

    var menuBarTitle: String {
        guard let defaultProfile = defaultProfile else {
            return "プロファイル未選択"
        }

        return displayName(for: defaultProfile)
    }

    var currentProfileSummary: String {
        guard let defaultProfile else {
            return "現在: プロファイル未選択"
        }

        return "現在: \(displayName(for: defaultProfile))"
    }

    var defaultProfile: ChromeProfile? {
        guard let defaultProfileDirectory else {
            return nil
        }

        return profiles.first { $0.directoryName == defaultProfileDirectory }
    }

    var isRegisteredAsDefaultBrowser: Bool {
        DefaultBrowserRegistrar.isCurrentAppDefault()
    }

    var isLaunchAtLoginEnabled: Bool {
        launchAtLoginStatus.isEnabled
    }

    var launchAtLoginDescription: String {
        launchAtLoginStatus.description
    }

    func refreshProfiles() {
        do {
            profiles = try scanner.scan()
            lastError = nil
            normalizeDefaultProfile()
        } catch {
            profiles = []
            lastError = error.localizedDescription
        }
    }

    func displayName(for profile: ChromeProfile) -> String {
        if let alias = alias(for: profile) {
            return alias
        }

        return profile.chromeName
    }

    func alias(for profile: ChromeProfile) -> String? {
        aliases[profile.directoryName]?.nilIfBlank
    }

    func hasCustomAlias(for profile: ChromeProfile) -> Bool {
        alias(for: profile) != nil
    }

    func setAlias(_ alias: String, for profile: ChromeProfile) {
        let trimmed = alias.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            aliases.removeValue(forKey: profile.directoryName)
        } else {
            aliases[profile.directoryName] = trimmed
        }

        saveSettings()
    }

    func resetAlias(for profile: ChromeProfile) {
        aliases.removeValue(forKey: profile.directoryName)
        saveSettings()
    }

    func setDefaultProfile(_ profile: ChromeProfile) {
        defaultProfileDirectory = profile.directoryName
        saveSettings()
    }

    func registerAsDefaultBrowser() {
        do {
            try DefaultBrowserRegistrar.registerCurrentApp()
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func refreshLaunchAtLoginStatus() {
        launchAtLoginStatus = loginItemManager.status()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            try loginItemManager.setLaunchAtLogin(enabled)
            refreshLaunchAtLoginStatus()
            lastError = nil
        } catch {
            refreshLaunchAtLoginStatus()
            lastError = error.localizedDescription
        }
    }

    func openIncomingURL(_ url: URL) {
        guard let profile = defaultProfile else {
            lastError = "リンクを開く前に、デフォルトの Chrome プロファイルを選択してください。"
            return
        }

        do {
            try launcher.open(url, profileDirectory: profile.directoryName)
            lastOpenedURL = url
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    private func normalizeDefaultProfile() {
        if let current = defaultProfileDirectory, profiles.contains(where: { $0.directoryName == current }) {
            return
        }

        defaultProfileDirectory = profiles.first(where: { $0.directoryName == "Default" })?.directoryName
            ?? profiles.first?.directoryName
        saveSettings()
    }

    private func saveSettings() {
        settingsStore.save(
            AppSettings(
                defaultProfileDirectory: defaultProfileDirectory,
                aliases: aliases
            )
        )
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private final class NotificationToken: @unchecked Sendable {
    private var observer: NSObjectProtocol?

    init(_ observer: NSObjectProtocol) {
        self.observer = observer
    }

    func invalidate() {
        guard let observer else {
            return
        }

        NotificationCenter.default.removeObserver(observer)
        self.observer = nil
    }

    deinit {
        invalidate()
    }
}
