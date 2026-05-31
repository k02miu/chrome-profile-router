# Chrome Profile Router

Chrome Profile Router is a small macOS menu bar app that opens clicked links with a selected Google Chrome profile.

It is intended for people who use multiple Chrome profiles and want a quick way to switch the default profile used for links.

## Features

- Scans local Google Chrome profiles.
- Reads Chrome profile display names from `Local State`.
- Lets you assign simpler aliases to profile folders.
- Switches the default profile from the menu bar.
- Registers as the macOS `http` and `https` handler.
- Opens links with `Google Chrome --profile-directory=<folder>`.
- Can launch automatically at login.

## Requirements

- macOS 14 or later
- Google Chrome
- Xcode 16 or later for local builds

## Build

```sh
xcodebuild \
  -project ChromeProfileRouter.xcodeproj \
  -scheme ChromeProfileRouter \
  -configuration Release \
  -derivedDataPath ./DerivedData \
  build
```

The app is built at:

```text
DerivedData/Build/Products/Release/ChromeProfileRouter.app
```

## Package

```sh
scripts/package_app.sh
```

The packaged app is written to `dist/ChromeProfileRouter.zip`.

## Notes

The app does not depend on Finicky. It owns URL receipt, profile selection, Chrome launching, and the menu bar UI directly.
