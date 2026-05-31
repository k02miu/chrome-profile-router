import SwiftUI

@main
struct ChromeProfileRouterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "person.crop.circle")
                Text(appState.menuBarTitle)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}
