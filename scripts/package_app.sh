#!/bin/sh
set -eu

PROJECT="ChromeProfileRouter.xcodeproj"
SCHEME="ChromeProfileRouter"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-./DerivedData}"
PRODUCTS_DIR="$DERIVED_DATA_PATH/Build/Products/$CONFIGURATION"
APP_PATH="$PRODUCTS_DIR/ChromeProfileRouter.app"
DIST_DIR="${DIST_DIR:-./dist}"
ZIP_PATH="$DIST_DIR/ChromeProfileRouter.zip"
DMG_PATH="$DIST_DIR/ChromeProfileRouter.dmg"
DMG_STAGING_PATH="$DIST_DIR/dmg-staging"
SKIP_BUILD="${SKIP_BUILD:-0}"

if [ "$SKIP_BUILD" != "1" ]; then
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    CODE_SIGNING_ALLOWED=NO \
    build
fi

if [ ! -d "$APP_PATH" ]; then
  echo "App was not found at $APP_PATH" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"
codesign --force --deep --sign - "$APP_PATH"

ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

rm -rf "$DMG_STAGING_PATH"
mkdir -p "$DMG_STAGING_PATH"
ditto "$APP_PATH" "$DMG_STAGING_PATH/ChromeProfileRouter.app"
ln -s /Applications "$DMG_STAGING_PATH/Applications"
hdiutil create \
  -volname "Chrome Profile Router" \
  -srcfolder "$DMG_STAGING_PATH" \
  -ov \
  -format UDZO \
  "$DMG_PATH"
rm -rf "$DMG_STAGING_PATH"

echo "$ZIP_PATH"
echo "$DMG_PATH"
