#!/bin/bash

################################################################################
# Single-User Homebrew Installation Script
#
# Installs Homebrew for the current user's account (not system-wide).
# This script can be called standalone or sourced by other scripts.
#
# Usage:
#   bash scripts/single-user-homebrew-install.sh
#
# Returns:
#   0 - Homebrew is installed and ready
#   1 - Installation failed
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

################################################################################
# Main Installation
################################################################################

main() {
    log_info "Checking Homebrew installation..."

    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        log_error "This script is designed for macOS only"
        return 1
    fi

    # Detect architecture
    ARCH="$(uname -m)"
    if [[ "${ARCH}" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew"
        log_info "Architecture: Apple Silicon (arm64)"
    else
        BREW_PREFIX="/usr/local"
        log_info "Architecture: Intel (x86_64)"
    fi

    BREW_BIN="${BREW_PREFIX}/bin/brew"

    # Check if Homebrew is already installed
    if [[ -f "${BREW_BIN}" ]]; then
        log_success "Homebrew already installed at ${BREW_PREFIX}"

        # Ensure Homebrew is in PATH for this session
        if ! command -v brew >/dev/null 2>&1; then
            log_info "Adding Homebrew to PATH for this session..."
            eval "$(${BREW_BIN} shellenv)"
        fi

        # Check when last updated (skip if updated in last 24 hours)
        BREW_LAST_UPDATE="${BREW_PREFIX}/.git/FETCH_HEAD"
        if [[ -f "${BREW_LAST_UPDATE}" ]]; then
            LAST_UPDATE=$(stat -f %m "${BREW_LAST_UPDATE}" 2>/dev/null || echo 0)
            CURRENT_TIME=$(date +%s)
            TIME_DIFF=$((CURRENT_TIME - LAST_UPDATE))

            # 86400 seconds = 24 hours
            if [[ ${TIME_DIFF} -lt 86400 ]]; then
                log_info "Homebrew was updated recently, skipping update"
            else
                log_info "Updating Homebrew..."
                "${BREW_BIN}" update || log_warning "Homebrew update failed (continuing anyway)"
            fi
        else
            log_info "Updating Homebrew..."
            "${BREW_BIN}" update || log_warning "Homebrew update failed (continuing anyway)"
        fi

        log_info "Homebrew version: $(${BREW_BIN} --version | head -n1)"
        return 0
    fi

    # Install Homebrew
    log_info "Installing Homebrew to ${BREW_PREFIX}..."
    echo ""

    # Request sudo access upfront
    log_warning "Requesting sudo access for Homebrew installation..."
    if ! sudo -v; then
        log_error "Sudo access required for Homebrew installation"
        return 1
    fi

    # Keep sudo alive in background during installation
    ( while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null ) &
    SUDO_KEEPALIVE_PID=$!

    # Set NONINTERACTIVE for automated installation
    export NONINTERACTIVE=1

    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Kill sudo keepalive
        kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
        log_success "Homebrew installed at ${BREW_PREFIX}"

        # Add Homebrew to PATH for this session
        eval "$(${BREW_BIN} shellenv)"

        # Add to shell profile if not already present
        SHELL_PROFILE=""
        if [[ -n "${ZSH_VERSION}" ]] || [[ "${SHELL}" == *"zsh"* ]]; then
            SHELL_PROFILE="${HOME}/.zprofile"
        elif [[ -n "${BASH_VERSION}" ]] || [[ "${SHELL}" == *"bash"* ]]; then
            SHELL_PROFILE="${HOME}/.bash_profile"
        fi

        if [[ -n "${SHELL_PROFILE}" ]]; then
            if ! grep -q "eval.*brew shellenv" "${SHELL_PROFILE}" 2>/dev/null; then
                echo "" >> "${SHELL_PROFILE}"
                echo '# Homebrew' >> "${SHELL_PROFILE}"
                echo 'eval "$('${BREW_BIN}' shellenv)"' >> "${SHELL_PROFILE}"
                log_success "Added Homebrew to ${SHELL_PROFILE}"
            fi
        fi

        log_info "Homebrew version: $(${BREW_BIN} --version | head -n1)"
        log_success "Homebrew installation complete"
        return 0
    else
        # Kill sudo keepalive on failure
        kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true
        log_error "Homebrew installation failed"
        return 1
    fi
}

# Run main function
main "$@"
