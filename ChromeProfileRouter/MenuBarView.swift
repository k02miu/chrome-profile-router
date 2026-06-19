import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openWindow) private var openWindow

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
                Text("Chrome のプロファイルが見つかりません")
            } else {
                Section("デフォルトプロファイル") {
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

            Button("プロファイルを再読み込み") {
                appState.refreshProfiles()
            }

            Button(defaultBrowserButtonTitle) {
                appState.registerAsDefaultBrowser()
            }
            .disabled(appState.isRegisteringDefaultBrowser)

            Button("ログイン時に起動: \(appState.launchAtLoginStatus.label)") {
                appState.setLaunchAtLogin(!appState.isLaunchAtLoginEnabled)
            }

            Button("設定...") {
                openWindow(id: "main")
            }

            Divider()

            Button("終了") {
                NSApp.terminate(nil)
            }
        }
    }

    private var defaultBrowserButtonTitle: String {
        if appState.isRegisteringDefaultBrowser {
            return "デフォルトブラウザ登録中..."
        }

        return appState.isRegisteredAsDefaultBrowser ? "デフォルトブラウザ登録済み" : "デフォルトブラウザに設定"
    }
}
