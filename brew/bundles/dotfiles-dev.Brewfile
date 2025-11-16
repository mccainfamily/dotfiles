# Dotfiles Development Bundle
# Development dependencies for editing and contributing to this dotfiles repository

# ========================================
# Pre-commit Framework
# ========================================

brew "pre-commit"           # Git hooks framework for code quality

# ========================================
# Linting & Validation Tools
# ========================================

brew "shellcheck"           # Shell script linter
brew "markdownlint-cli"     # Markdown linter
brew "yamllint"             # YAML linter
brew "detect-secrets"       # Prevents committing secrets

# ========================================
# Development Utilities
# ========================================

brew "git"                  # Version control (if not already installed)
brew "gh"                   # GitHub CLI (if not already installed)

# Note: This bundle contains all tools needed to develop on the dotfiles repository:
#   - pre-commit: Manages git hooks for automatic validation
#   - shellcheck: Lints shell scripts for common issues
#   - markdownlint-cli: Ensures consistent markdown formatting
#   - yamllint: Validates YAML syntax
#   - detect-secrets: Scans for accidentally committed credentials
#
# To install this bundle:
#   bash scripts/install-apps.sh --bundles "dotfiles-dev"
#
# After installation, initialize the development environment:
#   make init
