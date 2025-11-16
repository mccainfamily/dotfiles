#!/bin/bash

################################################################################
# Dotfiles User Installation Script
#
# This script performs a personal setup for an individual user:
# - Clones dotfiles repository to ~/.dotfiles
# - Installs Homebrew in user's account (if not already installed)
# - Installs packages using install-apps.sh
# - Configures shell, terminal, and development environment
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash
#
# Or with custom profile:
#   curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile creative
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

log_header() {
    echo
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
}

################################################################################
# Configuration
################################################################################

DOTFILES_REPO="https://github.com/mccainfamily/dotfiles.git"
DOTFILES_BRANCH="main"
DOTFILES_DIR="${HOME}/.dotfiles"
INSTALL_PROFILE="everything"  # Default to everything profile
INSTALL_BUNDLES=""
EXCLUDE_BUNDLES=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            INSTALL_PROFILE="$2"
            shift 2
            ;;
        --bundles)
            INSTALL_BUNDLES="$2"
            INSTALL_PROFILE=""
            shift 2
            ;;
        --exclude)
            EXCLUDE_BUNDLES="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --profile <name>    Install using a profile (default: base)"
            echo "  --bundles \"<list>\"  Install specific bundles"
            echo "  --exclude \"<list>\"  Exclude specific bundles"
            echo "  --help              Show this help message"
            echo ""
            echo "Available profiles: everything, base, creative, kids, work"
            echo ""
            echo "Examples:"
            echo "  $0 --profile everything"
            echo "  $0 --bundles \"base development\""
            echo "  $0 --profile everything --exclude \"entertainment creative\""
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

################################################################################
# Pre-flight checks
################################################################################

log_header "Dotfiles Installation"

log_info "Starting dotfiles installation for user: ${USER}"

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_error "This script is designed for macOS only"
    exit 1
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

################################################################################
# Step 1: Clone Dotfiles Repository
################################################################################

log_header "Step 1: Cloning Dotfiles"

if [[ -d "${DOTFILES_DIR}" ]]; then
    log_info "Dotfiles directory already exists at ${DOTFILES_DIR}"

    # Check if it's a git repository
    if [[ -d "${DOTFILES_DIR}/.git" ]]; then
        log_info "Updating existing repository..."
        cd "${DOTFILES_DIR}"

        # Save current branch
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

        # Fetch latest changes
        if git fetch origin 2>/dev/null; then
            # Try to pull if on a tracking branch
            if git pull origin "${CURRENT_BRANCH}" 2>/dev/null; then
                log_success "Repository updated successfully"
            else
                log_warning "Could not auto-update repository (may have local changes)"
                log_info "Run 'cd ${DOTFILES_DIR} && git pull' manually if needed"
            fi
        else
            log_warning "Could not fetch updates from remote"
        fi
        cd - > /dev/null
    else
        log_warning "Directory exists but is not a git repository"
        log_info "Using existing directory contents"
    fi
else
    log_info "Cloning ${DOTFILES_REPO}..."
    if git clone -b "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" "${DOTFILES_DIR}"; then
        log_success "Dotfiles cloned to ${DOTFILES_DIR}"
    else
        log_error "Failed to clone repository"
        exit 1
    fi
fi

################################################################################
# Step 2: Install Homebrew
################################################################################

log_header "Step 2: Installing Homebrew"

# Use the dedicated Homebrew installation script
HOMEBREW_INSTALL_SCRIPT="${DOTFILES_DIR}/scripts/single-user-homebrew-install.sh"

if [[ ! -f "${HOMEBREW_INSTALL_SCRIPT}" ]]; then
    log_error "Homebrew installation script not found at ${HOMEBREW_INSTALL_SCRIPT}"
    exit 1
fi

chmod +x "${HOMEBREW_INSTALL_SCRIPT}"

