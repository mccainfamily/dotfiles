#!/bin/bash

################################################################################
# ScaleFusion MDM Deployment Script for Dotfiles
#
# This script performs a complete setup:
# - Clones dotfiles repository
# - Installs Homebrew (as admin, not root)
# - Installs packages using install-apps.sh (profiles/bundles with exclusions)
# - Deploys configs to admin and all users
# - Creates time-limited sudo for cask installations
#
# Usage: Run via ScaleFusion MDM as root
################################################################################

set -e

################################################################################
# CONFIGURATION - EDIT THESE VALUES OR SET AS ENVIRONMENT VARIABLES
################################################################################

# Use environment variables if set, otherwise use defaults
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/mccainfamily/dotfiles.git}"
DOTFILES_BRANCH="${DOTFILES_BRANCH:-main}"
ADMIN_USER="${ADMIN_USER:-${SUDO_USER:-administrator}}"  # The administrator user who will own Homebrew
DEPLOY_TO_ALL_USERS="${DEPLOY_TO_ALL_USERS:-true}"      # Deploy configs to all users

# Profile/Bundle Configuration
# Options:
#   - Set INSTALL_PROFILE to use a predefined profile
#   - Set INSTALL_BUNDLES to specify custom bundles
#   - Set EXCLUDE_BUNDLES to exclude specific bundles from a profile
#
# Available profiles: everything, base, creative, kids, work
#
# Available bundles: base, network-security, cloud-infrastructure, development,
#                    development-appstore, security-privacy, diagrams, monitoring,
#                    monitoring-appstore, creative, creative-appstore, av-studio,
#                    av-studio-appstore, communication, entertainment,
#                    entertainment-appstore, work
#
# NOTE: The 'base' bundle is ALWAYS installed first and cannot be excluded.

# Install using a profile (recommended) - use environment variable if set
INSTALL_PROFILE="${INSTALL_PROFILE:-everything}"

# OR install specific bundles (leave INSTALL_PROFILE empty)
# INSTALL_BUNDLES is used from environment if set
INSTALL_BUNDLES="${INSTALL_BUNDLES:-}"

# Exclude specific bundles from the profile (space-separated list)
# Example: EXCLUDE_BUNDLES="entertainment creative"
EXCLUDE_BUNDLES="${EXCLUDE_BUNDLES:-}"

################################################################################
# LOGGING AND AUDIT
################################################################################

LOG_FILE="/var/log/mdm-dotfiles-deploy.log"

log_message() {
    local level="${2:-INFO}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $1" | tee -a "$LOG_FILE"
}

audit_log() {
    local event="$1"
    local detail="$2"
    log_message "[${ADMIN_USER}] [PID:$$] [${event}] ${detail}" "AUDIT"
    logger -t mdm-dotfiles -p auth.info "$event: $detail"
}

################################################################################
# PRE-FLIGHT CHECKS
################################################################################

log_message "========================================="
log_message "MDM Dotfiles Deployment Starting"
log_message "========================================="
audit_log "DEPLOY_START" "Beginning MDM deployment"

# Must run as root
if [[ $EUID -ne 0 ]]; then
   log_message "ERROR: This script must be run as root (via MDM)"
   audit_log "SECURITY_VIOLATION" "Script not run as root"
   exit 1
fi

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    log_message "ERROR: This script is designed for macOS only"
    exit 1
fi

# Verify admin user exists and is in admin group
if ! id "$ADMIN_USER" &>/dev/null; then
    log_message "ERROR: Admin user ${ADMIN_USER} does not exist"
    audit_log "SECURITY_VIOLATION" "Invalid admin user specified"
    exit 1
fi

if ! dseditgroup -o checkmember -m "${ADMIN_USER}" admin &>/dev/null; then
    log_message "ERROR: ${ADMIN_USER} is not in admin group"
    audit_log "SECURITY_VIOLATION" "User not in admin group"
    exit 1
fi

log_message "Admin user verified: ${ADMIN_USER}"
audit_log "ADMIN_VERIFIED" "Admin user ${ADMIN_USER} validated"

