#!/bin/bash

################################################################################
# Update Script
# Updates Homebrew, all packages, and cleans up
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Homebrew Update & Upgrade ==="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed"
    echo "Run: ${SCRIPT_DIR}/homebrew-setup.sh"
    exit 1
fi

# Detect Homebrew location
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    BREW_BIN="/opt/homebrew/bin/brew"
elif [[ -f "/usr/local/bin/brew" ]]; then
    BREW_BIN="/usr/local/bin/brew"
else
    BREW_BIN="brew"
fi

echo "Step 1: Updating Homebrew..."
"${BREW_BIN}" update

echo ""
echo "Step 2: Upgrading all packages..."
"${BREW_BIN}" upgrade

echo ""
echo "Step 3: Upgrading all casks..."
"${BREW_BIN}" upgrade --cask --greedy

echo ""
echo "Step 4: Running bundle cleanup (removing unlisted packages)..."
if [[ -f "${DOTFILES_DIR}/brew/Brewfile" ]]; then
    "${BREW_BIN}" bundle cleanup --file="${DOTFILES_DIR}/brew/Brewfile" --force
else
    echo "Warning: Brewfile not found, skipping bundle cleanup"
fi

echo ""
echo "Step 5: Cleaning up old versions..."
"${BREW_BIN}" cleanup

echo ""
echo "Step 6: Running brew doctor..."
"${BREW_BIN}" doctor || echo "Warning: brew doctor found some issues (non-fatal)"

echo ""
echo "✓ Update complete!"
echo ""
echo "Summary:"
"${BREW_BIN}" list --versions | wc -l | xargs echo "Installed formulae:"
"${BREW_BIN}" list --cask --versions | wc -l | xargs echo "Installed casks:"
echo ""
