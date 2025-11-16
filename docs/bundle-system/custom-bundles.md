# Custom Modules

Learn how to create your own custom modules to extend the dotfiles system with your specific tools and configurations.

## Overview

Custom modules follow the same structure as built-in modules. Each module can have up to three file types that are all installed automatically when the module is specified.

## Module File Types

### Brewfile (`<module>.Brewfile`)

Contains Homebrew formulas (CLI tools) and casks (GUI applications).

**Syntax:**

```ruby
# My Custom Module
# Description of what this module provides

brew "package-name"      # CLI tool
cask "application-name"  # GUI application
```

### Appfile (`<module>.Appfile`)

Contains Mac App Store applications.

**Syntax:**

```ruby
# My Custom Module - App Store Apps

mas "App Name", id: 123456789
```

**Finding App IDs:**

```bash
# Search for an app
mas search "App Name"

# Example output:
#   123456789  App Name (Version)
```

### Custom Script (`<module>.sh`)

Shell script for custom setup, configuration, or installations that can't be done via Homebrew or App Store.

**Syntax:**

```bash
#!/bin/bash
# Custom setup for my-module

echo "Running custom setup..."
# Your custom commands here
```

**Important:** Make the script executable:

```bash
chmod +x brew/bundles/<module>.sh
```

## Creating a Custom Module

### Step 1: Plan Your Module

Decide what your module should include:

- What tools do you need?
- Are they available via Homebrew, App Store, or require custom installation?
- What configuration is needed?

### Step 2: Create Module Files

Create only the file types you need. A module can have 1, 2, or all 3 file types.

#### Example: Data Science Module

**File:** `brew/bundles/data-science.Brewfile`

```ruby
# Data Science Module
# Tools for data analysis and machine learning

# ========================================
# Python Data Science Stack
# ========================================

brew "python@3.11"        # Python 3.11
brew "jupyter"            # Jupyter notebooks
brew "numpy"              # Numerical computing
brew "pandas"             # Data manipulation
brew "scipy"              # Scientific computing

# ========================================
# Data Visualization
# ========================================

brew "plotly"             # Interactive plots
brew "matplotlib"         # Plotting library

# ========================================
# Machine Learning
# ========================================

brew "tensorflow"         # ML framework
brew "scikit-learn"       # ML library

# ========================================
# GUI Applications
# ========================================

cask "rstudio"            # R IDE
cask "tableau-public"     # Data visualization
```

**File:** `brew/bundles/data-science.sh`

```bash
#!/bin/bash
# Data Science Module - Custom Setup

echo "Setting up Python data science environment..."

# Install Python packages not available via Homebrew
pip3 install --user \
    seaborn \
    statsmodels \
    xgboost \
    lightgbm

# Create Jupyter config directory
mkdir -p ~/.jupyter

# Generate Jupyter config if it doesn't exist
if [[ ! -f ~/.jupyter/jupyter_notebook_config.py ]]; then
    jupyter notebook --generate-config
    echo "✓ Jupyter config generated"
fi

echo "✓ Data science environment configured"
```

Don't forget to make it executable:

```bash
chmod +x brew/bundles/data-science.sh
```

### Step 3: Test Your Module

Test the module locally before using it in a profile:

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --bundles "data-science"
```

### Step 4: Add to a Profile (Optional)

If you want this module in a profile, edit `brew/profiles/profiles.conf`:

```bash
# Data Scientist Profile
PROFILE_DATA_SCIENTIST="base development data-science diagrams"
```

## Module Best Practices

### 1. Use Descriptive Names

Choose clear, descriptive module names:

- ✅ `data-science`, `web-dev`, `mobile-dev`
- ❌ `tools`, `myApps`, `stuff`

### 2. Add Documentation Comments

Start each file with a comment block explaining what it contains:

```ruby
# Web Development Module
# Modern web development tools and frameworks
#
# Includes:
# - Node.js and npm
# - Modern browsers
# - Web development IDEs
# - API testing tools
```

### 3. Organize with Sections

Use comment sections to group related items:

```ruby
# ========================================
# JavaScript Runtime & Package Managers
# ========================================

brew "node"
brew "yarn"
brew "pnpm"

# ========================================
# Build Tools
# ========================================

brew "webpack"
brew "vite"
```

### 4. Handle Errors Gracefully

In custom scripts, check for errors and provide helpful messages:

```bash
#!/bin/bash
# Custom Module Setup

set -e  # Exit on error

