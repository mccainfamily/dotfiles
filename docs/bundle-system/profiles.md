# Profiles

Profiles are pre-configured combinations of modules designed for common use cases. They provide a quick way to install a complete environment without manually selecting individual modules.

## Understanding Profiles

A profile is simply a named list of modules defined in [`brew/profiles/profiles.conf`](../../brew/profiles/profiles.conf). When you install a profile, all specified modules are installed, and each module installs all its file types (Brewfile, Appfile, and custom scripts).

## Available Profiles

### base

**Use Case:** Minimal Mac setup with only essentials

**Modules:** `base`

**What's Included:**

- Essential Unix utilities
- Modern CLI tools (ripgrep, bat, eza, fzf)
- Ghostty terminal
- Zsh with plugins
- Starship prompt
- Git and GitHub CLI
- Google Chrome

**Package Count:** ~40 packages

**Best For:**

- Users who want minimal installations
- Starting point for custom configurations
- Lightweight environments

**Installation:**

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile base
```

### everything

**Use Case:** Power user setup with all available tools

**Modules:** `base network-security cloud-infrastructure development security-privacy diagrams monitoring creative av-studio communication entertainment games work`

**What's Included:**

- Everything from all modules
- Complete development environment
- Network and security tools
- Cloud infrastructure tools
- Creative and media production
- Communication and entertainment

**Package Count:** 210+ packages

**Best For:**

- Power users who need comprehensive tooling
- Workstations with ample disk space
- Users who work across multiple domains

**Installation:**

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile everything
```

### creative

**Use Case:** Creative work, design, and media production

**Modules:** `base creative`

**What's Included:**

- Base essential tools
- Logic Pro (professional audio)
- OmniGraffle (diagramming)
- cmatrix and other creative tools

**Package Count:** ~50 packages

**Best For:**

- Designers and artists
- Audio/video producers
- Creative professionals

**Installation:**

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile creative
```

### kids

**Use Case:** Family/kids machine with entertainment

**Modules:** `base entertainment games`

**What's Included:**

- Base essential tools
- Spotify, Audible, Kindle
- Steam gaming platform
- Endel (focus soundscapes)

**Package Count:** ~50 packages

**Best For:**

- Family computers
- Kids' machines
- Entertainment-focused setups

**Installation:**

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile kids
```

### work

**Use Case:** Professional work environment

**Modules:** `base network-security cloud-infrastructure development security-privacy diagrams monitoring creative communication`

**What's Included:**

- Complete development environment
- Cloud and infrastructure tools
- Security and network tools
- Communication apps (Zoom, Teams, Slack)
- Monitoring and observability
- Diagram tools

**Package Count:** ~180 packages

**Best For:**

- Professional workstations
- DevOps and SRE roles
- Network engineers
- Security professionals

**Installation:**

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile work
```

## Using Profiles

### Basic Usage

Install a profile with:

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile <profile-name>
```

### List Available Profiles

View all available profiles and their modules:

```bash
./scripts/install-apps.sh --list-profiles
```

Example output:

```
Available Profiles:

  everything
    Bundles: base network-security cloud-infrastructure development security-privacy diagrams monitoring creative av-studio communication entertainment games work

  base
    Bundles: base

  creative
    Bundles: base creative
```

### Using Profiles with Exclusions

You can exclude specific modules from a profile:

```bash
# Install everything except entertainment and games
./scripts/install-apps.sh --profile everything --exclude "entertainment games"

# Install work profile but exclude creative tools
./scripts/install-apps.sh --profile work --exclude "creative"
```

**Note:** The `base` module cannot be excluded as it's required for all installations.

## Profile Comparison

| Profile | Modules | Use Case | Package Count |
|---------|---------|----------|---------------|
| **base** | 1 | Minimal setup | ~40 |
| **creative** | 2 | Design & media | ~50 |
| **kids** | 3 | Family/entertainment | ~50 |
| **work** | 8 | Professional environment | ~180 |
| **everything** | 13 | Complete toolkit | 210+ |

## One-Line Installation

Profiles can be used with the one-line installer:

```bash
# Install with a specific profile
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile creative

# Install everything profile
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile everything
```

## Creating Custom Profiles

You can create your own profiles by editing `brew/profiles/profiles.conf`:

```bash
# Add to brew/profiles/profiles.conf
PROFILE_MY_CUSTOM="base development creative communication"
```

Then use it:

```bash
./scripts/install-apps.sh --profile my-custom
```

### Custom Profile Guidelines

1. **Always include `base`** - It's required and must be first
2. **Use descriptive names** - Make it clear what the profile is for
3. **Document your profile** - Add comments explaining the use case
4. **Test locally first** - Verify the profile works before deploying

Example custom profile:

```bash
# Full-Stack Developer Profile
# For web developers working with modern JavaScript frameworks
PROFILE_FULLSTACK="base development cloud-infrastructure diagrams communication"
```

## MDM Deployment with Profiles

For enterprise deployment via ScaleFusion or other MDM solutions, configure the profile in `scripts/mdm-deploy.sh`:

```bash
# Set the profile to deploy
INSTALL_PROFILE="work"
```

See the [MDM Deployment Guide](../deployment/mdm.md) for more details.

## Next Steps

- View [Available Modules](bundles.md) to see what each module contains
- Learn to create [Custom Modules](custom-bundles.md)
- Read the [Installation Guide](../getting-started/installation.md)
