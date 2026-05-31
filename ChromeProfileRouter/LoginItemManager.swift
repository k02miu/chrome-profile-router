import Foundation
import ServiceManagement

struct LoginItemManager {
    enum LoginItemStatus: Equatable {
        case enabled
        case notRegistered
        case requiresApproval
        case notFound
        case unknown

        var isEnabled: Bool {
            self == .enabled
        }

        var label: String {
            switch self {
            case .enabled:
                return "有効"
            case .notRegistered:
                return "無効"
            case .requiresApproval:
                return "承認が必要"
            case .notFound:
                return "利用不可"
            case .unknown:
                return "不明"
            }
        }

        var description: String {
            switch self {
            case .enabled:
                return "ログイン時にこのアプリを自動で起動します。"
            case .notRegistered:
                return "ログイン時にこのアプリは起動しません。"
            case .requiresApproval:
                return "ログイン時に起動するには、macOS のシステム設定で承認が必要です。"
            case .notFound:
                return "ログイン時の起動を有効にする前に、アプリを Applications にインストールしてください。"
            case .unknown:
                return "macOS から不明なログイン項目ステータスが返されました。"
            }
        }
    }

    func status() -> LoginItemStatus {
        switch SMAppService.mainApp.status {
        case .enabled:
            return .enabled
        case .notRegistered:
            return .notRegistered
        case .requiresApproval:
            return .requiresApproval
        case .notFound:
            return .notFound
        @unknown default:
            return .unknown
        }
    }

    func setLaunchAtLogin(_ enabled: Bool) throws {
        let service = SMAppService.mainApp

        if enabled {
            guard service.status != .enabled else {
                return
            }
            try service.register()
        } else {
            guard service.status != .notRegistered else {
                return
            }
            try service.unregister()
        }
    }
}
