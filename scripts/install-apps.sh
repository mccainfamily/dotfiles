#!/bin/bash

################################################################################
# Modular App Installer
#
# Install Homebrew packages using modular bundles and profiles
#
# Usage:
#   ./install-apps.sh --profile network-engineer
#   ./install-apps.sh --bundles "base development"
#   ./install-apps.sh --profile complete --exclude "entertainment creative"
#   ./install-apps.sh --list-profiles
#   ./install-apps.sh --list-bundles
################################################################################

set -e

# Configuration
# Auto-detect if running from repository or installed location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "${SCRIPT_DIR}/../brew/bundles" ]]; then
    DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
else
    DOTFILES_DIR="${HOME}/.dotfiles"
fi

BUNDLES_DIR="${DOTFILES_DIR}/brew/bundles"
PROFILES_DIR="${DOTFILES_DIR}/brew/profiles"
PROFILES_FILE="${PROFILES_DIR}/profiles.conf"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
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

log_bundle() {
    echo -e "${CYAN}📦${NC} $1"
}

################################################################################
# Cleanup function
################################################################################

cleanup() {
    # Placeholder for future cleanup tasks
    :
}

# Set trap to cleanup on exit
trap cleanup EXIT

# List available bundles
list_bundles() {
    echo "Available Bundles:"
    echo
    # Get unique module names by checking for any module files
    declare -A modules
    for bundle in "${BUNDLES_DIR}"/*.Brewfile "${BUNDLES_DIR}"/*.Appfile "${BUNDLES_DIR}"/*.sh; do
        [[ -f "$bundle" ]] || continue
        bundle_name=$(basename "$bundle" | sed -E 's/\.(Brewfile|Appfile|sh)$//')
        modules["$bundle_name"]=1
    done

    # Display each unique module with its available file types
    for module_name in $(echo "${!modules[@]}" | tr ' ' '\n' | sort); do
        files=()
        [[ -f "${BUNDLES_DIR}/${module_name}.Brewfile" ]] && files+=("Brewfile")
        [[ -f "${BUNDLES_DIR}/${module_name}.Appfile" ]] && files+=("Appfile")
        [[ -f "${BUNDLES_DIR}/${module_name}.sh" ]] && files+=("Custom Script")

        # Read first comment line from Brewfile or Appfile for description
        description=""
        if [[ -f "${BUNDLES_DIR}/${module_name}.Brewfile" ]]; then
            description=$(grep -m 1 "^# " "${BUNDLES_DIR}/${module_name}.Brewfile" | sed 's/^# //')
        elif [[ -f "${BUNDLES_DIR}/${module_name}.Appfile" ]]; then
            description=$(grep -m 1 "^# " "${BUNDLES_DIR}/${module_name}.Appfile" | sed 's/^# //')
        fi

        echo -e "  ${CYAN}${module_name}${NC} ($(IFS=', '; echo "${files[*]}"))"
        [[ -n "$description" ]] && echo "    $description"
    done
}

# List available profiles
list_profiles() {
    echo "Available Profiles:"
    echo
    # shellcheck source=/dev/null
    source "${PROFILES_FILE}"

    # Get all profile variables
    profiles=$(grep "^PROFILE_" "${PROFILES_FILE}" | cut -d= -f1 | sed 's/PROFILE_//' | tr '[:upper:]' '[:lower:]')

    for profile in $profiles; do
        profile_upper=$(echo "$profile" | tr '[:lower:]' '[:upper:]')
        var_name="PROFILE_${profile_upper}"
        bundles="${!var_name}"

        echo -e "  ${GREEN}${profile}${NC}"
        echo "    Bundles: $bundles"
    done
}

# Show contents of a specific bundle
show_bundle() {
    local bundle="$1"

    if [[ -z "$bundle" ]]; then
        log_error "Bundle name is required"
        echo "Usage: install-apps.sh --show-bundle <bundle-name>"
        exit 1
    fi

    # Check if bundle exists
    if [[ ! -f "${BUNDLES_DIR}/${bundle}.Brewfile" ]] && \
       [[ ! -f "${BUNDLES_DIR}/${bundle}.Appfile" ]] && \
       [[ ! -f "${BUNDLES_DIR}/${bundle}.sh" ]]; then
        log_error "Bundle '${bundle}' not found"
        echo
        list_bundles
        exit 1
    fi

    echo "Contents of bundle: ${bundle}"
    echo

    # Show Brewfile if exists
    if [[ -f "${BUNDLES_DIR}/${bundle}.Brewfile" ]]; then
        echo -e "${CYAN}=== Brewfile ===${NC}"
        cat "${BUNDLES_DIR}/${bundle}.Brewfile"
        echo
    fi

    # Show Appfile if exists
    if [[ -f "${BUNDLES_DIR}/${bundle}.Appfile" ]]; then
        echo -e "${CYAN}=== Appfile ===${NC}"
        cat "${BUNDLES_DIR}/${bundle}.Appfile"
        echo
    fi

    # Show custom script if exists
    if [[ -f "${BUNDLES_DIR}/${bundle}.sh" ]]; then
        echo -e "${CYAN}=== Custom Script ===${NC}"
        cat "${BUNDLES_DIR}/${bundle}.sh"
        echo
    fi
}

# Get bundles for a profile
get_profile_bundles() {
    local profile="$1"
    local profile_upper
    profile_upper=$(echo "$profile" | tr '[:lower:]' '[:upper:]')
    local var_name="PROFILE_${profile_upper}"

    # shellcheck source=/dev/null
    source "${PROFILES_FILE}"

    if [[ -z "${!var_name}" ]]; then
        log_error "Profile '${profile}' not found"
        echo
        list_profiles
        exit 1
    fi

    echo "${!var_name}"
}

# Install a single module (all associated file types)
install_bundle() {
    local module="$1"
    local module_success=0

    # Check if module exists (has at least one file type)
    if [[ ! -f "${BUNDLES_DIR}/${module}.Brewfile" ]] && \
       [[ ! -f "${BUNDLES_DIR}/${module}.Appfile" ]] && \
       [[ ! -f "${BUNDLES_DIR}/${module}.sh" ]]; then
        log_error "Module '${module}' not found (no .Brewfile, .Appfile, or .sh file exists)"
        return 1
    fi

    log_bundle "Installing module: ${module}"

    # Check if brew is available in PATH, otherwise use architecture-specific path
    if command -v brew >/dev/null 2>&1; then
        BREW_BIN="brew"
    else
        # Fallback to architecture-specific path
        ARCH="$(uname -m)"
        if [[ "${ARCH}" == "arm64" ]]; then
            BREW_PREFIX="/opt/homebrew"
        else
            BREW_PREFIX="/usr/local"
        fi
        BREW_BIN="${BREW_PREFIX}/bin/brew"

        # Verify brew exists at this path
        if [[ ! -x "${BREW_BIN}" ]]; then
            log_error "Homebrew not found. Please install Homebrew first."
            log_info "Visit: https://brew.sh or run: ./scripts/single-user-homebrew-install.sh"
            return 1
        fi
    fi

    # Install Brewfile if it exists
    if [[ -f "${BUNDLES_DIR}/${module}.Brewfile" ]]; then
        log_info "Installing Homebrew packages from ${module}.Brewfile..."
        if ${BREW_BIN} bundle install --file="${BUNDLES_DIR}/${module}.Brewfile"; then
            log_success "Brewfile for '${module}' installed successfully"
        else
            log_error "Failed to install Brewfile for '${module}'"
            module_success=1
        fi
    fi

    # Install Appfile if it exists
    if [[ -f "${BUNDLES_DIR}/${module}.Appfile" ]]; then
        log_info "Installing App Store apps from ${module}.Appfile..."
        if ${BREW_BIN} bundle install --file="${BUNDLES_DIR}/${module}.Appfile"; then
            log_success "Appfile for '${module}' installed successfully"
        else
            log_error "Failed to install Appfile for '${module}'"
            module_success=1
        fi
    fi

    # Run custom script if it exists
    if [[ -f "${BUNDLES_DIR}/${module}.sh" ]]; then
        log_info "Running custom installer script ${module}.sh..."
        if bash "${BUNDLES_DIR}/${module}.sh"; then
            log_success "Custom script for '${module}' completed successfully"
        else
            log_warning "Custom script for '${module}' failed or had warnings"
            module_success=1
        fi
    fi

    if [[ ${module_success} -eq 0 ]]; then
        log_success "Module '${module}' installed successfully"
    fi

    return ${module_success}
}

# Uninstall a single module (all associated file types)
uninstall_bundle() {
    local module="$1"
    local module_success=0

    # Check if module exists (has at least one file type)
    if [[ ! -f "${BUNDLES_DIR}/${module}.Brewfile" ]] && \
       [[ ! -f "${BUNDLES_DIR}/${module}.Appfile" ]]; then
        log_error "Module '${module}' not found (no .Brewfile or .Appfile exists)"
        return 1
    fi

    log_bundle "Uninstalling module: ${module}"

    # Check if brew is available in PATH, otherwise use architecture-specific path
    if command -v brew >/dev/null 2>&1; then
        BREW_BIN="brew"
    else
        # Fallback to architecture-specific path
        ARCH="$(uname -m)"
        if [[ "${ARCH}" == "arm64" ]]; then
            BREW_PREFIX="/opt/homebrew"
        else
            BREW_PREFIX="/usr/local"
        fi
        BREW_BIN="${BREW_PREFIX}/bin/brew"

        # Verify brew exists at this path
        if [[ ! -x "${BREW_BIN}" ]]; then
            log_error "Homebrew not found. Please install Homebrew first."
            log_info "Visit: https://brew.sh or run: ./scripts/single-user-homebrew-install.sh"
            return 1
        fi
    fi

    # Uninstall Brewfile packages if it exists
    if [[ -f "${BUNDLES_DIR}/${module}.Brewfile" ]]; then
        log_info "Uninstalling Homebrew packages from ${module}.Brewfile..."
        if ${BREW_BIN} bundle cleanup --force --file="${BUNDLES_DIR}/${module}.Brewfile"; then
            log_success "Brewfile packages for '${module}' uninstalled successfully"
        else
            log_warning "Some packages from Brewfile for '${module}' may not have been uninstalled"
            module_success=1
        fi
    fi

    # Uninstall Appfile apps if it exists
    if [[ -f "${BUNDLES_DIR}/${module}.Appfile" ]]; then
        log_info "Uninstalling App Store apps from ${module}.Appfile..."
        if ${BREW_BIN} bundle cleanup --force --file="${BUNDLES_DIR}/${module}.Appfile"; then
            log_success "Appfile apps for '${module}' uninstalled successfully"
        else
            log_warning "Some apps from Appfile for '${module}' may not have been uninstalled"
            module_success=1
        fi
    fi

    if [[ ${module_success} -eq 0 ]]; then
        log_success "Module '${module}' uninstalled successfully"
    fi

    return ${module_success}
}

# Show usage
usage() {
    cat << EOF
Usage: ${0##*/} [OPTIONS]

