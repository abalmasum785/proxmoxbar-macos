#!/bin/bash
set -e

echo "✨ Generating Sparkle Appcast..."

if [ -z "$SPARKLE_PRIVATE_KEY" ]; then
    echo "❌ CRITICAL ERROR: SPARKLE_PRIVATE_KEY not set"
    exit 1
fi

if [ -z "$TAG_NAME" ]; then
    echo "❌ CRITICAL ERROR: TAG_NAME not set"
    exit 1
fi

# 1. Download Sparkle Tools
# We download 2.6.0 as in the original workflow
if [ ! -d "sparkle_tools" ]; then
    echo "ℹ️  Downloading Sparkle Tools..."
    curl -L -o sparkle.tar.xz https://github.com/sparkle-project/Sparkle/releases/download/2.6.0/Sparkle-2.6.0.tar.xz
    mkdir sparkle_tools
    tar -xf sparkle.tar.xz -C sparkle_tools
fi

# 2. Sign the DMG
echo "ℹ️  Signing DMG..."
echo "$SPARKLE_PRIVATE_KEY" > sparkle_key.pem
./sparkle_tools/bin/sign_update "ProxmoxBar.dmg" --ed-key-file sparkle_key.pem

# 3. Prepare Release Assets
rm -rf release_assets
mkdir release_assets
cp "ProxmoxBar.dmg" release_assets/

DOWNLOAD_URL="https://github.com/ryzenixx/proxmoxbar-macos/releases/download/${TAG_NAME}/"

# 4. Generate Appcast
echo "ℹ️  Generating Appcast XML..."
echo "$SPARKLE_PRIVATE_KEY" | ./sparkle_tools/bin/generate_appcast \
    --download-url-prefix "$DOWNLOAD_URL" \
    --ed-key-file - \
    release_assets

# 5. Inject Release Notes
echo "ℹ️  Processing Release Notes..."
if ! command -v pandoc &> /dev/null; then
    echo "ℹ️  Installing pandoc..."
    brew install pandoc
fi

# Convert Markdown to HTML
if [ -f "RELEASE_NOTES.md" ]; then
    pandoc RELEASE_NOTES.md -f markdown -t html -o release_notes.html
    
    # Inject HTML content into the appcast as <description>
    # Note: Using perl as in original because it works reliably for multiline replacement
    perl -0777 -i -pe 'BEGIN { local $/; open(F, "<release_notes.html"); $notes = <F>; close(F); } s|</item>|<description><![CDATA[$notes]]></description></item>|' release_assets/appcast.xml
else
    echo "⚠️  RELEASE_NOTES.md not found, skipping injection."
fi

# Output for debugging
# cat release_assets/appcast.xml

echo "✅ Appcast Generated Successfully!"
