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
        .defaultSize(width: 980, height: 720)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Label {
                Text(appState.menuBarTitle)
            } icon: {
                Image(systemName: "person.crop.circle")
            }
        }
    }
}
