# Modular Bundle System

## Overview

The dotfiles repository uses a **modular bundle system** that allows you to install only the tools you need for your specific use case. Instead of installing everything, you can choose from pre-defined profiles or select individual modules.

## Module Structure

Each module is identified by a single name (e.g., `development`, `creative`, `av-studio`) and can have up to three file types:

- **`<module>.Brewfile`** - Homebrew formulas and casks
- **`<module>.Appfile`** - Mac App Store applications
- **`<module>.sh`** - Custom installation scripts

When you specify a module by name, **all available file types** for that module are automatically installed.

### Example

The `av-studio` module includes:

- `av-studio.Brewfile` - OBS Studio, NDI tools, stream utilities
- `av-studio.Appfile` - Final Cut Pro, X32-Mix from App Store
- `av-studio.sh` - Custom configuration for OBS plugins

Installing the `av-studio` module installs all three components automatically.

## Benefits

- **Faster installations** - Install only what you need
- **Reduced disk space** - Don't install unused applications
- **Unified naming** - One name per module, regardless of package source
- **Customizable** - Mix and match modules for your workflow
- **Profiles** - Pre-configured sets for common use cases
- **Maintainable** - Each module's files are clearly organized

## Available Modules

| Module | Files | Description | Package Count |
|--------|-------|-------------|---------------|
| **base** | Brewfile, Script | Essential tools for all users | ~40 packages |
| **network-security** | Brewfile | Network scanning, packet analysis, diagnostics | ~40 packages |
| **cloud-infrastructure** | Brewfile | AWS, K8s, Terraform, IaC tools | ~20 packages |
| **development** | Brewfile, Appfile | Languages, IDEs, development tools | ~20 packages |
| **security-privacy** | Brewfile | Encryption, Proton suite, Yubikey, Tor | ~25 packages |
| **diagrams** | Brewfile | PlantUML, Mermaid, Graphviz, OmniGraffle | ~8 packages |
| **monitoring** | Brewfile, Appfile | Prometheus, Grafana, observability, AvertX | ~5 packages |
| **creative** | Brewfile, Appfile | Logic Pro, OmniGraffle, creative tools | ~3 packages |
| **av-studio** | Brewfile, Appfile, Script | OBS, NDI, Final Cut Pro, X32-Mix | ~15 packages |
| **communication** | Brewfile | Zoom, Teams, WhatsApp, Slack, Discord | ~5 packages |
| **entertainment** | Brewfile, Appfile | Games, Spotify, Audible, djay Pro, VirtualDJ | ~5 packages |
| **work** | Brewfile | Professional tools and VPN | ~3 packages |

## Pre-Defined Profiles

Profiles are combinations of modules for common workflows:

### base

**Use case**: Basic Mac setup with essentials only
**Modules**: `base`
**Package count**: ~40

### everything

**Use case**: Power user with all tools
**Modules**: `base network-security cloud-infrastructure development security-privacy diagrams monitoring creative av-studio communication entertainment work`
**Package count**: ~210+

### creative

**Use case**: Creative work, design, video/audio production
**Modules**: `base creative`
**Package count**: ~50

### kids

**Use case**: Family/kids machine with entertainment
**Modules**: `base entertainment`
**Package count**: ~50

### work

**Use case**: Professional work environment
**Modules**: `base work communication`
**Package count**: ~50

## Usage

### Manual Installation

#### Using a Profile

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile everything
```

#### Using Specific Modules

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --bundles "base development creative"
```

Note: When you specify a module like `development`, all its file types (`.Brewfile`, `.Appfile`, `.sh`) are installed automatically.

#### List Available Options

```bash
# List all profiles
./scripts/install-apps.sh --list-profiles

# List all modules (shows which file types each module has)
./scripts/install-apps.sh --list-bundles
```

### MDM Deployment (ScaleFusion)

Edit `scripts/mdm-deploy.sh` and configure:

