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
                return "On"
            case .notRegistered:
                return "Off"
            case .requiresApproval:
                return "Needs Approval"
            case .notFound:
                return "Not Available"
            case .unknown:
                return "Unknown"
            }
        }

        var description: String {
            switch self {
            case .enabled:
                return "This app will open automatically when you log in."
            case .notRegistered:
                return "This app is not set to open at login."
            case .requiresApproval:
                return "macOS needs approval in System Settings before this app can open at login."
            case .notFound:
                return "Install the app in Applications before enabling launch at login."
            case .unknown:
                return "macOS returned an unknown launch-at-login status."
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
