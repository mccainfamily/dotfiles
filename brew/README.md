# Homebrew Package Management

This directory contains the Homebrew package configuration organized into modular bundles and installation profiles.

## Directory Structure

```
brew/
├── bundles/              # Individual package bundles
│   ├── base.Brewfile                # Essential tools (REQUIRED)
│   ├── network-security.Brewfile    # Network tools and security
│   ├── cloud-infrastructure.Brewfile # Cloud platforms, K8s, IaC
│   ├── development.Brewfile         # Languages, IDEs, dev tools
│   ├── security-privacy.Brewfile    # Encryption, Proton suite
│   ├── diagrams.Brewfile            # PlantUML, Mermaid, etc.
│   ├── monitoring.Brewfile          # Prometheus, Grafana
│   ├── creative.Brewfile            # Design and creative tools
│   ├── communication.Brewfile       # Zoom, Teams, messaging
│   └── entertainment.Brewfile       # Games, Spotify, etc.
└── profiles/
    └── profiles.conf     # Profile definitions
```

## Bundle System

### Base Bundle (REQUIRED)

The `base` bundle contains essential tools that should be installed on every system:

- Core Unix utilities (coreutils, findutils, grep, etc.)
- Shell & terminal tools (zsh, tmux, starship, etc.)
- Basic development tools (git, gh, pyenv)
- Essential utilities (jq, yq, fzf, ripgrep, bat, etc.)
- Ghostty terminal emulator
- JetBrains Mono and other fonts

**Important**: The `base` bundle is ALWAYS installed first and cannot be excluded.

### Optional Bundles

All other bundles are optional and can be mixed and matched:

- **network-security**: Network scanning, packet analysis, diagnostics
- **cloud-infrastructure**: AWS, GCP, Azure, Kubernetes, Terraform
- **development**: Programming languages, IDEs, database tools
- **security-privacy**: Encryption tools, Proton suite, Yubikey support
- **diagrams**: Diagram generation tools (PlantUML, Mermaid, Graphviz, D2)
- **monitoring**: Monitoring and observability tools
- **creative**: Design and creative applications
- **communication**: Video conferencing and messaging apps
- **entertainment**: Games, music, and entertainment apps

## Installation Profiles

Profiles are predefined combinations of bundles for common use cases:

### Available Profiles

1. **everything** (default)
   - Installs all available bundles
   - Best for: Power users, developers, network engineers

2. **base**
   - Only the essential tools
   - Best for: Minimal installations

3. **creative**
   - Base + creative tools
   - Best for: Content creators, designers

4. **kids**
   - Base + entertainment + education
   - Best for: Family/kid-friendly setups

## Configuration Options

In [mdm-deploy.sh](../scripts/mdm-deploy.sh), you can configure installation using these options:

### Option 1: Use a Profile (Recommended)

```bash
INSTALL_PROFILE="everything"
```

### Option 2: Install Specific Bundles

```bash
INSTALL_PROFILE=""
INSTALL_BUNDLES="base development cloud-infrastructure"
```

### Option 3: Exclude Bundles from a Profile

```bash
INSTALL_PROFILE="everything"
EXCLUDE_BUNDLES="entertainment creative"
```

**Note**: The `base` bundle cannot be excluded and will always be installed first.

## Usage Examples

### Install Everything

```bash
INSTALL_PROFILE="everything"
EXCLUDE_BUNDLES=""
```

### Developer Workstation (No Entertainment)

```bash
INSTALL_PROFILE="everything"
EXCLUDE_BUNDLES="entertainment communication"
```

### Network Engineer Setup

```bash
INSTALL_PROFILE=""
INSTALL_BUNDLES="base network-security cloud-infrastructure monitoring"
```

### Minimal Installation

```bash
INSTALL_PROFILE="base"
EXCLUDE_BUNDLES=""
```

## Adding New Bundles

To create a new bundle:

1. Create a new Brewfile in `bundles/` directory:

   ```bash
   touch brew/bundles/my-bundle.Brewfile
   ```

2. Add your packages using Homebrew Bundle syntax:

   ```ruby
   # My Custom Bundle
   brew "package-name"
   cask "app-name"
   ```

3. Update [profiles.conf](profiles/profiles.conf) to include the bundle in relevant profiles:

   ```bash
   PROFILE_MYPROFILE="base my-bundle other-bundle"
   ```

4. Document the bundle in this README

## Important Notes

- **Base Bundle**: Always installed first, cannot be excluded
- **No Main Brewfile**: All packages must be in bundle files
- **Profile System**: Use profiles for common setups, customize with exclusions
- **Bundle Order**: Base is always first, others installed in the order specified
- **Deduplication**: Duplicate bundles are automatically removed from the install list
