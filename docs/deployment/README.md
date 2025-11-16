# Deployment Options

Overview of the two primary installation methods for dotfiles.

## Two Installation Methods

This dotfiles system supports two distinct deployment approaches:

### 1. Individual User Installation (`user-install.sh`)

**Best for:**

- Personal machines
- Individual developers
- Manual setup
- Testing and experimentation

**Characteristics:**

- User-owned Homebrew installation
- Clones to `~/.dotfiles`
- Single-user configuration
- Idempotent and safe

[Read the complete guide →](manual.md)

### 2. MDM Deployment (`mdm-deploy.sh`)

**Best for:**

- Enterprise environments
- IT-managed fleets
- Multi-user systems
- Standardized configurations

**Characteristics:**

- Centralized Homebrew installation
- Deploys to all system users
- Audit logging
- Environment variable configuration

[Read the complete guide →](mdm.md)

## Quick Comparison

| Feature | Individual User | MDM Deployment |
|---------|----------------|----------------|
| **Target** | Personal laptops | Company fleets |
| **Homebrew** | User-owned | Admin-owned, centralized |
| **Users** | Current user only | All users on system |
| **Repository** | `~/.dotfiles` | `/var/root/.dotfiles` |
| **Execution** | User runs script | MDM runs as root |
| **Configuration** | Command-line args | Environment variables |
| **Logging** | Terminal output | `/var/log/mdm-dotfiles-deploy.log` |
| **Updates** | Re-run anytime | MDM scheduled/triggered |
| **Idempotent** | ✅ Yes | ✅ Yes |

## Quick Start Examples

### Individual User

```bash
# Everything profile (default)
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash

# Specific profile
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile creative

# Custom bundles
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --bundles "base development"
```

### MDM Deployment

```bash
#!/bin/bash
# MDM Script (run as root)

export DOTFILES_REPO="https://github.com/YOUR_ORG/dotfiles.git"
export INSTALL_PROFILE="work"
export ADMIN_USER="localadmin"

curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/dotfiles/main/scripts/mdm-deploy.sh -o /tmp/mdm-deploy.sh
chmod +x /tmp/mdm-deploy.sh
/tmp/mdm-deploy.sh 2>&1 | tee /var/log/mdm-dotfiles-deploy.log
rm /tmp/mdm-deploy.sh
```

## Choosing the Right Method

### Use Individual User Installation If

- ✅ Setting up your personal Mac
- ✅ You're a developer managing your own machine
- ✅ You want user-level Homebrew
- ✅ You need flexibility and experimentation
- ✅ You're testing configurations

### Use MDM Deployment If

- ✅ Managing 10+ company Macs
- ✅ You need standardized configurations
- ✅ You want centralized Homebrew
- ✅ You need audit trails
- ✅ You're an IT administrator
- ✅ You use Jamf, Kandji, ScaleFusion, etc.

## Both Methods Support

- ✅ Modular bundle system
- ✅ Profiles for common workflows
- ✅ Custom bundle selection
- ✅ Excluding specific bundles
- ✅ Idempotent operations (safe to re-run)
- ✅ Automatic updates via git pull
- ✅ Configuration file symlinking

## Installation Process Comparison

### Individual User Installation

1. Clone/update repository to `~/.dotfiles`
2. Install Homebrew in user account
3. Install packages via `install-apps.sh`
4. Symlink configs to user home directory
5. Run bundle custom scripts (base.sh, etc.)
6. Setup VS Code CLI

**Time:** 5-45 minutes depending on profile

### MDM Deployment

1. Clone repository to `/var/root/.dotfiles`
2. Install Homebrew centrally (owned by admin)
3. Install packages via `install-apps.sh`
4. Deploy configs to all system users
5. Run bundle custom scripts
6. Complete audit logging

**Time:** 10-60 minutes depending on profile + fleet size

## Next Steps

- [Individual User Installation Guide](manual.md)
- [MDM Deployment Guide](mdm.md)
- [Bundle System Overview](../bundle-system/README.md)
