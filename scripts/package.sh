#!/bin/bash
set -e

echo "📦 Creating DMG..."

if ! command -v create-dmg &> /dev/null; then
    echo "ℹ️  Installing create-dmg..."
    brew install create-dmg
fi

# Ensure no existing dmg
rm -f "ProxmoxBar.dmg"

create-dmg \
  --volname "ProxmoxBar Installer" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "ProxmoxBar.app" 200 190 \
  --hide-extension "ProxmoxBar.app" \
  --app-drop-link 600 185 \
  "ProxmoxBar.dmg" \
  "ProxmoxBar.app"

if [ ! -f "ProxmoxBar.dmg" ]; then
    echo "❌ CRITICAL ERROR: DMG creation failed"
    exit 1
fi

echo "✅ DMG Created Successfully!"
