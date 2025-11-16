#!/bin/bash

################################################################################
# Python Setup Script
# Installs common Python versions using pyenv and sets up development tools
################################################################################

set -e

echo "========================================="
echo "Python Development Environment Setup"
echo "========================================="
echo ""

# Check if pyenv is installed
if ! command -v pyenv &> /dev/null; then
    echo "Error: pyenv is not installed"
    echo "Please install pyenv first: brew install pyenv pyenv-virtualenv"
    exit 1
fi

# Initialize pyenv in current shell
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Python versions to install
PYTHON_VERSIONS=(
    "3.11"      # Latest stable 3.11.x
    "3.12"      # Latest stable 3.12.x
)

DEFAULT_VERSION="3.12"

echo "This script will install the following Python versions:"
for version in "${PYTHON_VERSIONS[@]}"; do
    echo "  - Python $version (latest patch version)"
done
echo ""
echo "Default global version: $DEFAULT_VERSION"
echo ""

read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled"
    exit 0
fi

echo ""
echo "========================================="
echo "Installing Python Versions"
echo "========================================="
echo ""

# Update pyenv
echo "Updating pyenv..."
brew upgrade pyenv pyenv-virtualenv 2>/dev/null || true

# Install Python versions
for version in "${PYTHON_VERSIONS[@]}"; do
    echo ""
    echo "Installing Python $version..."

    # Get the latest patch version available
    latest_patch=$(pyenv install --list | grep -E "^\s*${version}\.[0-9]+$" | tail -1 | xargs)

    if [[ -z "$latest_patch" ]]; then
        echo "Warning: Could not find Python $version, skipping..."
        continue
    fi

    echo "Latest available version: $latest_patch"

    # Check if already installed
    if pyenv versions --bare | grep -q "^${latest_patch}$"; then
        echo "✓ Python $latest_patch is already installed"
    else
        echo "Installing Python $latest_patch..."
        pyenv install "$latest_patch"
        echo "✓ Python $latest_patch installed"
    fi
done

echo ""
echo "========================================="
echo "Setting Global Python Version"
echo "========================================="
echo ""

# Get the latest patch version for the default
default_patch=$(pyenv install --list | grep -E "^\s*${DEFAULT_VERSION}\.[0-9]+$" | tail -1 | xargs)

if [[ -n "$default_patch" ]]; then
    echo "Setting global Python version to $default_patch..."
    pyenv global "$default_patch"
    echo "✓ Global Python version set"
else
    echo "Warning: Could not set global version"
fi

echo ""
echo "========================================="
echo "Installing Common Python Tools"
echo "========================================="
echo ""

# Install common development tools globally
echo "Installing common Python development tools..."

pip install --upgrade pip setuptools wheel

COMMON_TOOLS=(
    "pipx"              # Install Python applications in isolated environments
    "poetry"            # Dependency management and packaging
    "black"             # Code formatter
    "ruff"              # Fast Python linter
    "mypy"              # Static type checker
    "pytest"            # Testing framework
    "ipython"           # Enhanced interactive Python shell
    "virtualenv"        # Virtual environment tool
)

for tool in "${COMMON_TOOLS[@]}"; do
    echo "Installing $tool..."
    pip install --upgrade "$tool"
done

echo ""
echo "✓ Common Python tools installed"

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Installed Python versions:"
pyenv versions
echo ""
echo "Current Python version:"
python --version
echo ""
echo "Installed tools:"
echo "  - pip (Python package installer)"
echo "  - pipx (Install Python applications)"
echo "  - poetry (Dependency management)"
echo "  - black (Code formatter)"
echo "  - ruff (Fast linter)"
echo "  - mypy (Type checker)"
echo "  - pytest (Testing framework)"
echo "  - ipython (Enhanced REPL)"
echo ""
echo "Usage tips:"
echo "  - List available Python versions: pyenv install --list"
echo "  - Install a specific version: pyenv install 3.11.5"
echo "  - Set global version: pyenv global 3.11.5"
echo "  - Set local version: pyenv local 3.11.5"
echo "  - Create virtualenv: pyenv virtualenv 3.11.5 myproject"
echo "  - Activate virtualenv: pyenv activate myproject"
echo "  - Use poetry: poetry new myproject"
echo ""
echo "Restart your shell or run: exec \$SHELL"
echo ""
