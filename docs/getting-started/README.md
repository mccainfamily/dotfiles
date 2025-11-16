# Getting Started

Welcome! This guide will help you get your dotfiles environment set up quickly.

## Prerequisites

Before you begin, ensure you have:

- **macOS 14+** (Sonoma or later recommended)
- **Admin access** to your Mac
- **Internet connection** for downloading packages
- Basic familiarity with the terminal

## Installation Methods

There are three ways to install this dotfiles system:

### 1. Profile-Based Installation (Recommended)

Best for most users. Choose a pre-configured profile that matches your needs.

[Learn more about profiles →](../bundle-system/profiles.md)

### 2. Custom Bundle Selection

Mix and match bundles to create your own custom setup.

[Learn more about bundles →](../bundle-system/bundles.md)

### 3. MDM Deployment

Automated deployment for managed Macs via ScaleFusion.

[Learn more about MDM deployment →](../deployment/mdm.md)

## Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/mccainfamily/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

{% hint style="info" %}
**Note**: If git is not installed, the script will install it automatically via Xcode Command Line Tools.
{% endhint %}

### Step 2: Choose Your Profile

List available profiles to see what's available:

```bash
./scripts/install-apps.sh --list-profiles
```

You'll see profiles like:

- `minimal` - Just the essentials
- `network-engineer` - Network security and cloud tools
- `developer` - Software development tools
- `security` - Security-focused setup
- And more...

### Step 3: Install

Install using your chosen profile:

```bash
./scripts/install-apps.sh --profile network-engineer
```

The installation will:

1. Install Homebrew (if not already installed)
2. Install all packages in the selected bundles
3. Configure your shell (Zsh with Starship prompt)
4. Set up configuration files
5. Create necessary directories

{% hint style="success" %}
**Estimated time**: 15-30 minutes depending on your profile and internet speed.
{% endhint %}

### Step 4: Restart Your Terminal

After installation, restart your terminal or run:

```bash
source ~/.zshrc
```

## What Gets Installed?

Depending on your chosen profile, you'll get:

### All Profiles Include "base" Bundle

- Essential Unix utilities (coreutils, findutils, grep, sed, wget, curl)
- Shell tools (bash, zsh, tmux, starship)
- Basic dev tools (git, gh)
- Common utilities (jq, yq, fzf, ripgrep, bat, eza)
- Ghostty terminal
- Google Chrome
- Developer fonts (JetBrains Mono, Fira Code)

### Additional Tools by Profile

Check out the [Profiles Guide](../bundle-system/profiles.md) to see what each profile includes.

## Verifying Installation

### Check Homebrew

```bash
brew --version
brew doctor
```

### Check Installed Tools

```bash
# Check shell
echo $SHELL

# Check Starship prompt
starship --version

# Check Git
git --version

# List installed packages
brew list
```

### Check Configuration

```bash
# Check if config files are linked
ls -la ~/
grep -l "dotfiles" ~/.zshrc
```

## Next Steps

Now that you're set up:

1. **[Customize your configuration](../configuration/README.md)** - Personalize your environment
2. **[Learn about bundles](../bundle-system/README.md)** - Understand what's installed
3. **[Explore the tools](../reference/packages.md)** - Discover what you can do
4. **[Read the quick reference](../reference/quick-reference.md)** - Common commands at your fingertips

## Need Help?

- **Installation issues?** Check [Troubleshooting](../troubleshooting.md)
- **Want to customize?** See [Configuration Guide](../configuration/README.md)
- **Questions?** Check the [FAQ](../faq.md)

## What's Next?

Continue to:

- [Installation Guide →](installation.md) - Detailed installation instructions
- [Quick Start →](quick-start.md) - Jump right in with common tasks
- [First Steps →](first-steps.md) - What to do after installation
