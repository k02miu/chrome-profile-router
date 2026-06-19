import Foundation

struct AppSettings: Codable, Equatable {
    var defaultProfileDirectory: String?
    var aliases: [String: String]
    var launchMethod: ChromeLaunchMethod

    static let empty = AppSettings(
        defaultProfileDirectory: nil,
        aliases: [:],
        launchMethod: .directExecutable
    )

    init(
        defaultProfileDirectory: String?,
        aliases: [String: String],
        launchMethod: ChromeLaunchMethod = .directExecutable
    ) {
        self.defaultProfileDirectory = defaultProfileDirectory
        self.aliases = aliases
        self.launchMethod = launchMethod
    }

    private enum CodingKeys: String, CodingKey {
        case defaultProfileDirectory
        case aliases
        case launchMethod
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultProfileDirectory = try container.decodeIfPresent(
            String.self,
            forKey: .defaultProfileDirectory
        )
        aliases = try container.decodeIfPresent([String: String].self, forKey: .aliases) ?? [:]
        launchMethod = try container.decodeIfPresent(
            ChromeLaunchMethod.self,
            forKey: .launchMethod
        ) ?? .directExecutable
    }
}

struct SettingsStore {
    private let defaults: UserDefaults
    private let key = "AppSettings.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> AppSettings {
        guard let data = defaults.data(forKey: key) else {
            return .empty
        }

        do {
            return try JSONDecoder().decode(AppSettings.self, from: data)
        } catch {
            return .empty
        }
    }

    func save(_ settings: AppSettings) {
        guard let data = try? JSONEncoder().encode(settings) else {
            return
        }

        defaults.set(data, forKey: key)
    }
}
