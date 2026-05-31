import Foundation

struct ChromeProfile: Identifiable, Codable, Hashable {
    var id: String { directoryName }

    let directoryName: String
    let chromeName: String
    let gaiaName: String?
    let userName: String?

    var accountDescription: String {
        if let userName, !userName.isEmpty {
            return userName
        }

        if let gaiaName, !gaiaName.isEmpty {
            return gaiaName
        }

        return "アカウント情報なし"
    }
}
