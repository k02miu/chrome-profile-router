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

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  build

mkdir -p "$DIST_DIR"
ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

echo "$ZIP_PATH"