# Detect architecture
ARCH="$(uname -m)"
if [[ "${ARCH}" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
    log_message "Architecture: Apple Silicon (arm64)"
else
    BREW_PREFIX="/usr/local"
    log_message "Architecture: Intel (x86_64)"
fi

BREW_BIN="${BREW_PREFIX}/bin/brew"

################################################################################
# STEP 1: CLONE DOTFILES REPOSITORY
################################################################################

log_message "========================================="
log_message "Step 1: Cloning Dotfiles Repository"
log_message "========================================="

DOTFILES_DIR="/tmp/dotfiles-deploy"
FINAL_DOTFILES_DIR="/Users/${ADMIN_USER}/.dotfiles"

# Clean up any previous attempts
rm -rf "${DOTFILES_DIR}"

# Clone repository
log_message "Cloning ${DOTFILES_REPO} to ${DOTFILES_DIR}"
audit_log "REPO_CLONE_START" "Cloning dotfiles from ${DOTFILES_REPO}"

if git clone -b "${DOTFILES_BRANCH}" "${DOTFILES_REPO}" "${DOTFILES_DIR}" 2>&1 | tee -a "$LOG_FILE"; then
    log_message "✓ Repository cloned successfully"
    audit_log "REPO_CLONE_SUCCESS" "Dotfiles cloned to ${DOTFILES_DIR}"
else
    log_message "ERROR: Failed to clone repository"
    audit_log "REPO_CLONE_FAILURE" "Git clone failed"
    exit 1
fi

################################################################################
# STEP 2: CREATE TIME-LIMITED SUDO CONFIGURATION
################################################################################

log_message "========================================="
log_message "Step 2: Configuring Sudo Access"
log_message "========================================="

SUDOERS_FILE="/etc/sudoers.d/homebrew"
SUDOERS_CASK_FILE="/etc/sudoers.d/homebrew-cask-temp"

# Permanent sudoers for brew alias
cat > "${SUDOERS_FILE}.tmp" << EOF
# Allow all users to run brew commands as ${ADMIN_USER}
ALL ALL=(${ADMIN_USER}) NOPASSWD: ${BREW_BIN}
ALL ALL=(${ADMIN_USER}) NOPASSWD: ${BREW_BIN} *
EOF

chmod 0440 "${SUDOERS_FILE}.tmp"

if visudo -c -f "${SUDOERS_FILE}.tmp" > /dev/null 2>&1; then
    mv "${SUDOERS_FILE}.tmp" "${SUDOERS_FILE}"
    log_message "✓ Permanent brew sudoers created"
    audit_log "SUDOERS_PERMANENT" "Permanent brew alias configured"
else
    log_message "ERROR: Invalid sudoers syntax"
    rm -f "${SUDOERS_FILE}.tmp"
    exit 1
fi

# Temporary sudoers for cask installations
log_message "Creating temporary sudo for cask installations..."
audit_log "TEMP_SUDOERS_START" "Creating time-limited sudo"

cat > "${SUDOERS_CASK_FILE}.tmp" << EOF
# TEMPORARY SUDOERS - AUTO-EXPIRES IN 2 HOURS
# Created: $(date)
# Purpose: Passwordless sudo for cask installations
${ADMIN_USER} ALL=(root) NOPASSWD: /bin/mkdir -p /Applications/*
${ADMIN_USER} ALL=(root) NOPASSWD: /bin/cp -R * /Applications/*
${ADMIN_USER} ALL=(root) NOPASSWD: /bin/mv * /Applications/*
${ADMIN_USER} ALL=(root) NOPASSWD: /bin/chown -R * /Applications/*
${ADMIN_USER} ALL=(root) NOPASSWD: /bin/chmod * /Applications/*
${ADMIN_USER} ALL=(root) NOPASSWD: /usr/sbin/installer -pkg * -target /
${ADMIN_USER} ALL=(root) NOPASSWD: /usr/bin/ditto * /Applications/*
${ADMIN_USER} ALL=(root) NOPASSWD: /usr/sbin/pkgutil --expand * *
${ADMIN_USER} ALL=(root) NOPASSWD: /sbin/mount *
${ADMIN_USER} ALL=(root) NOPASSWD: /sbin/umount *
${ADMIN_USER} ALL=(root) NOPASSWD: /usr/bin/hdiutil attach *
${ADMIN_USER} ALL=(root) NOPASSWD: /usr/bin/hdiutil detach *
EOF

chmod 0440 "${SUDOERS_CASK_FILE}.tmp"

if visudo -c -f "${SUDOERS_CASK_FILE}.tmp" > /dev/null 2>&1; then
    mv "${SUDOERS_CASK_FILE}.tmp" "${SUDOERS_CASK_FILE}"
    log_message "✓ Temporary cask sudoers created (expires in 2 hours)"
    audit_log "TEMP_SUDOERS_SUCCESS" "Time-limited sudo active"

    # Schedule removal
    (sleep 7200 && rm -f "${SUDOERS_CASK_FILE}" && logger -t mdm-dotfiles "Temp sudoers removed") &
    log_message "Auto-removal scheduled (PID: $!)"
else
    log_message "ERROR: Invalid temp sudoers syntax"
    rm -f "${SUDOERS_CASK_FILE}.tmp"
fi

# Create brew alias script
ALIAS_SCRIPT="/etc/profile.d/brew-alias.sh"
mkdir -p /etc/profile.d

cat > "${ALIAS_SCRIPT}" << EOF
# Homebrew alias to run as ${ADMIN_USER}
alias brew='sudo -u ${ADMIN_USER} ${BREW_BIN}'
EOF

chmod 644 "${ALIAS_SCRIPT}"
log_message "✓ Brew alias configured"

################################################################################
# STEP 3: INSTALL HOMEBREW
################################################################################

log_message "========================================="
log_message "Step 3: Installing Homebrew"
log_message "========================================="

if [[ ! -f "${BREW_BIN}" ]]; then
    log_message "Installing Homebrew as ${ADMIN_USER}..."
    audit_log "HOMEBREW_INSTALL_START" "Beginning Homebrew installation"

    # Install as admin user, not root
    su - "${ADMIN_USER}" -c "NONINTERACTIVE=1 /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""

    log_message "✓ Homebrew installed at ${BREW_PREFIX}"
    audit_log "HOMEBREW_INSTALL_SUCCESS" "Homebrew installation complete"
else
    log_message "✓ Homebrew already installed"
    # Update existing installation
    su - "${ADMIN_USER}" -c "${BREW_BIN} update" 2>&1 | tee -a "$LOG_FILE"
fi

# Verify installation
if [[ ! -f "${BREW_BIN}" ]]; then
    log_message "ERROR: Homebrew installation failed"
    audit_log "HOMEBREW_INSTALL_FAILURE" "Installation failed"
    exit 1
fi

log_message "Homebrew version: $(su - "${ADMIN_USER}" -c "${BREW_BIN} --version" | head -n1)"

################################################################################
# STEP 4: INSTALL PACKAGES USING INSTALL-APPS.SH
################################################################################

log_message "========================================="
log_message "Step 4: Installing Packages"
log_message "========================================="

# Build install-apps.sh command arguments
INSTALL_APPS_SCRIPT="${DOTFILES_DIR}/scripts/install-apps.sh"
INSTALL_ARGS=""

# Check if install-apps.sh exists
if [[ ! -f "${INSTALL_APPS_SCRIPT}" ]]; then
    log_message "ERROR: install-apps.sh not found at ${INSTALL_APPS_SCRIPT}"
    exit 1
fi

# Make script executable
chmod +x "${INSTALL_APPS_SCRIPT}"

# Determine installation arguments
if [[ -n "${INSTALL_PROFILE}" ]]; then
    log_message "Using installation profile: ${INSTALL_PROFILE}"
    audit_log "INSTALL_PROFILE" "Profile: ${INSTALL_PROFILE}"
    INSTALL_ARGS="--profile ${INSTALL_PROFILE}"
elif [[ -n "${INSTALL_BUNDLES}" ]]; then
    log_message "Installing custom bundles: ${INSTALL_BUNDLES}"
    audit_log "INSTALL_BUNDLES" "Bundles: ${INSTALL_BUNDLES}"
    INSTALL_ARGS="--bundles \"${INSTALL_BUNDLES}\""
else
    # Default to everything profile
    log_message "No profile or bundles specified, defaulting to 'everything' profile"
    INSTALL_ARGS="--profile everything"
fi

# Add exclusions if specified
if [[ -n "${EXCLUDE_BUNDLES}" ]]; then
    log_message "Excluding bundles: ${EXCLUDE_BUNDLES}"
    audit_log "EXCLUDE_BUNDLES" "Excluding: ${EXCLUDE_BUNDLES}"
    INSTALL_ARGS="${INSTALL_ARGS} --exclude \"${EXCLUDE_BUNDLES}\""
fi

# Run install-apps.sh as the admin user with auto-confirm
log_message "Running install-apps.sh with arguments: ${INSTALL_ARGS}"
audit_log "BUNDLE_INSTALL_START" "Installing apps via install-apps.sh"

# Run as admin user and auto-confirm installation
su - "${ADMIN_USER}" -c "
    cd ${DOTFILES_DIR}
    export HOMEBREW_NO_AUTO_UPDATE=1
    export HOMEBREW_NO_INSTALL_FROM_API=1
    export NONINTERACTIVE=1
    echo 'y' | ${INSTALL_APPS_SCRIPT} ${INSTALL_ARGS}
" 2>&1 | tee -a "$LOG_FILE"

if [[ $? -eq 0 ]]; then
    log_message "✓ All packages installed successfully"
    audit_log "BUNDLE_INSTALL_SUCCESS" "All bundles installed"
else
    log_message "ERROR: Package installation failed"
    audit_log "BUNDLE_INSTALL_FAILURE" "Installation failed"
    exit 1
fi

################################################################################
# STEP 5: DEPLOY DOTFILES TO USERS
################################################################################

log_message "========================================="
log_message "Step 5: Deploying Dotfiles to Users"
log_message "========================================="

# Move dotfiles to admin's home directory
log_message "Moving dotfiles to ${FINAL_DOTFILES_DIR}..."
rm -rf "${FINAL_DOTFILES_DIR}"
mv "${DOTFILES_DIR}" "${FINAL_DOTFILES_DIR}"
chown -R "${ADMIN_USER}:staff" "${FINAL_DOTFILES_DIR}"
log_message "✓ Dotfiles moved to admin home"

deploy_dotfiles_for_user() {
    local user="$1"
    local user_home
    user_home=$(eval echo "~${user}")
    local user_dotfiles="${user_home}/.dotfiles"

    log_message "Deploying dotfiles for ${user}..."

    # Copy dotfiles to user's home
    if [[ ! -d "${user_dotfiles}" ]]; then
        cp -R "${FINAL_DOTFILES_DIR}" "${user_dotfiles}"
        chown -R "${user}:staff" "${user_dotfiles}"
        log_message "✓ Dotfiles copied to ${user_dotfiles}"
    fi

    # Create symlinks for config files
    local configs=(".zshrc" ".bashrc" ".bash_profile" ".gitconfig")
    for config in "${configs[@]}"; do
        local target="${user_home}/${config}"
        local source="${user_dotfiles}/config/${config}"

        if [[ -f "${source}" ]]; then
            # Backup existing file
            if [[ -f "${target}" ]] && [[ ! -L "${target}" ]]; then
                mv "${target}" "${target}.backup"
                log_message "  Backed up existing ${config}"
            fi

            # Create symlink
            ln -sf "${source}" "${target}"
            chown -h "${user}:staff" "${target}"
            log_message "  ✓ Linked ${config}"
        fi
    done

    # Set up SSH config for macOS keychain integration
    if [[ -f "${user_dotfiles}/config/ssh_config" ]]; then
        local ssh_dir="${user_home}/.ssh"
        local ssh_config="${ssh_dir}/config"

        # Create .ssh directory if it doesn't exist
        mkdir -p "${ssh_dir}"
        chmod 700 "${ssh_dir}"
        chown "${user}:staff" "${ssh_dir}"

        # Create sockets directory for SSH connection sharing
        mkdir -p "${ssh_dir}/sockets"
        chmod 700 "${ssh_dir}/sockets"
        chown "${user}:staff" "${ssh_dir}/sockets"

        # Backup existing SSH config
        if [[ -f "${ssh_config}" ]] && [[ ! -L "${ssh_config}" ]]; then
            mv "${ssh_config}" "${ssh_config}.backup"
            log_message "  Backed up existing SSH config"
        fi

        # Link SSH config
        ln -sf "${user_dotfiles}/config/ssh_config" "${ssh_config}"
        chmod 600 "${ssh_config}"
        chown -h "${user}:staff" "${ssh_config}"
        log_message "  ✓ Linked SSH config (macOS keychain integration enabled)"
    fi

    # Create Go src directory structure
    local src_dir="${user_home}/src"
    local github_dir="${src_dir}/github.com"

    if [[ ! -d "${github_dir}" ]]; then
        mkdir -p "${github_dir}"
        chown -R "${user}:staff" "${src_dir}"
        log_message "  ✓ Created ~/src/github.com directory"
    fi

    # Deploy Starship config (installed via Brewfile)
    if [[ -f "${user_dotfiles}/config/starship.toml" ]]; then
        local starship_config_dir="${user_home}/.config"
        mkdir -p "${starship_config_dir}"
        chown "${user}:staff" "${starship_config_dir}"

        ln -sf "${user_dotfiles}/config/starship.toml" "${starship_config_dir}/starship.toml"
        chown -h "${user}:staff" "${starship_config_dir}/starship.toml"
        log_message "  ✓ Linked starship.toml"
    fi

    log_message "✓ Dotfiles deployed for ${user}"
}

# Deploy to admin user
deploy_dotfiles_for_user "${ADMIN_USER}"

# Deploy to all other users if enabled
if [[ "$DEPLOY_TO_ALL_USERS" == true ]]; then
    log_message "Deploying to all users..."

    # Get list of all users (excluding system users)
    for user_home in /Users/*; do
        if [[ -d "${user_home}" ]]; then
            user=$(basename "${user_home}")

            # Skip system users and admin (already done)
            if [[ "${user}" != "Shared" ]] && \
               [[ "${user}" != "Guest" ]] && \
               [[ "${user}" != "${ADMIN_USER}" ]] && \
               [[ $(id -u "${user}" 2>/dev/null || echo 0) -ge 501 ]]; then
                deploy_dotfiles_for_user "${user}"
            fi
        fi
    done
fi

audit_log "DOTFILES_DEPLOYED" "Dotfiles deployed to all users"

################################################################################
# STEP 6: INSTALL VS CODE CLI INTEGRATION
################################################################################

log_message "========================================="
log_message "Step 6: Installing VS Code CLI Integration"
log_message "========================================="

# Check if VS Code is installed
VSCODE_PATH="/Applications/Visual Studio Code.app"
if [[ -d "${VSCODE_PATH}" ]]; then
    log_message "Installing VS Code 'code' command..."

    # Create symlink for code command
    VSCODE_BIN="${VSCODE_PATH}/Contents/Resources/app/bin/code"
    if [[ -f "${VSCODE_BIN}" ]]; then
        # Create symlink in Homebrew bin (accessible to all users)
        ln -sf "${VSCODE_BIN}" "${BREW_PREFIX}/bin/code"
        log_message "✓ VS Code CLI installed: code"
        audit_log "VSCODE_CLI_INSTALLED" "VS Code CLI integration installed"
    else
        log_message "WARNING: VS Code binary not found at expected location"
    fi
else
    log_message "VS Code not yet installed - CLI will be available after package installation"
fi

################################################################################
# STEP 7: CLEANUP
################################################################################

log_message "========================================="
log_message "Step 7: Cleanup"
log_message "========================================="

# Clean Homebrew cache
su - "${ADMIN_USER}" -c "${BREW_BIN} cleanup" 2>&1 | tee -a "$LOG_FILE"
log_message "✓ Homebrew cache cleaned"

################################################################################
# COMPLETION
################################################################################

log_message "========================================="
log_message "Deployment Complete!"
log_message "========================================="
log_message ""
log_message "Summary:"
log_message "  Admin user: ${ADMIN_USER}"
log_message "  Dotfiles location: ${FINAL_DOTFILES_DIR}"
log_message "  Homebrew: ${BREW_BIN}"
log_message "  Profile/Bundles: ${INSTALL_PROFILE:-${INSTALL_BUNDLES}}"
log_message "  Deployment mode: $([ "$DEPLOY_TO_ALL_USERS" == true ] && echo "All users" || echo "Admin only")"
log_message "  VS Code CLI: Installed"
log_message "  SSH Agent: macOS Keychain integrated"
log_message "  Go Workspace: ~/src/github.com created"
log_message ""
log_message "Configuration via bundle scripts:"
log_message "  • Shell (eza aliases, Starship): base.sh"
log_message "  • Ghostty terminal: base.sh"
log_message "  • Custom tools: av-studio.sh (if installed)"
log_message ""
log_message "Log file: ${LOG_FILE}"
log_message "Note: Temporary sudo expires in 2 hours"
log_message ""

audit_log "DEPLOY_COMPLETE" "MDM deployment finished successfully"

exit 0