```bash
# Use a profile (recommended)
INSTALL_PROFILE="everything"

# OR use specific modules
# INSTALL_BUNDLES="base development creative"

# OR leave both empty for legacy Brewfile (all packages)
```

Then deploy as usual via ScaleFusion.

## Module Details

### base (Brewfile + Script)

**Essential tools for all users**

- Unix utilities (coreutils, findutils, grep, sed, wget, curl)
- Shell tools (bash, zsh, tmux, starship)
- Basic dev tools (git, gh)
- Common utilities (jq, yq, fzf, ripgrep, bat, eza, htop)
- Ghostty terminal
- Google Chrome
- Developer fonts

### network-security (Brewfile)

**Network scanning and security tools**

- Scanning: nmap, masscan, zmap, arp-scan
- Packet analysis: wireshark, tcpdump, tshark, ngrep
- Diagnostics: mtr, iperf3, speedtest-cli, bandwhich
- DNS: dig, dog, dnsmasq, dnstracer
- SSL/TLS: openssl, mkcert, certbot
- VPN: wireguard, openvpn, sshuttle
- Network testing: hping, vegeta, wrk

### cloud-infrastructure (Brewfile)

**Cloud platforms and IaC**

- AWS: awscli, aws-vault, chamber
- GCP: google-cloud-sdk
- Azure: azure-cli
- Kubernetes: kubectl, k9s, helm, kubectx, stern
- IaC: terraform, terragrunt, ansible, pulumi
- Containers: OrbStack

### development (Brewfile + Appfile)

**Programming languages and IDEs**

- Languages: Python, Node.js, Go, Rust
- IDEs: VS Code, GoLand, JetBrains Toolbox
- Git tools: lazygit, delta
- Web/API: curl alternatives, grpcurl
- Databases: PostgreSQL, MySQL, Redis, SQLite
- Code quality: shellcheck, hadolint

### security-privacy (Brewfile)

**Encryption, secure communications, hardware security**

- Encryption: GPG, age, sops, vault, pass
- Anonymity: Tor, torsocks, proxychains
- Yubikey: Full yubikey toolchain
- Browsers: Tor Browser, Brave, Firefox
- Communications: Signal, Proton suite (Mail, Pass, Drive, VPN)
- Keybase: Encrypted collaboration

### diagrams (Brewfile)

**Diagram and visualization tools**

- CLI: PlantUML, Mermaid, Graphviz, D2, ditaa
- GUI: Draw.io, OmniGraffle, XMind, Freeplane
- Use cases: UML, C4 models, flowcharts, network diagrams

### monitoring (Brewfile + Appfile)

**Metrics and observability**

- Prometheus, Grafana
- Telegraf, Loki, Promtail
- AvertX Remote (App Store)

### creative (Brewfile + Appfile)

**Creative and design tools**

- Logic Pro (App Store)
- OmniGraffle (App Store)
- cmatrix (fun terminal)

### av-studio (Brewfile + Appfile + Script)

**Audio/video editing and live production**

- OBS Studio, NDI tools, stream utilities
- Final Cut Pro (App Store)
- X32-Mix (App Store)
- Custom OBS plugin configuration

### communication (Brewfile)

**Video conferencing and messaging**

- Zoom, Microsoft Teams
- Slack, Discord, Signal
- WhatsApp, Bluesky

### entertainment (Brewfile + Appfile)

**Games, music, audiobooks**

- Spotify, Audible, Steam
- djay Pro, VirtualDJ, Endel (App Store)
- Note: War Thunder available via Steam or website

### work (Brewfile)

**Professional tools and VPN**

- FortiClient VPN
- Professional productivity tools

## Creating Custom Modules

You can create your own custom modules with any combination of file types:

1. Create module files in `brew/bundles/`:

