import Foundation

struct AppSettings: Codable, Equatable {
    var defaultProfileDirectory: String?
    var aliases: [String: String]

    static let empty = AppSettings(defaultProfileDirectory: nil, aliases: [:])
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
