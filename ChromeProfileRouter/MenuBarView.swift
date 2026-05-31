import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack {
            Text(appState.currentProfileSummary)
                .font(.headline)

            if let defaultProfile = appState.defaultProfile {
                Text(defaultProfile.directoryName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            if appState.profiles.isEmpty {
                Text("No Chrome profiles found")
            } else {
                Section("Default Profile") {
                    ForEach(appState.profiles) { profile in
                        Button {
                            appState.setDefaultProfile(profile)
                        } label: {
                            HStack {
                                if appState.defaultProfileDirectory == profile.directoryName {
                                    Image(systemName: "checkmark")
                                }
                                Text(appState.displayName(for: profile))
                            }
                        }
                    }
                }
            }

            Divider()

            Button("Refresh Profiles") {
                appState.refreshProfiles()
            }

            Button(appState.isRegisteredAsDefaultBrowser ? "Default Browser Registered" : "Set as Default Browser") {
                appState.registerAsDefaultBrowser()
            }

            Button("Launch at Login: \(appState.launchAtLoginStatus.label)") {
                appState.setLaunchAtLogin(!appState.isLaunchAtLoginEnabled)
            }

            Button("Settings...") {
                openSettings()
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
