# Dotfiles Project Instructions

## Project Overview

This is a modular, role-based development environment for network engineering, DevOps, and software development. Features a flexible bundle system with 210+ packages organized into 10 bundles and 10 pre-defined profiles.

## Project Structure

```
dotfiles/
├── brew/
│   ├── bundles/              # Modular bundle files
│   │   ├── *.Brewfile        # Homebrew packages
│   │   ├── *.Appfile         # Mac App Store apps
│   │   └── *.sh              # Custom install scripts
│   └── profiles/
│       └── profiles.conf     # Profile definitions
├── config/
│   ├── starship.toml         # Starship prompt configuration
│   └── ssh_config            # SSH configuration
├── scripts/
│   ├── user-install.sh       # Individual user installation (recommended)
│   ├── install-apps.sh       # Bundle-based installation
│   ├── mdm-deploy.sh         # MDM deployment for enterprises
│   ├── install.sh            # Legacy installation (deprecated)
│   ├── brew-sync.sh          # Sync packages to Brewfile
│   ├── update.sh             # Update all packages
│   └── update-and-pr.sh      # Create PR after updates
├── docs/                     # GitBook documentation
│   ├── getting-started/
│   ├── bundle-system/
│   ├── deployment/
│   ├── configuration/
│   └── reference/
└── .github/workflows/        # GitHub Actions for docs deployment
```

## Key Concepts

### Bundles

Individual collections of related packages organized by purpose:

**Core Bundles:**

- `base` - Essential Unix tools, shell, Git, modern CLI tools (eza, bat, ripgrep, fzf, etc.)
- `development` - Programming languages (Python, Node, Go, Rust), IDEs (VS Code, GoLand), databases
- `network-security` - Network scanning (nmap, masscan, zmap), packet analysis (Wireshark), VPN (Tailscale, WireGuard)
- `cloud-infrastructure` - AWS/GCP/Azure CLI, Kubernetes (kubectl, k9s, helm), Terraform, Ansible
- `security-privacy` - Encryption tools, security utilities
- `diagrams` - PlantUML, Mermaid, Graphviz, D2
- `monitoring` - Prometheus, Grafana, observability tools
- `creative` - Design and creative tools
- `av-studio` - Audio/video editing and live production (OBS, NDI, Stream Deck, Elgato, Opal Composer)
- `communication` - Zoom, Teams, Slack, Discord, Signal, WhatsApp, Bluesky
- `entertainment` - Games, Spotify, Audible
- `work` - Professional work tools, FortiClient VPN

**App Store Bundles:**

- `development-appstore` - Mouse Jiggler
- `creative-appstore` - Logic Pro, OmniGraffle
- `av-studio-appstore` - Final Cut Pro, X32-Mix (Behringer)
- `entertainment-appstore` - djay Pro, VirtualDJ Home, Endel
- `monitoring-appstore` - AvertX Remote

**Custom Scripts:**
Bundle-specific `.sh` scripts in `brew/bundles/` run after Brewfile/Appfile installation:

- `base.sh` - Configures eza aliases, Starship prompt, Ghostty terminal
- `av-studio.sh` - Installs Shure Wireless Workbench (manual download helper)

### Profiles

Pre-configured combinations of bundles defined in `brew/profiles/profiles.conf`:

- `base` - Essential tools only
- `everything` - All bundles (power user setup)
- `creative` - Base + creative + creative-appstore
- `kids` - Base + entertainment + entertainment-appstore
- `work` - Base + work + communication

Profiles automatically include both Brewfile and Appfile bundles where applicable.

## Working with Bundles and Brewfiles

- **Bundle Brewfiles**: Located in `brew/bundles/*.Brewfile`
- **App Store bundles**: Located in `brew/bundles/*.Appfile`
- **Custom scripts**: Located in `brew/bundles/*.sh` (run after bundle installation)
- **Profile definitions**: Located in `brew/profiles/profiles.conf`
- When modifying bundle files, maintain alphabetical ordering within each section
- Test bundle installations before committing: `./scripts/install-apps.sh --bundles "bundle-name"`
- Custom scripts are automatically executed by `install-apps.sh` when a bundle is installed
- Document any system-specific dependencies or requirements in bundle comments