echo "Installing custom packages..."

if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed"
    exit 1
fi

pip3 install --user package-name || {
    echo "Warning: Failed to install package-name"
    # Continue anyway
}

echo "✓ Setup complete"
```

### 5. Make Scripts Idempotent

Ensure scripts can be run multiple times safely:

```bash
# Check if already configured
if [[ -f ~/.config/myapp/config.yml ]]; then
    echo "Already configured, skipping..."
    exit 0
fi

# Create config
mkdir -p ~/.config/myapp
cp config-template.yml ~/.config/myapp/config.yml
```

### 6. Document Dependencies

If your module requires other modules, document it:

```ruby
# Cloud Development Module
# REQUIRES: base, development
#
# Cloud development tools for AWS, GCP, and Azure
```

## Real-World Examples

### Example 1: iOS Development

**File:** `brew/bundles/ios-dev.Brewfile`

```ruby
# iOS Development Module
# Tools for iOS and macOS app development

cask "xcode"              # Apple's IDE
brew "cocoapods"          # Dependency manager
brew "fastlane"           # Automation tool
brew "swiftlint"          # Swift linter
brew "swiftformat"        # Swift formatter
cask "sf-symbols"         # Apple's icon library
cask "proxyman"           # HTTP debugging
```

### Example 2: DevOps Tools

**File:** `brew/bundles/devops.Brewfile`

```ruby
# DevOps Module
# CI/CD and automation tools

brew "jenkins"            # CI server
brew "gitlab-runner"      # GitLab CI runner
brew "circleci"           # CircleCI CLI
brew "gh-actions"         # GitHub Actions CLI
brew "act"                # Run GitHub Actions locally
brew "pre-commit"         # Git hook framework
```

**File:** `brew/bundles/devops.sh`

```bash
#!/bin/bash
# DevOps Module - Setup

echo "Configuring DevOps tools..."

# Setup pre-commit hooks
if [[ -f .pre-commit-config.yaml ]]; then
    pre-commit install
    echo "✓ Pre-commit hooks installed"
fi

echo "✓ DevOps environment configured"
```

### Example 3: Photography & Media

**File:** `brew/bundles/photography.Brewfile`

```ruby
# Photography Module
# Photo editing and management tools

cask "adobe-creative-cloud"  # Adobe suite
cask "capture-one"           # RAW processor
cask "darktable"             # Open-source RAW editor
cask "gimp"                  # Image editor
brew "imagemagick"           # Image manipulation CLI
brew "exiftool"              # Metadata tool
```

**File:** `brew/bundles/photography.Appfile`

```ruby
# Photography Module - App Store

mas "Pixelmator Pro", id: 1289583905      # Image editor
mas "Affinity Photo", id: 824183456       # Photo editing
mas "Lightroom", id: 1451544217           # Adobe Lightroom
```

## Managing Custom Modules

### Listing Your Modules

View all modules including custom ones:

```bash
./scripts/install-apps.sh --list-bundles
```

### Testing Modules

Test individual modules:

```bash
# Test just the Brewfile
brew bundle check --file=brew/bundles/my-module.Brewfile

# Test just the Appfile
brew bundle check --file=brew/bundles/my-module.Appfile

# Test the custom script
bash -n brew/bundles/my-module.sh  # Syntax check
bash brew/bundles/my-module.sh     # Run it
```

### Sharing Modules

To share your custom module:

1. Create a pull request to the main repository
2. Share the individual files
3. Document the module in this guide

## Troubleshooting

### Module Not Found

If your module isn't recognized:

```bash
# Check file naming
ls -la brew/bundles/my-module.*

# Verify no typos in the name
./scripts/install-apps.sh --list-bundles | grep my-module
```

### Script Won't Execute

If your custom script fails:

```bash
# Check permissions
ls -l brew/bundles/my-module.sh

# Make executable
chmod +x brew/bundles/my-module.sh

# Check for syntax errors
bash -n brew/bundles/my-module.sh

# Run with debugging
bash -x brew/bundles/my-module.sh
```

### Homebrew Package Not Found

If a package isn't found:

```bash
# Search for the correct name
brew search package-name

# Check if it's a cask
brew search --cask app-name

# Update Homebrew
brew update
```

## Next Steps

- Review [Available Modules](bundles.md) for examples
- Learn about [Profiles](profiles.md) to group your custom modules
- Check the [Troubleshooting Guide](../troubleshooting.md)
