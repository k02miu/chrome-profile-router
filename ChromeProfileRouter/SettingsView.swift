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
            Text("選択した Google Chrome プロファイルでリンクを開きます。")
                .foregroundStyle(.secondary)
        }
    }

    private var profilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("プロファイル")
                    .font(.title2.bold())
                Spacer()
                Button("再読み込み") {
                    appState.refreshProfiles()
                }
            }

            if appState.profiles.isEmpty {
                ContentUnavailableView(
                    "プロファイルがありません",
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text("Chrome で少なくとも 1 つのプロファイルを作成してください。")
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
            Text("ルーティング")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("デフォルトプロファイル")
                    .font(.headline)

                Picker("デフォルトプロファイル", selection: defaultProfileBinding) {
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
                Text("macOS のデフォルトブラウザ")
                    .font(.headline)
                Text(defaultBrowserDescription)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(appState.isRegisteredAsDefaultBrowser ? "再登録" : "デフォルトブラウザに設定") {
                    appState.registerAsDefaultBrowser()
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Toggle("ログイン時に起動", isOn: launchAtLoginBinding)
                    .toggleStyle(.switch)
                Text(appState.launchAtLoginDescription)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("動作確認")
                    .font(.headline)
                TextField("URL", text: $testURLString)
                    .textFieldStyle(.roundedBorder)
                Button("デフォルトプロファイルで開く") {
                    if let url = URL(string: testURLString) {
                        appState.openIncomingURL(url)
                    }
                }
                .disabled(URL(string: testURLString) == nil || appState.defaultProfile == nil)
            }

            if let lastOpenedURL = appState.lastOpenedURL {
                Text("最後に開いた URL: \(lastOpenedURL.absoluteString)")
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
                    Label("デフォルト", systemImage: "checkmark.circle.fill")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.green)
                }
            }

            Text(profile.accountDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text("エイリアス")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    TextField("仕事用、個人用、案件A...", text: aliasBinding(for: profile))
                        .textFieldStyle(.roundedBorder)

                    Button("クリア") {
                        appState.resetAlias(for: profile)
                    }
                    .disabled(!appState.hasCustomAlias(for: profile))
                }
            }

            HStack(spacing: 8) {
                Text("Chrome 名: \(profile.chromeName)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Text("フォルダ: \(profile.directoryName)")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                Button("デフォルトにする") {
                    appState.setDefaultProfile(profile)
                }
                .disabled(appState.defaultProfileDirectory == profile.directoryName)
            }
        }
        .padding(.vertical, 8)
    }

    private func profileSubtitle(for profile: ChromeProfile) -> String {
        if appState.hasCustomAlias(for: profile) {
            return "\(profile.chromeName) のエイリアス"
        }

        return "Chrome のプロファイル名を使用中"
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
            return "このアプリは http / https リンクのハンドラとして登録されています。"
        }

        return "このアプリを http / https ハンドラとして登録すると、クリックしたリンクが最初にこのアプリへ送られます。"
    }
}