```bash
# Create a Brewfile for Homebrew packages
cat > brew/bundles/my-module.Brewfile << 'EOF'
# My Custom Module
# Description of what this module includes

brew "tool1"
brew "tool2"
cask "app1"
EOF

# Optionally create an Appfile for App Store apps
cat > brew/bundles/my-module.Appfile << 'EOF'
# My Custom Module - App Store Apps

mas "App Name", id: 123456789
EOF

# Optionally create a custom script
cat > brew/bundles/my-module.sh << 'EOF'
#!/bin/bash
# Custom setup for my-module
echo "Running custom setup..."
EOF
chmod +x brew/bundles/my-module.sh
```

2. Install the module (all file types will be processed):

```bash
./scripts/install-apps.sh --bundles "base my-module"
```

## Creating Custom Profiles

Edit `brew/profiles/profiles.conf`:

```bash
# My custom profile
PROFILE_MY_CUSTOM="base development my-module"
```

Then use it:

```bash
./scripts/install-apps.sh --profile my-custom
```

## Migrating from Legacy Brewfile

The repository maintains backward compatibility. If you don't specify a profile or bundles, the MDM script will use the legacy `brew/Brewfile` if it exists.

To migrate to the modular system:

1. Choose a profile that matches your needs
2. Update `scripts/mdm-deploy.sh`:

   ```bash
   INSTALL_PROFILE="everything"
   ```

3. Test locally first:

   ```bash
   ./scripts/install-apps.sh --profile everything
   ```

4. Deploy via MDM

## Module Dependencies

Some modules work well together:

- **All profiles should include `base`** - Contains essential tools
- **`development`** includes both Brewfile and Appfile automatically
- **`creative`** and **`av-studio`** both include App Store apps for professional work
- **`entertainment`** includes both Homebrew packages and App Store games

The module system automatically installs all file types for each specified module.

## Package Counts by Profile

| Profile | Approximate Package Count |
|---------|--------------------------|
| base | 40 |
| creative | 50 |
| kids | 50 |
| work | 50 |
| everything | 210+ |

## Best Practices

1. **Start with a profile** - Use pre-defined profiles for common use cases
2. **Base is essential** - Always include the `base` module
3. **Test locally** - Test module installations before MDM deployment
4. **Document custom modules** - Add comments to explain what's included in each file type
5. **Keep modules focused** - Each module should serve a specific purpose
6. **Use all file types** - Leverage Brewfile, Appfile, and scripts as needed for complete installations
7. **Use profiles for MDM** - Easier to maintain than custom module lists

## Troubleshooting

### Module not found

```bash
# List available modules and their file types
./scripts/install-apps.sh --list-bundles

# Check if module files exist
ls brew/bundles/<module>.*
```

### Profile not found

```bash
# List available profiles
./scripts/install-apps.sh --list-profiles

# Check profiles.conf
cat brew/profiles/profiles.conf
```

### Installation fails

- Check individual module files (Brewfile, Appfile, .sh) for syntax
- Validate Brewfile with: `brew bundle check --file=brew/bundles/<module>.Brewfile`
- Validate Appfile with: `brew bundle check --file=brew/bundles/<module>.Appfile`
- Check custom script permissions: `ls -l brew/bundles/<module>.sh`
- Check Homebrew logs

## Examples

### Everything Profile

```bash
./scripts/install-apps.sh --profile everything
```

Installs: All available modules with all their file types

### Creative Workstation

```bash
./scripts/install-apps.sh --profile creative
```

Installs: Base tools + creative module (Brewfile + Appfile)

### Work Profile

```bash
./scripts/install-apps.sh --profile work
```

Installs: Base tools + work tools + communication apps

### Custom Combination

```bash
./scripts/install-apps.sh --bundles "base development av-studio"
```

Installs: Only the specified modules (each with all their file types)

### MDM Deployment

Edit `scripts/mdm-deploy.sh`:

```bash
INSTALL_PROFILE="everything"
```

Deploy via ScaleFusion - installs all modules

## Support

For questions or issues with the bundle system:

1. Check this documentation
2. Review bundle Brewfiles in `brew/bundles/`
3. Review profile definitions in `brew/profiles/profiles.conf`
4. Test locally before MDM deployment