if bash "${HOMEBREW_INSTALL_SCRIPT}"; then
    log_success "Homebrew is ready"

    # Detect architecture and set Homebrew path
    ARCH="$(uname -m)"
    if [[ "${ARCH}" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew"
    else
        BREW_PREFIX="/usr/local"
    fi
    BREW_BIN="${BREW_PREFIX}/bin/brew"

    # Ensure Homebrew is in PATH for this session
    if ! command -v brew >/dev/null 2>&1; then
        log_info "Adding Homebrew to PATH for this session..."
        eval "$(${BREW_BIN} shellenv)"
    fi

    log_info "Homebrew version: $(brew --version | head -n1)"
else
    log_error "Homebrew installation failed"
    exit 1
fi

################################################################################
# Step 3: Install Packages
################################################################################

log_header "Step 3: Installing Packages"

INSTALL_APPS_SCRIPT="${DOTFILES_DIR}/scripts/install-apps.sh"

if [[ ! -f "${INSTALL_APPS_SCRIPT}" ]]; then
    log_error "install-apps.sh not found at ${INSTALL_APPS_SCRIPT}"
    exit 1
fi

chmod +x "${INSTALL_APPS_SCRIPT}"

# Build installation command
INSTALL_ARGS=""
if [[ -n "${INSTALL_PROFILE}" ]]; then
    log_info "Installing profile: ${INSTALL_PROFILE}"
    INSTALL_ARGS="--profile ${INSTALL_PROFILE}"
elif [[ -n "${INSTALL_BUNDLES}" ]]; then
    log_info "Installing bundles: ${INSTALL_BUNDLES}"
    INSTALL_ARGS="--bundles \"${INSTALL_BUNDLES}\""
fi

if [[ -n "${EXCLUDE_BUNDLES}" ]]; then
    log_info "Excluding bundles: ${EXCLUDE_BUNDLES}"
    INSTALL_ARGS="${INSTALL_ARGS} --exclude \"${EXCLUDE_BUNDLES}\""
fi

log_info "Running install-apps.sh..."
cd "${DOTFILES_DIR}"

# Run install-apps.sh
eval "${INSTALL_APPS_SCRIPT} ${INSTALL_ARGS}"

if [[ $? -ne 0 ]]; then
    log_error "Package installation failed"
    exit 1
fi

log_success "All packages installed successfully"

################################################################################
# Step 4: Deploy Configuration Files
################################################################################

log_header "Step 4: Deploying Configuration Files"

# Symlink configuration files
log_info "Creating symlinks for configuration files..."

# Shell configs
for config in .zshrc .bashrc .bash_profile .gitconfig; do
    source_file="${DOTFILES_DIR}/config/${config}"
    target_file="${HOME}/${config}"

    if [[ -f "${source_file}" ]]; then
        # Check if symlink already points to correct location
        if [[ -L "${target_file}" ]]; then
            CURRENT_TARGET=$(readlink "${target_file}")
            if [[ "${CURRENT_TARGET}" == "${source_file}" ]]; then
                log_info "${config} already linked correctly"
                continue
            fi
        fi

        # Backup existing file if it's not a symlink
        if [[ -f "${target_file}" ]] && [[ ! -L "${target_file}" ]]; then
            mv "${target_file}" "${target_file}.backup.$(date +%Y%m%d-%H%M%S)"
            log_info "Backed up existing ${config}"
        fi

        # Create symlink
        ln -sf "${source_file}" "${target_file}"
        log_success "Linked ${config}"
    fi
done

# SSH config
if [[ -f "${DOTFILES_DIR}/config/ssh_config" ]]; then
    SSH_DIR="${HOME}/.ssh"
    SSH_CONFIG="${SSH_DIR}/config"

    mkdir -p "${SSH_DIR}"
    chmod 700 "${SSH_DIR}"

    # Create sockets directory for SSH connection sharing
    mkdir -p "${SSH_DIR}/sockets"
    chmod 700 "${SSH_DIR}/sockets"

    # Check if symlink already points to correct location
    if [[ -L "${SSH_CONFIG}" ]]; then
        CURRENT_TARGET=$(readlink "${SSH_CONFIG}")
        if [[ "${CURRENT_TARGET}" == "${DOTFILES_DIR}/config/ssh_config" ]]; then
            log_info "SSH config already linked correctly"
        else
            ln -sf "${DOTFILES_DIR}/config/ssh_config" "${SSH_CONFIG}"
            chmod 600 "${SSH_CONFIG}"
            log_success "Updated SSH config symlink"
        fi
    else
        # Backup existing SSH config if it's not a symlink
        if [[ -f "${SSH_CONFIG}" ]]; then
            mv "${SSH_CONFIG}" "${SSH_CONFIG}.backup.$(date +%Y%m%d-%H%M%S)"
            log_info "Backed up existing SSH config"
        fi

        # Link SSH config
        ln -sf "${DOTFILES_DIR}/config/ssh_config" "${SSH_CONFIG}"
        chmod 600 "${SSH_CONFIG}"
        log_success "Linked SSH config (macOS keychain integration enabled)"
    fi
fi

# Starship config
if [[ -f "${DOTFILES_DIR}/config/starship.toml" ]]; then
    STARSHIP_CONFIG_DIR="${HOME}/.config"
    STARSHIP_CONFIG="${STARSHIP_CONFIG_DIR}/starship.toml"
    mkdir -p "${STARSHIP_CONFIG_DIR}"

    # Check if symlink already points to correct location
    if [[ -L "${STARSHIP_CONFIG}" ]]; then
        CURRENT_TARGET=$(readlink "${STARSHIP_CONFIG}")
        if [[ "${CURRENT_TARGET}" == "${DOTFILES_DIR}/config/starship.toml" ]]; then
            log_info "Starship config already linked correctly"
        else
            ln -sf "${DOTFILES_DIR}/config/starship.toml" "${STARSHIP_CONFIG}"
            log_success "Updated starship.toml symlink"
        fi
    else
        ln -sf "${DOTFILES_DIR}/config/starship.toml" "${STARSHIP_CONFIG}"
        log_success "Linked starship.toml"
    fi
fi

# Create Go workspace directory
GO_SRC_DIR="${HOME}/src/github.com"
if [[ ! -d "${GO_SRC_DIR}" ]]; then
    mkdir -p "${GO_SRC_DIR}"
    log_success "Created ~/src/github.com directory"
else
    log_info "Go workspace directory already exists"
fi

################################################################################
# Step 5: VS Code CLI Integration
################################################################################

log_header "Step 5: VS Code CLI Integration"

VSCODE_PATH="/Applications/Visual Studio Code.app"
if [[ -d "${VSCODE_PATH}" ]]; then
    VSCODE_BIN="${VSCODE_PATH}/Contents/Resources/app/bin/code"

    if [[ -f "${VSCODE_BIN}" ]]; then
        CODE_SYMLINK="${BREW_PREFIX}/bin/code"

        # Check if symlink already exists and points to correct location
        if [[ -L "${CODE_SYMLINK}" ]]; then
            CURRENT_TARGET=$(readlink "${CODE_SYMLINK}")
            if [[ "${CURRENT_TARGET}" == "${VSCODE_BIN}" ]]; then
                log_info "VS Code CLI already linked correctly"
            else
                if [[ -w "${BREW_PREFIX}/bin" ]]; then
                    ln -sf "${VSCODE_BIN}" "${CODE_SYMLINK}"
                    log_success "Updated VS Code CLI symlink"
                fi
            fi
        elif [[ -w "${BREW_PREFIX}/bin" ]]; then
            ln -sf "${VSCODE_BIN}" "${CODE_SYMLINK}"
            log_success "VS Code CLI installed: code"
        else
            log_warning "Cannot write to ${BREW_PREFIX}/bin - skipping VS Code CLI"
            log_info "Run manually: sudo ln -sf \"${VSCODE_BIN}\" \"${BREW_PREFIX}/bin/code\""
        fi
    fi
else
    log_info "VS Code not installed - CLI will be available after installing development bundle"
fi

################################################################################
# Completion
################################################################################

log_header "Installation Complete!"

echo ""
log_success "Dotfiles installation completed successfully!"
echo ""
echo "Summary:"
echo "  User: ${USER}"
echo "  Dotfiles: ${DOTFILES_DIR}"
echo "  Homebrew: ${BREW_BIN}"
echo "  Profile: ${INSTALL_PROFILE:-custom bundles}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Configure Git with your credentials:"
echo "     git config --global user.name \"Your Name\""
echo "     git config --global user.email \"your.email@example.com\""
echo ""
echo "To install additional bundles, run:"
echo "  cd ${DOTFILES_DIR}"
echo "  ./scripts/install-apps.sh --list-profiles"
echo "  ./scripts/install-apps.sh --list-bundles"
echo "  ./scripts/install-apps.sh --bundles \"bundle-name\""
echo ""

exit 0
