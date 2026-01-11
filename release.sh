#!/bin/bash

# Release Helper Script for ProxmoxBar
# Usage: ./release.sh [version]

# Ensure we are on the main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  You are not on the 'main' branch."
    read -p "Continue anyway? (y/N) " confirm
    if [[ "$confirm" != "y" ]]; then
        exit 1
    fi
fi

# Ensure working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Your working directory is not clean."
    echo "   Please commit or stash your changes before releasing."
    exit 1
fi

# Get version
VERSION=$1
if [ -z "$VERSION" ]; then
    # Fetch latest tag to help user
    git fetch --tags
    LATEST_TAG=$(git describe --tags `git rev-list --tags --max-count=1`)
    echo "ℹ️  Latest tag: $LATEST_TAG"
    
    read -p "Enter new version: " VERSION
fi

# Validate input
if [[ "$VERSION" != v* ]]; then
    VERSION="v$VERSION"
fi

echo "🚀 Preparing to release $VERSION..."

# Tag and Push
git tag $VERSION
git push origin $VERSION

echo "✅ Release trigger pushed!"
echo "👉 Check progress here: https://github.com/ryzenixx/proxmoxbar-macos/actions"
