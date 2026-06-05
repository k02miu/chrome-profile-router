import SwiftUI

@main
struct ChromeProfileRouterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup("Chrome Profile Router", id: "main") {
            SettingsView()
                .environmentObject(appState)
        }
        .defaultSize(width: 760, height: 520)
        .windowResizability(.contentSize)

        MenuBarExtra(appState.menuBarTitle, systemImage: "person.crop.circle") {
            MenuBarView()
                .environmentObject(appState)
        }
    }
}
