# Dotfiles Documentation

Welcome to the comprehensive documentation for the modular dotfiles system.

## Overview

This is a **modular, bundle-based development environment** for macOS. Features a flexible bundle system for customized installations suitable for individuals and enterprise deployments.

### Key Features

✨ **12 Specialized Modules** - Packages organized by purpose with unified naming
📦 **5 Pre-defined Profiles** - Ready-to-use configurations
🚀 **Two Installation Methods** - Individual user or MDM deployment
🔒 **Idempotent** - Safe to run multiple times
⚡ **Fast & Efficient** - Install only what you need
🔄 **Auto-updating** - Git pull on re-run
🎯 **Multi-type Modules** - Each module can include Homebrew, App Store, and custom scripts  

## Two Installation Methods

### Method 1: Individual User Installation

For personal machines and individual developers:

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash
```

- User-owned Homebrew
- Clones to `~/.dotfiles`
- Idempotent and safe
- [Full Guide →](getting-started/installation.md)

### Method 2: MDM Deployment

For enterprise environments and IT-managed fleets:

```bash
#!/bin/bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/mdm-deploy.sh -o /tmp/mdm-deploy.sh
chmod +x /tmp/mdm-deploy.sh
/tmp/mdm-deploy.sh 2>&1 | tee /var/log/mdm-dotfiles-deploy.log
rm /tmp/mdm-deploy.sh
```

- Centralized Homebrew
- Multi-user deployment
- Audit logging
- [Full Guide →](deployment/mdm.md)

## Available Modules

Each module has a single name and can include multiple file types:

- `.Brewfile` - Homebrew formulas and casks
- `.Appfile` - Mac App Store applications
- `.sh` - Custom installation scripts

| Module | Files | Description | Package Count |
|--------|-------|-------------|---------------|
| **base** | Brewfile, Script | Essential tools, shell, fonts | ~40 packages |
| **network-security** | Brewfile | Network scanning, diagnostics, VPN | ~40 packages |
| **cloud-infrastructure** | Brewfile | AWS, K8s, Terraform, IaC | ~20 packages |
| **development** | Brewfile, Appfile | Languages, IDEs, dev tools | ~20 packages |
| **security-privacy** | Brewfile | Encryption, secure comms | ~25 packages |
| **diagrams** | Brewfile | PlantUML, Mermaid, Graphviz | ~8 packages |
| **monitoring** | Brewfile, Appfile | Prometheus, Grafana, AvertX | ~5 packages |
| **creative** | Brewfile, Appfile | Logic Pro, OmniGraffle | ~3 packages |
| **av-studio** | Brewfile, Appfile, Script | OBS, Final Cut Pro, NDI, X32 | ~15 packages |
| **communication** | Brewfile | Zoom, Teams, Slack, Discord | ~5 packages |
| **entertainment** | Brewfile, Appfile | Games, music, djay Pro, VirtualDJ | ~5 packages |
| **work** | Brewfile | FortiClient VPN | ~3 packages |

[See all modules →](bundle-system/bundles.md)

## Documentation Structure

This documentation is organized into the following sections:

### 📚 [Getting Started](getting-started/README.md)

Installation and initial setup guides

### 📦 [Bundle System](bundle-system/README.md)

Understanding and using bundles and profiles

### 🚀 [Deployment](deployment/README.md)

Individual and MDM deployment options

### ⚙️ [Configuration](configuration/README.md)

Customizing your environment

### 📖 [Reference](reference/quick-reference.md)

Command reference, package lists, and environment variables

### 🔧 [Troubleshooting](troubleshooting.md)

Common issues and solutions

## Common Tasks

### Install with Profile

```bash
# Individual user
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile creative

# Or after cloning
cd ~/.dotfiles
./scripts/install-apps.sh --profile work
```

### Install Specific Bundles

```bash
./scripts/install-apps.sh --bundles "base development communication"
```

### Update Everything

```bash
# Re-run installation (pulls latest changes)
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash

# Or update packages only
brew update && brew upgrade
```

### List Available Options

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --list-profiles
./scripts/install-apps.sh --list-bundles
```

## Requirements

- macOS 11+ (Big Sur or later)
- Internet connection
- Admin access (for MDM) or user account (for individual install)

## Support

- **Documentation**: You're reading it!
- **Troubleshooting**: Check the [Troubleshooting Guide](troubleshooting.md)
- **Quick Reference**: See [Quick Reference](reference/quick-reference.md)
- **Issues**: Report problems on GitHub

## License

MIT License - See LICENSE for details.

---

Built with ❤️ for network engineers and cloud infrastructure professionals
