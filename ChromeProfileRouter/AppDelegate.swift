import AppKit
import Carbon
import Darwin

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard !handleCommandLineOptions() else {
            return
        }

        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        NSAppleEventManager.shared().removeEventHandler(
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    @objc
    private func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard
            let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let url = URL(string: urlString)
        else {
            return
        }

        NotificationCenter.default.post(name: .routerReceivedURL, object: url)
    }

    private func handleCommandLineOptions() -> Bool {
        let arguments = Set(CommandLine.arguments.dropFirst())

        if arguments.contains("--enable-launch-at-login") {
            runLaunchAtLoginCommand(enabled: true)
            return true
        }

        if arguments.contains("--disable-launch-at-login") {
            runLaunchAtLoginCommand(enabled: false)
            return true
        }

        if arguments.contains("--print-launch-at-login-status") {
            print(LoginItemManager().status().label)
            fflush(stdout)
            exit(EXIT_SUCCESS)
        }

        return false
    }

    private func runLaunchAtLoginCommand(enabled: Bool) {
        do {
            let manager = LoginItemManager()
            try manager.setLaunchAtLogin(enabled)
            print("Launch at login: \(manager.status().label)")
            fflush(stdout)
            exit(EXIT_SUCCESS)
        } catch {
            fputs("Launch at login failed: \(error.localizedDescription)\n", stderr)
            fflush(stderr)
            exit(EXIT_FAILURE)
        }
    }
}