## Working with Documentation

- **Documentation location**: `docs/` directory
- **GitBook format**: Uses GitBook with SUMMARY.md for structure
- When adding features, update relevant documentation pages
- GitHub Actions automatically deploys docs to GitHub Pages on push to main

## General Guidelines

- Preserve existing formatting and conventions
- Test changes on a clean environment when possible
- Consider cross-machine compatibility
- Document any manual setup steps that can't be automated
- Scripts are in `scripts/` directory, not root
- Config files are in `config/` directory
- Keep bundles focused and organized

## Common Tasks

### Quick Installation (Individual Users)

```bash
# One-line installation with defaults (base profile)
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash

# Install with specific profile
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile everything

# Install specific bundles
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --bundles "base development av-studio"
```

### Manual Installation

```bash
# Clone and install
git clone https://github.com/mccainfamily/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/user-install.sh --profile everything

# Or use install-apps.sh directly for just packages
./scripts/install-apps.sh --profile everything
./scripts/install-apps.sh --bundles "base development"
./scripts/install-apps.sh --list-profiles
./scripts/install-apps.sh --list-bundles
```

### Package Management

```bash
# Sync installed packages to Brewfile
./scripts/brew-sync.sh

# Update all packages
./scripts/update.sh

# Create PR after updates
./scripts/update-and-pr.sh "Add new tools"
```

### Bundle Operations

```bash
# Check a bundle
brew bundle check --file=brew/bundles/base.Brewfile

# Install a specific bundle (with custom script if present)
./scripts/install-apps.sh --bundles "av-studio"

# Install App Store bundle
./scripts/install-apps.sh --bundles "creative-appstore"

# Install both Brewfile and Appfile bundles
./scripts/install-apps.sh --bundles "av-studio av-studio-appstore"

# Cleanup
brew cleanup
```

### Creating New Bundles

1. Create `brew/bundles/my-bundle.Brewfile` with package definitions
2. (Optional) Create `brew/bundles/my-bundle.Appfile` for Mac App Store apps
3. (Optional) Create `brew/bundles/my-bundle.sh` for custom installation steps
4. Make custom script executable: `chmod +x brew/bundles/my-bundle.sh`
5. Add bundle to `brew/profiles/profiles.conf` Available Bundles list
6. Test: `./scripts/install-apps.sh --bundles "my-bundle"`

### Documentation

```bash
# Test locally
cd docs && gitbook serve

# Build
cd docs && gitbook build

# GitHub Actions automatically deploys on push to main
```

## MDM Deployment

- **Script**: `scripts/mdm-deploy.sh`
- **Purpose**: Enterprise/multi-user deployment via ScaleFusion MDM
- **Configuration**: Set via environment variables or edit script defaults
- **Default profile**: `everything`
- Deployed via ScaleFusion as root
- Installs Homebrew in admin user account (not per-user)
- Full audit logging to `/var/log/mdm-dotfiles-deploy.log`

**Environment Variables:**

```bash
# Override defaults with environment variables
INSTALL_PROFILE="work" ADMIN_USER="john" ./mdm-deploy.sh
INSTALL_BUNDLES="base development" INSTALL_PROFILE="" ./mdm-deploy.sh
DEPLOY_TO_ALL_USERS=false ./mdm-deploy.sh
```

**Individual users should use `user-install.sh` instead** - it installs Homebrew in their own account.

## Important Files

- `README.md` - Repository overview with quick start
- `brew/profiles/profiles.conf` - Profile and bundle definitions
- `brew/bundles/*.Brewfile` - Homebrew package bundles
- `brew/bundles/*.Appfile` - Mac App Store app bundles
- `brew/bundles/*.sh` - Custom installation scripts for bundles
- `scripts/user-install.sh` - Individual user installation (recommended)
- `scripts/install-apps.sh` - Bundle installer engine
- `scripts/mdm-deploy.sh` - Enterprise MDM deployment
- `docs/README.md` - Documentation home page
- `docs/SUMMARY.md` - Documentation structure
- `.github/workflows/deploy-docs.yml` - GitHub Actions workflow
