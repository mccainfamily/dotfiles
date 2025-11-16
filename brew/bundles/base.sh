#!/bin/bash

################################################################################
# Base Bundle Custom Setup
#
# Configures essential tools and sets up shell customizations
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
# Setup eza alias
################################################################################

setup_eza_alias() {
    log_info "Setting up eza alias for ls..."

    # Zsh configuration
    ZSHRC="${HOME}/.zshrc"
    if [[ -f "${ZSHRC}" ]]; then
        if grep -q "alias ls=" "${ZSHRC}"; then
            log_warning "ls alias already exists in ~/.zshrc"
        else
            cat >> "${ZSHRC}" << 'EOF'

# eza aliases (modern ls replacement)
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'
EOF
            log_success "Added eza aliases to ~/.zshrc"
        fi
    else
        log_warning "${HOME}/.zshrc not found, creating with eza aliases..."
        cat > "${ZSHRC}" << 'EOF'
# eza aliases (modern ls replacement)
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'
EOF
        log_success "Created ~/.zshrc with eza aliases"
    fi

    # Bash configuration
    BASHRC="${HOME}/.bashrc"
    if [[ -f "${BASHRC}" ]]; then
        if grep -q "alias ls=" "${BASHRC}"; then
            log_warning "ls alias already exists in ~/.bashrc"
        else
            cat >> "${BASHRC}" << 'EOF'

# eza aliases (modern ls replacement)
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'
EOF
            log_success "Added eza aliases to ~/.bashrc"
        fi
    fi
}

################################################################################
# Setup Starship
################################################################################

setup_starship() {
    log_info "Setting up Starship prompt..."

    # Check if Starship config exists
    STARSHIP_CONFIG="${HOME}/.config/starship.toml"

    if [[ -f "${STARSHIP_CONFIG}" ]]; then
        log_success "Starship config already exists at ${STARSHIP_CONFIG}"
    else
        log_info "Starship config not found - may need to be copied from dotfiles"
    fi

    # Add Starship init to zshrc if not already present
    ZSHRC="${HOME}/.zshrc"
    if [[ -f "${ZSHRC}" ]]; then
        if grep -q "starship init" "${ZSHRC}"; then
            log_success "Starship is already initialized in ~/.zshrc"
        else
            cat >> "${ZSHRC}" << 'EOF'

# Initialize Starship prompt
eval "$(starship init zsh)"
EOF
            log_success "Added Starship initialization to ~/.zshrc"
        fi
    else
        log_warning "${HOME}/.zshrc not found - Starship initialization may need manual setup"
    fi

    # Add Starship init to bashrc if it exists
    BASHRC="${HOME}/.bashrc"
    if [[ -f "${BASHRC}" ]]; then
        if grep -q "starship init" "${BASHRC}"; then
            log_success "Starship is already initialized in ~/.bashrc"
        else
            cat >> "${BASHRC}" << 'EOF'

# Initialize Starship prompt
eval "$(starship init bash)"
EOF
            log_success "Added Starship initialization to ~/.bashrc"
        fi
    fi
}

################################################################################
# Setup Ghostty Terminal
################################################################################

setup_ghostty() {
    log_info "Setting up Ghostty terminal configuration..."

    local ghostty_config_dir="${HOME}/.config/ghostty"

    # Create config directory
    mkdir -p "${ghostty_config_dir}"

    # Check if config already exists
    if [[ -f "${ghostty_config_dir}/config" ]]; then
        log_warning "Ghostty config already exists at ${ghostty_config_dir}/config"
        log_info "Skipping Ghostty configuration to preserve existing settings"
        return 0
    fi

    # Create Ghostty config
    cat > "${ghostty_config_dir}/config" << 'EOF'
# Ghostty Terminal Configuration - Developer Optimized

# Font Configuration
font-family = "JetBrains Mono"
font-size = 13
font-feature = -calt

# Theme - One Dark Pro
background = #282c34
foreground = #abb2bf
cursor-color = #528bff
selection-background = #3e4451

# Colors (One Dark Pro)
palette = 0=#282c34
palette = 1=#e06c75
palette = 2=#98c379
palette = 3=#e5c07b
palette = 4=#61afef
palette = 5=#c678dd
palette = 6=#56b6c2
palette = 7=#abb2bf
palette = 8=#5c6370
palette = 9=#e06c75
palette = 10=#98c379
palette = 11=#e5c07b
palette = 12=#61afef
palette = 13=#c678dd
palette = 14=#56b6c2
palette = 15=#ffffff

# Window Configuration
window-padding-x = 10
window-padding-y = 10
window-decoration = true
macos-titlebar-style = transparent

# Performance
macos-option-as-alt = true

# Shell Integration
shell-integration = detect
shell-integration-features = cursor,sudo,title

# Keybindings (macOS optimized)
keybind = cmd+t=new_tab
keybind = cmd+w=close_surface
keybind = cmd+shift+[=previous_tab
keybind = cmd+shift+]=next_tab
keybind = cmd+plus=increase_font_size:1
keybind = cmd+minus=decrease_font_size:1
keybind = cmd+0=reset_font_size

# Copy/Paste
clipboard-read = allow
clipboard-write = allow
copy-on-select = true

# Mouse
mouse-hide-while-typing = true

# Miscellaneous
confirm-close-surface = false
quit-after-last-window-closed = false
EOF

    log_success "Ghostty configuration created at ${ghostty_config_dir}/config"
}

################################################################################
# Main
################################################################################

main() {
    log_info "Running base bundle custom setup..."
    echo

    setup_eza_alias
    echo

    setup_starship
    echo

    setup_ghostty
    echo

    log_success "Base bundle custom setup complete"
    log_info "Please restart your shell or run: source ~/.zshrc"
}

main "$@"