Install Homebrew packages using modular bundles and profiles.

OPTIONS:
    --profile <name>       Install bundles for a specific profile
    --bundles "<list>"     Install specific bundles (space-separated)
    --exclude "<list>"     Exclude specific bundles (space-separated)
    --uninstall            Uninstall packages instead of installing
    --yes, -y              Skip confirmation prompt (non-interactive mode)
    --list-profiles        List all available profiles
    --list-bundles         List all available bundles
    --show-bundle <name>   Show contents of a specific bundle
    --help                 Show this help message

EXAMPLES:
    # Install using a profile
    ${0##*/} --profile network-engineer

    # Install profile with exclusions
    ${0##*/} --profile complete --exclude "entertainment creative"

    # Install specific bundles
    ${0##*/} --bundles "base development"

    # Uninstall a profile
    ${0##*/} --uninstall --profile personal

    # Uninstall specific bundles
    ${0##*/} --uninstall --bundles "entertainment creative"

    # List available options
    ${0##*/} --list-profiles
    ${0##*/} --list-bundles

    # Show bundle contents
    ${0##*/} --show-bundle base

PROFILES:
    minimal               - Just essential tools
    network-engineer      - Network security and cloud infrastructure
    developer             - Development tools and cloud
    fullstack             - Full stack development
    security              - Security-focused setup
    devops                - Infrastructure and automation
    creative              - Creative tools
    complete              - Everything (power user)
    work                  - Professional tools
    personal              - Personal setup with entertainment

BUNDLES:
    base                  - Essential tools for all users
    network-security      - Network scanning and security tools
    cloud-infrastructure  - AWS, K8s, Terraform, etc.
    development           - Languages, IDEs, dev tools
    security-privacy      - Encryption, Proton suite, Yubikey
    diagrams              - PlantUML, Mermaid, Graphviz, etc.
    monitoring            - Prometheus, Grafana, etc.
    creative              - Design and creative tools
    communication         - Zoom, Teams, WhatsApp
    entertainment         - Games, Spotify, Audible

EOF
}

# Main logic
main() {
    # Check if we're in the dotfiles directory
    if [[ ! -d "${BUNDLES_DIR}" ]]; then
        log_error "Bundles directory not found: ${BUNDLES_DIR}"
        log_info "Make sure you're running this from the dotfiles repository"
        exit 1
    fi

    # Check for Homebrew
    ARCH="$(uname -m)"
    if [[ "${ARCH}" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew"
    else
        BREW_PREFIX="/usr/local"
    fi

    BREW_BIN="${BREW_PREFIX}/bin/brew"

    if [[ ! -f "${BREW_BIN}" ]]; then
        log_error "Homebrew not found at ${BREW_BIN}"
        log_info "Install Homebrew first: https://brew.sh"
        exit 1
    fi

    # Parse arguments
    if [[ $# -eq 0 ]]; then
        usage
        exit 0
    fi

    SKIP_CONFIRMATION=0
    UNINSTALL_MODE=0

    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                PROFILE="$2"
                shift 2
                ;;
            --bundles)
                BUNDLES="$2"
                shift 2
                ;;
            --exclude)
                EXCLUDE_BUNDLES="$2"
                shift 2
                ;;
            --uninstall)
                UNINSTALL_MODE=1
                shift
                ;;
            --yes|-y)
                SKIP_CONFIRMATION=1
                shift
                ;;
            --list-profiles)
                list_profiles
                exit 0
                ;;
            --list-bundles)
                list_bundles
                exit 0
                ;;
            --show-bundle)
                show_bundle "$2"
                exit 0
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    # Determine bundles to install
    if [[ -n "${PROFILE}" ]]; then
        log_info "Using profile: ${PROFILE}"
        BUNDLES=$(get_profile_bundles "${PROFILE}")
        log_info "Bundles to install: ${BUNDLES}"
    elif [[ -z "${BUNDLES}" ]]; then
        log_error "Either --profile or --bundles must be specified"
        usage
        exit 1
    fi

    # Apply exclusions if specified
    if [[ -n "${EXCLUDE_BUNDLES}" ]]; then
        log_info "Excluding bundles: ${EXCLUDE_BUNDLES}"

        for exclude in ${EXCLUDE_BUNDLES}; do
            # Never allow excluding the base bundle
            if [[ "${exclude}" == "base" ]]; then
                log_warning "Cannot exclude 'base' bundle - ignoring exclusion"
                continue
            fi

            # Remove the excluded bundle from the list
            BUNDLES=$(echo " ${BUNDLES} " | sed "s/ ${exclude} / /g" | xargs)
        done

        # Remove duplicate bundles and extra spaces
        BUNDLES=$(echo "${BUNDLES}" | tr ' ' '\n' | awk '!seen[$0]++' | tr '\n' ' ' | xargs)
        log_info "Final bundles after exclusions: ${BUNDLES}"
    fi

    # Confirm installation or uninstallation
    echo
    if [[ ${UNINSTALL_MODE} -eq 1 ]]; then
        echo "The following bundles will be uninstalled:"
    else
        echo "The following bundles will be installed:"
    fi
    for bundle in $BUNDLES; do
        echo "  - ${bundle}"
    done
    echo

    if [[ ${SKIP_CONFIRMATION} -eq 0 ]]; then
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Cancelled"
            exit 0
        fi
    else
        log_info "Skipping confirmation (non-interactive mode)"
    fi

    # Note: Homebrew will prompt for sudo password when needed for cask installations
    # No need to request sudo upfront - let Homebrew handle it per-package

    # Install or uninstall bundles
    echo
    if [[ ${UNINSTALL_MODE} -eq 1 ]]; then
        log_info "Starting uninstallation..."
    else
        log_info "Starting installation..."
    fi
    echo

    failed_bundles=()
    for bundle in $BUNDLES; do
        if [[ ${UNINSTALL_MODE} -eq 1 ]]; then
            if ! uninstall_bundle "$bundle"; then
                failed_bundles+=("$bundle")
            fi
        else
            if ! install_bundle "$bundle"; then
                failed_bundles+=("$bundle")
            fi
        fi
        echo
    done

    # Summary
    echo
    echo "=================================================="
    if [[ ${#failed_bundles[@]} -eq 0 ]]; then
        if [[ ${UNINSTALL_MODE} -eq 1 ]]; then
            log_success "All bundles uninstalled successfully!"
        else
            log_success "All bundles installed successfully!"
        fi
    else
        if [[ ${UNINSTALL_MODE} -eq 1 ]]; then
            log_warning "Uninstallation completed with errors"
        else
            log_warning "Installation completed with errors"
        fi
        echo
        echo "Failed bundles:"
        for bundle in "${failed_bundles[@]}"; do
            echo "  - ${bundle}"
        done
    fi
    echo "=================================================="
}

main "$@"
