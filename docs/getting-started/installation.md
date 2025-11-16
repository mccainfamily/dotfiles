# Installation

There are two primary installation methods depending on your deployment scenario.

## Prerequisites

- macOS 11+ (Big Sur or later)
- Internet connection
- Admin access (for MDM deployment) OR user account (for personal installation)

## Method 1: Individual User Installation

**Best for:** Personal machines, individual developers, manual setup

### One-Line Installation

The quickest way to get started:

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash
```

This installs the `everything` profile by default.

### Custom Profile Installation

Install with a specific profile:

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile creative
```

### Custom Bundles Installation

Pick specific bundles:

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --bundles "base development"
```

### What user-install.sh Does

1. **Clones Repository** - Clones dotfiles to `~/.dotfiles` (or updates if exists)
2. **Installs Homebrew** - Installs in user's home directory (`/opt/homebrew` or `/usr/local`)
3. **Installs Packages** - Installs selected bundles via `install-apps.sh`
4. **Deploys Configs** - Symlinks shell configs, SSH config, Starship config
5. **Configures Shell** - Sets up eza aliases, Starship prompt, Ghostty terminal (via base.sh)
6. **Sets up VS Code CLI** - Links `code` command if VS Code is installed

### Characteristics

- ✅ Idempotent - Safe to run multiple times
- ✅ Non-destructive - Backs up existing configs with timestamps
- ✅ User-owned - Homebrew installed in user account
- ✅ Updates automatically - Re-running pulls latest changes

## Method 2: MDM Deployment

**Best for:** Enterprise environments, IT management, fleet deployment

### Quick Start

Deploy via MDM (e.g., Jamf, Kandji, ScaleFusion):

```bash
#!/bin/bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/mdm-deploy.sh -o /tmp/mdm-deploy.sh
chmod +x /tmp/mdm-deploy.sh
/tmp/mdm-deploy.sh 2>&1 | tee /var/log/mdm-dotfiles-deploy.log
rm /tmp/mdm-deploy.sh
```

### Configuration

Configure via environment variables before deployment:

```bash
export DOTFILES_REPO="https://github.com/YOUR_ORG/dotfiles.git"
export DOTFILES_BRANCH="main"
export ADMIN_USER="admin"
export INSTALL_PROFILE="everything"
```

### What mdm-deploy.sh Does

1. **Clones Repository** - As root to `/var/root/.dotfiles`
2. **Installs Homebrew** - Centralized installation owned by admin user
3. **Installs Packages** - Runs `install-apps.sh` with specified profile
4. **Deploys to All Users** - Copies configs to admin and all existing users
5. **Audit Logging** - Full logging to `/var/log/mdm-dotfiles-deploy.log`

### Characteristics

- ✅ Enterprise-ready - Designed for MDM systems
- ✅ Multi-user - Deploys to all users on the system
- ✅ Centralized Homebrew - Single installation for all users
- ✅ Configurable - Environment variables for customization
- ✅ Audit trail - Complete deployment logs

See [MDM Deployment Guide](../deployment/mdm.md) for complete details.

## Choosing Your Method

| Scenario | Recommended Method |
|----------|-------------------|
| Personal Mac | Individual User Installation |
| Developer laptop | Individual User Installation |
| Company fleet | MDM Deployment |
| Lab/shared machines | MDM Deployment |
| Testing/experimentation | Individual User Installation |

## Installation Time

Varies based on bundle selection:

- **base profile**: ~5-10 minutes
- **creative/work profiles**: ~15-20 minutes
- **everything profile**: ~30-45 minutes

Factors affecting time:

- Internet connection speed
- Mac performance (Apple Silicon is faster)
- Number of packages in selected bundles

## Post-Installation

### Restart Your Shell

```bash
source ~/.zshrc
# OR
exec zsh
```

### Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Verify Installation

```bash
# Check Homebrew
brew --version

# Check Starship
starship --version

# List installed packages
brew list

# Check bundle system
cd ~/.dotfiles
./scripts/install-apps.sh --list-profiles
```

## Next Steps

- [First Steps](first-steps.md) - Post-installation configuration
- [Bundle System](../bundle-system/README.md) - Understanding bundles and profiles
- [Troubleshooting](../troubleshooting.md) - Common issues and solutions
