import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var testURLString = "https://example.com"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            if let lastError = appState.lastError {
                Text(lastError)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
            }

            HStack(alignment: .top, spacing: 24) {
                profilesSection
                routingSection
            }
        }
        .padding(24)
        .frame(minWidth: 760, minHeight: 520)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Chrome Profile Router")
                .font(.largeTitle.bold())
            Text("Route links to the selected Google Chrome profile.")
                .foregroundStyle(.secondary)
        }
    }

    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Profiles")
                    .font(.title2.bold())
                Spacer()
                Button("Refresh") {
                    appState.refreshProfiles()
                }
            }

            if appState.profiles.isEmpty {
                ContentUnavailableView(
                    "No Profiles",
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text("Open Chrome and create at least one profile.")
                )
            } else {
                List(appState.profiles) { profile in
                    profileRow(profile)
                }
                .listStyle(.inset)
            }
        }
        .frame(minWidth: 430)
    }

    private var routingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Routing")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Default Profile")
                    .font(.headline)

                Picker("Default Profile", selection: defaultProfileBinding) {
                    ForEach(appState.profiles) { profile in
                        Text(appState.displayName(for: profile))
                            .tag(profile.directoryName)
                    }
                }
                .labelsHidden()
                .disabled(appState.profiles.isEmpty)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("macOS Default Browser")
                    .font(.headline)
                Text(defaultBrowserDescription)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(appState.isRegisteredAsDefaultBrowser ? "Register Again" : "Set as Default Browser") {
                    appState.registerAsDefaultBrowser()
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Toggle("Launch at Login", isOn: launchAtLoginBinding)
                    .toggleStyle(.switch)
                Text(appState.launchAtLoginDescription)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Test Open")
                    .font(.headline)
                TextField("URL", text: $testURLString)
                    .textFieldStyle(.roundedBorder)
                Button("Open with Default Profile") {
                    if let url = URL(string: testURLString) {
                        appState.openIncomingURL(url)
                    }
                }
                .disabled(URL(string: testURLString) == nil || appState.defaultProfile == nil)
            }

            if let lastOpenedURL = appState.lastOpenedURL {
                Text("Last opened: \(lastOpenedURL.absoluteString)")
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .frame(minWidth: 260, maxWidth: 320)
    }

    private func profileRow(_ profile: ChromeProfile) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(appState.displayName(for: profile))
                        .font(.headline)
                    Text(profileSubtitle(for: profile))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if appState.defaultProfileDirectory == profile.directoryName {
                    Label("Default", systemImage: "checkmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.green)
                }
            }

            Text(profile.accountDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("Alias")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    TextField("Work, Personal, Client A...", text: aliasBinding(for: profile))
                        .textFieldStyle(.roundedBorder)

                    Button("Clear") {
                        appState.resetAlias(for: profile)
                    }
                    .disabled(!appState.hasCustomAlias(for: profile))
                }
            }

            HStack(spacing: 8) {
                Text("Chrome: \(profile.chromeName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text("Folder: \(profile.directoryName)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                Button("Make Default") {
                    appState.setDefaultProfile(profile)
                }
                .disabled(appState.defaultProfileDirectory == profile.directoryName)
            }
        }
        .padding(.vertical, 8)
    }

    private func profileSubtitle(for profile: ChromeProfile) -> String {
        if appState.hasCustomAlias(for: profile) {
            return "Alias for \(profile.chromeName)"
        }

        return "Using Chrome profile name"
    }

    private var defaultProfileBinding: Binding<String> {
        Binding(
            get: { appState.defaultProfileDirectory ?? "" },
            set: { newValue in
                guard let profile = appState.profiles.first(where: { $0.directoryName == newValue }) else {
                    return
                }
                appState.setDefaultProfile(profile)
            }
        )
    }

    private func aliasBinding(for profile: ChromeProfile) -> Binding<String> {
        Binding(
            get: { appState.aliases[profile.directoryName] ?? "" },
            set: { appState.setAlias($0, for: profile) }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { appState.isLaunchAtLoginEnabled },
            set: { appState.setLaunchAtLogin($0) }
        )
    }

    private var defaultBrowserDescription: String {
        if appState.isRegisteredAsDefaultBrowser {
            return "This app is registered for http and https links."
        }

        return "Register this app as the http and https handler, then macOS will send clicked links here first."
    }
}
