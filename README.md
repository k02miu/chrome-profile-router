# Chrome Profile Router

Chrome Profile Router は、クリックしたリンクを選択中の Google Chrome プロファイルで開くための macOS メニューバーアプリです。

複数の Chrome プロファイルを使い分けていて、リンクを開くデフォルトのプロファイルをすぐ切り替えたい場合に使います。

## 機能

- ローカルの Google Chrome プロファイルを検出します。
- Chrome の `Local State` からプロファイル表示名を読み取ります。
- 分かりづらいプロファイルフォルダ名にエイリアスを付けられます。
- メニューバーからデフォルトプロファイルを切り替えられます。
- macOS の `http` / `https` ハンドラとして登録できます。
- `Google Chrome --profile-directory=<folder>` を使ってリンクを開きます。
- OS ログイン時に自動起動できます。

## 動作要件

- macOS 14 以降
- Google Chrome
- ローカルビルドには Xcode 16 以降

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

配布用 zip は `dist/ChromeProfileRouter.zip` に作成されます。

