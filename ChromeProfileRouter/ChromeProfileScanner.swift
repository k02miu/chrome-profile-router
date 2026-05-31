import Foundation

struct ChromeProfileScanner {
    private struct LocalState: Decodable {
        let profile: ProfileState?
    }

    private struct ProfileState: Decodable {
        let infoCache: [String: ProfileInfo]?

        enum CodingKeys: String, CodingKey {
            case infoCache = "info_cache"
        }
    }

    private struct ProfileInfo: Decodable {
        let name: String?
        let gaiaName: String?
        let userName: String?

        enum CodingKeys: String, CodingKey {
            case name
            case gaiaName = "gaia_name"
            case userName = "user_name"
        }
    }

    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func scan() throws -> [ChromeProfile] {
        let chromeRoot = chromeProfileRoot
        let infoCache = try readInfoCache(from: chromeRoot)
        var directoryNames = Set(
            infoCache.keys.filter { directoryExists($0, in: chromeRoot) }
        )

        if let children = try? fileManager.contentsOfDirectory(
            at: chromeRoot,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) {
            for child in children where isProfileDirectory(child) {
                directoryNames.insert(child.lastPathComponent)
            }
        }

        return directoryNames
            .sorted(by: profileSort)
            .map { directoryName in
                let info = infoCache[directoryName]
                return ChromeProfile(
                    directoryName: directoryName,
                    chromeName: info?.name?.nilIfBlank ?? directoryName,
                    gaiaName: info?.gaiaName?.nilIfBlank,
                    userName: info?.userName?.nilIfBlank
                )
            }
    }

    var chromeProfileRoot: URL {
        fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
            .appendingPathComponent("Google", isDirectory: true)
            .appendingPathComponent("Chrome", isDirectory: true)
    }

    private func readInfoCache(from chromeRoot: URL) throws -> [String: ProfileInfo] {
        let localStateURL = chromeRoot.appendingPathComponent("Local State", isDirectory: false)

        guard fileManager.fileExists(atPath: localStateURL.path) else {
            return [:]
        }

        let data = try Data(contentsOf: localStateURL)
        let localState = try JSONDecoder().decode(LocalState.self, from: data)
        return localState.profile?.infoCache ?? [:]
    }

    private func isProfileDirectory(_ url: URL) -> Bool {
        guard
            let resourceValues = try? url.resourceValues(forKeys: [.isDirectoryKey]),
            resourceValues.isDirectory == true
        else {
            return false
        }

        let name = url.lastPathComponent
        return name == "Default" || name.hasPrefix("Profile ")
    }

    private func directoryExists(_ directoryName: String, in chromeRoot: URL) -> Bool {
        var isDirectory: ObjCBool = false
        let url = chromeRoot.appendingPathComponent(directoryName, isDirectory: true)
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func profileSort(_ lhs: String, _ rhs: String) -> Bool {
        if lhs == "Default" {
            return true
        }

        if rhs == "Default" {
            return false
        }

        return lhs.localizedStandardCompare(rhs) == .orderedAscending
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
