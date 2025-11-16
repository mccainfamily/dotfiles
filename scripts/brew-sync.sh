#!/bin/bash

################################################################################
# Brew Sync Script
# Syncs currently installed Homebrew packages to Brewfile
################################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
BREWFILE="${DOTFILES_DIR}/brew/Brewfile"
BREWFILE_BACKUP="${BREWFILE}.backup"

echo "=== Homebrew Sync to Brewfile ==="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Error: Homebrew is not installed"
    exit 1
fi

# Detect Homebrew location
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    BREW_PREFIX="/opt/homebrew"
elif [[ -f "/usr/local/bin/brew" ]]; then
    BREW_PREFIX="/usr/local"
else
    echo "Error: Cannot detect Homebrew installation"
    exit 1
fi

BREW_BIN="${BREW_PREFIX}/bin/brew"

echo "Homebrew location: ${BREW_BIN}"
echo "Dotfiles directory: ${DOTFILES_DIR}"
echo "Brewfile location: ${BREWFILE}"
echo ""

# Backup existing Brewfile if it exists
if [[ -f "${BREWFILE}" ]]; then
    echo "Backing up existing Brewfile to ${BREWFILE_BACKUP}"
    cp "${BREWFILE}" "${BREWFILE_BACKUP}"
fi

# Generate new Brewfile
echo "Generating Brewfile from current installations..."
cd "${DOTFILES_DIR}/brew"
"${BREW_BIN}" bundle dump --force --describe

echo ""
echo "✓ Brewfile updated successfully!"
echo ""
echo "Summary:"
echo "--------"

# Count packages
BREW_COUNT=$(grep -c "^brew " "${BREWFILE}" || echo "0")
CASK_COUNT=$(grep -c "^cask " "${BREWFILE}" || echo "0")
TAP_COUNT=$(grep -c "^tap " "${BREWFILE}" || echo "0")
MAS_COUNT=$(grep -c "^mas " "${BREWFILE}" || echo "0")

echo "Taps: ${TAP_COUNT}"
echo "Formulae: ${BREW_COUNT}"
echo "Casks: ${CASK_COUNT}"
echo "Mac App Store apps: ${MAS_COUNT}"
echo ""

# Show what's new if there's a backup
if [[ -f "${BREWFILE_BACKUP}" ]]; then
    echo "Changes since last sync:"
    if diff "${BREWFILE_BACKUP}" "${BREWFILE}" > /dev/null 2>&1; then
        echo "  No changes detected"
    else
        echo "  Packages added/removed - review with: diff ${BREWFILE_BACKUP} ${BREWFILE}"
    fi
    echo ""
fi

echo "Next steps:"
echo "1. Review the Brewfile: cat ${BREWFILE}"
echo "2. Commit changes: cd ${DOTFILES_DIR} && git add brew/Brewfile && git commit -m 'Update Brewfile'"
echo "3. Push to remote: git push"
echo ""
