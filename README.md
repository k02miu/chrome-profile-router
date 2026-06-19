# Chrome Profile Router

Chrome Profile Router は、クリックしたリンクを選択中の Google Chrome プロファイルで開くための macOS メニューバーアプリです。

複数の Chrome プロファイルを使い分けていて、リンクを開くデフォルトのプロファイルをすぐ切り替えたい場合に使います。

## 機能

- ローカルの Google Chrome プロファイルを検出します。
- Chrome の `Local State` からプロファイル表示名を読み取ります。
- 分かりづらいプロファイルフォルダ名にエイリアスを付けられます。
- メニューバーからデフォルトプロファイルを切り替えられます。
- macOS の `http` / `https` ハンドラとして登録できます。
- デフォルトブラウザ登録には macOS の `NSWorkspace` API を使います。
- Chrome の実行ファイルへ `--profile-directory=<folder>` を直接渡して、選択したプロファイルでリンクを開きます。
- 環境差の確認用に、従来の macOS `open` コマンド方式へ切り替えられます。
- OS ログイン時に自動起動できます。

## 動作要件

- macOS 14 以降
- Google Chrome
- ローカルビルドには Xcode 16 以降

## インストール

Releases から `ChromeProfileRouter.dmg` をダウンロードして開き、`ChromeProfileRouter.app` を `Applications` にドラッグしてください。

初回起動時は設定ウィンドウが開きます。起動中は画面右上の通知ではなく、macOS のメニューバー上にプロファイル名付きで表示されます。

現時点の配布ビルドは Developer ID 署名と notarize を行っていません。macOS に「開発元を検証できません」と表示された場合は、Finder で右クリックして「開く」を選ぶか、システム設定のセキュリティから許可してください。

## プロファイル指定が効かない場合

Chrome や macOS のバージョンによって、`open` コマンド経由では最後に操作した Chrome プロファイルで開かれることがあります。

v0.1.4 以降は、既定で `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` を直接起動します。うまく動かない場合は、設定画面の「Chrome の起動方式」を切り替えてから「デフォルトプロファイルで開く」で確認してください。

## ビルド

```sh
xcodebuild \
  -project ChromeProfileRouter.xcodeproj \
  -scheme ChromeProfileRouter \
  -configuration Release \
  -derivedDataPath ./DerivedData \
  build
```

ビルドされたアプリは次の場所に出力されます。

```text
DerivedData/Build/Products/Release/ChromeProfileRouter.app
```

## パッケージ作成

```sh
scripts/package_app.sh
```

配布用 zip と DMG は `dist/` に作成されます。
