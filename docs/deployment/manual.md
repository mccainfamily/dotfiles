# Individual User Installation

Complete guide for manually installing dotfiles as an individual user.

## Overview

The `user-install.sh` script provides a personal dotfiles setup for individual users:

✅ Clones/updates dotfiles repository  
✅ Installs Homebrew in user account  
✅ Installs packages via modular bundle system  
✅ Deploys configuration files  
✅ Sets up shell environment (eza, Starship, Ghostty)  
✅ Configures VS Code CLI  
✅ Fully idempotent - safe to run multiple times  

## Quick Start

### Default Installation (everything profile)

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash
```

### Custom Profile

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile creative
```

### Specific Bundles

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --bundles "base development communication"
```

### Exclude Bundles

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile everything --exclude "entertainment creative"
```

## Available Options

| Option | Description | Example |
|--------|-------------|---------|
| `--profile <name>` | Install using a profile | `--profile creative` |
| `--bundles "<list>"` | Install specific bundles | `--bundles "base development"` |
| `--exclude "<list>"` | Exclude specific bundles | `--exclude "entertainment"` |
| `--help` | Show help message | `--help` |

## Available Profiles

| Profile | Bundles | Use Case |
|---------|---------|----------|
| **everything** | All bundles | Power user, everything |
| **base** | base only | Minimal setup |
| **creative** | base, creative, av-studio, communication | Content creation, video editing |
| **kids** | base, entertainment, communication | Family/kids machine |
| **work** | base, work, communication | Professional work |

See [Profiles Guide](../bundle-system/profiles.md) for complete list.

## Installation Process

### Step 1: Clone/Update Repository

- If `~/.dotfiles` doesn't exist: clones from GitHub
- If `~/.dotfiles` exists: runs `git pull` to update
- Handles local changes gracefully with warnings

### Step 2: Install Homebrew

- Detects architecture (Apple Silicon vs Intel)
- Installs if not present:
  - Apple Silicon: `/opt/homebrew`
  - Intel: `/usr/local`
- Skips update if updated within last 24 hours
- Adds to shell profile automatically

### Step 3: Install Packages

Runs `install-apps.sh` with your selected options:

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile everything
```

This installs:

- Homebrew packages (.Brewfile files)
- Mac App Store apps (.Appfile files)  
- Custom scripts (.sh files like base.sh, av-studio.sh)

### Step 4: Deploy Configuration Files

Creates symlinks for:

| Config File | Source | Target |
|------------|--------|--------|
| `.zshrc` | `~/.dotfiles/config/.zshrc` | `~/.zshrc` |
| `.bashrc` | `~/.dotfiles/config/.bashrc` | `~/.bashrc` |
| `.bash_profile` | `~/.dotfiles/config/.bash_profile` | `~/.bash_profile` |
| `.gitconfig` | `~/.dotfiles/config/.gitconfig` | `~/.gitconfig` |
| SSH config | `~/.dotfiles/config/ssh_config` | `~/.ssh/config` |
| Starship | `~/.dotfiles/config/starship.toml` | `~/.config/starship.toml` |

**Backup System:**

- Existing files backed up with timestamp: `.backup.20250122-143015`
- Only backs up regular files (not existing symlinks)
- Backups preserved on subsequent runs

### Step 5: Shell Configuration (base.sh)

The base bundle custom script configures:

**eza Aliases:**

```bash
alias ls='eza --icons'
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias lt='eza --tree --icons'
```

**Starship Prompt:**

- Initializes Starship in `.zshrc` and `.bashrc`
- Uses config from `~/.config/starship.toml`

**Ghostty Terminal:**

- Creates `~/.config/ghostty/config` if not exists
- Preserves existing configuration

### Step 6: VS Code CLI

If VS Code is installed, creates symlink for CLI:

```bash
ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
  "/opt/homebrew/bin/code"
```

## Idempotency

The installation is fully idempotent - safe to run multiple times:

### Git Repository

- Updates existing repo via `git pull`
- Continues if update fails (local changes)
- Never deletes your local work

### Homebrew

- Skips installation if present
- Only updates if not updated in last 24 hours
- Continues if update fails (network issues)

### Symlinks

- Checks if symlink points to correct location
- Only updates if target changed
- Never overwrites backups

### Package Installation

- Homebrew `brew bundle` is idempotent by design
- Only installs missing packages
- Skips already-installed packages

### Shell Configuration

- Checks for existing aliases before adding
- Checks for existing Starship init
- Never duplicates configuration

See [Idempotency Guide](../idempotency.md) for details.

## Post-Installation

### Restart Shell

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
brew doctor

# Check tools
starship --version
eza --version

# Check aliases
ls      # Should use eza with icons

# List bundles
cd ~/.dotfiles
./scripts/install-apps.sh --list-bundles
```

## Common Workflows

### Install Additional Bundles

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --bundles "diagrams monitoring"
```

### Update Everything

```bash
# Re-run installation (pulls latest changes)
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash

# Update Homebrew packages
brew update && brew upgrade
```

### Switch Profiles

```bash
cd ~/.dotfiles

# See what's available
./scripts/install-apps.sh --list-profiles

# Install new profile (additive - doesn't remove existing packages)
./scripts/install-apps.sh --profile work
```

## Customization

### Local Shell Customization

Add personal settings to `~/.zshrc.local`:

```bash
# ~/.zshrc.local (not tracked by dotfiles)
export MY_CUSTOM_VAR="value"
alias myalias="command"
```

The main `.zshrc` sources this file if it exists.

### Fork the Repository

For extensive customization:

1. Fork on GitHub: `https://github.com/mccainfamily/dotfiles`
2. Clone your fork:

   ```bash
   rm -rf ~/.dotfiles
   git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
   ```

3. Modify bundles, configs, scripts
4. Re-run installation:

   ```bash
   cd ~/.dotfiles
   ./scripts/user-install.sh
   ```

## Troubleshooting

### Repository Update Failed

```bash
cd ~/.dotfiles
git status                    # Check for local changes
git stash                     # Stash changes
git pull                      # Pull updates
git stash pop                 # Restore changes
```

### Homebrew Permission Issues

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew
```

### Symlink Already Exists

The script handles this automatically - existing symlinks are checked and only updated if pointing to wrong location.

### VS Code CLI Not Working

```bash
# Manually create symlink
sudo ln -sf "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
  "/opt/homebrew/bin/code"

# Test
code --version
```

### Package Installation Failed

```bash
# Check specific bundle
cd ~/.dotfiles
./scripts/install-apps.sh --bundles "base"

# Check Homebrew
brew doctor

# Update Homebrew
brew update
```

## Files and Directories

| Location | Purpose |
|----------|---------|
| `~/.dotfiles` | Cloned repository |
| `~/.dotfiles/brew/bundles/` | Bundle definitions |
| `~/.dotfiles/config/` | Configuration files |
| `~/.dotfiles/scripts/` | Installation scripts |
| `~/.zshrc` | Symlink to dotfiles |
| `~/.ssh/config` | Symlink to dotfiles |
| `~/.config/starship.toml` | Symlink to dotfiles |
| `~/.config/ghostty/` | Terminal config |
| `~/src/github.com` | Go workspace |
| `/opt/homebrew` | Homebrew (Apple Silicon) |
| `/usr/local` | Homebrew (Intel) |

## Next Steps

- [Bundle System](../bundle-system/README.md) - Understanding bundles
- [Configuration](../configuration/README.md) - Customizing configs
- [Idempotency](../idempotency.md) - Safety guarantees
