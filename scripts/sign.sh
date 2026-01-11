#!/bin/bash
set -e

echo "🔏 Signing Application..."

BUNDLE_PATH="ProxmoxBar.app"
FRAMEWORKS_PATH="$BUNDLE_PATH/Contents/Frameworks"

# Find Identity
# valid for keychain setup by apple-actions/import-codesign-certs or manual
IDENTITY_HASH=$(security find-identity -v -p codesigning | grep -oE '"[^"]+"' | head -1 | tr -d '"')

if [ -z "$IDENTITY_HASH" ]; then
    echo "❌ CRITICAL ERROR: No signing identity found."
    exit 1
fi

echo "ℹ️  Signing with Identity: $IDENTITY_HASH"

# Sign Sparkle Components
SPARKLE_FRAMEWORK="$FRAMEWORKS_PATH/Sparkle.framework"

# 1. Sign Autoupdate
AUTOUPDATE_PATH=$(find "$SPARKLE_FRAMEWORK" -name "Autoupdate" -type f | head -n 1)
if [ -z "$AUTOUPDATE_PATH" ]; then
    echo "❌ CRITICAL ERROR: Autoupdate binary not found"
    exit 1
fi
/usr/bin/codesign --force --options runtime --sign "$IDENTITY_HASH" "$AUTOUPDATE_PATH"

# 2. Sign Updater.app (if applicable)
UPDATER_APP_PATH=$(find "$SPARKLE_FRAMEWORK" -name "Updater.app" -type d | head -n 1)
if [ -n "$UPDATER_APP_PATH" ]; then
    echo "ℹ️  Signing Updater.app..."
    /usr/bin/codesign --force --options runtime --sign "$IDENTITY_HASH" "$UPDATER_APP_PATH/Contents/MacOS/Updater"
    /usr/bin/codesign --force --options runtime --sign "$IDENTITY_HASH" "$UPDATER_APP_PATH"
fi

# 3. Sign Sparkle Framework
/usr/bin/codesign --force --options runtime --sign "$IDENTITY_HASH" "$SPARKLE_FRAMEWORK"

# 4. Sign Main Binary
/usr/bin/codesign --force --options runtime --sign "$IDENTITY_HASH" "$BUNDLE_PATH/Contents/MacOS/ProxmoxBar"

# 5. Sign Bundle
/usr/bin/codesign --force --options runtime --sign "$IDENTITY_HASH" "$BUNDLE_PATH"

echo "✅ Application Signed Successfully!"
