# Dotfiles Repository

This is the dotfiles for McCain family MacOS systems. It also features a flexible profile and app bundle system for customized installation of applications.

📚 **[Read the Full Documentation](https://mccainfamily.github.io/dotfiles/)**

---

## 🚀 Quick Start

### One-Line Installation (Recommended)

Install dotfiles with a single command - no cloning required:

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash
```

This will:

- Clone the repository to `~/.dotfiles`
- Install Homebrew in your user account
- Install the base bundle (essential tools)
- Configure your shell and terminal

### Install with a Different Profile

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --profile everything
```

Available profiles: `base`, `everything`, `creative`, `kids`, `work`

### Install Specific Bundles

```bash
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash -s -- --bundles "base development creative"
```

### Manual Installation

If you prefer to clone first:

```bash
git clone https://github.com/mccainfamily/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./scripts/user-install.sh --profile everything
```

---

## 🎯 Modular Bundle System

Install only what you need with specialized modules and pre-defined profiles:

- **Profiles**: Ready-to-use configurations (base, everything, creative, work, etc.)
- **Modules**: Individual tool categories you can mix and match
- **Multi-type**: Each module can include Homebrew packages, App Store apps, and custom scripts
- **Flexible**: Choose a profile or create custom combinations
- **Efficient**: Install packages based on your needs

### Module Structure

Each module named `<module>` can have up to three file types:

- `<module>.Brewfile` - Homebrew formulas and casks
- `<module>.Appfile` - Mac App Store applications
- `<module>.sh` - Custom installation scripts

When you specify a module by name, **all available file types** for that module are installed automatically.

### Available Profiles

- `base` - Essential tools only
- `everything` - All bundles (power user setup)
- `creative` - Base + creative tools
- `kids` - Base + entertainment
- `work` - Base + work tools + communication

### List All Options

After installation, explore what's available:

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --list-profiles
./scripts/install-apps.sh --list-bundles
```

### Install Additional Bundles Later

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --bundles "development av-studio"
```

---

## What's Included

### Available Modules

- **base** - Essential Unix tools, shell, Git, modern CLI tools (Brewfile + Script)
- **development** - Programming languages, IDEs, dev tools, databases (Brewfile + Appfile)
- **creative** - Design and creative tools, Logic Pro, OmniGraffle (Brewfile + Appfile)
- **av-studio** - Audio/video editing and live production: OBS, NDI, Stream Deck, Final Cut Pro, X32-Mix (Brewfile + Appfile + Script)
- **communication** - Zoom, Teams, Slack, Discord, Signal, WhatsApp (Brewfile)
- **entertainment** - Games, Spotify, Audible, djay Pro, VirtualDJ, Endel (Brewfile + Appfile)
- **work** - Professional tools and VPN (Brewfile)
- **network-security** - Network scanning, packet analysis, VPN tools (Brewfile)
- **cloud-infrastructure** - AWS, K8s, Terraform, Docker (Brewfile)
- **security-privacy** - Encryption, security tools (Brewfile)
- **diagrams** - PlantUML, Mermaid, Graphviz (Brewfile)
- **monitoring** - Prometheus, Grafana, observability, AvertX Remote (Brewfile + Appfile)

## Repository Structure

```
dotfiles/
├── README.md
├── LICENSE
├── brew/
│   ├── Brewfile              # Legacy full Brewfile
│   ├── bundles/              # Modular bundle Brewfiles
│   └── profiles/             # Profile definitions
├── config/
│   ├── starship.toml         # Starship prompt config
│   └── ssh_config            # SSH configuration
├── scripts/
│   ├── install.sh            # Manual installation
│   ├── install-apps.sh    # Bundle installer
│   ├── mdm-deploy.sh         # MDM deployment script
│   ├── brew-sync.sh          # Sync installed packages
│   ├── update.sh             # Update all packages
│   └── update-and-pr.sh      # Update and create PR
└── docs/                     # GitBook documentation
```

## Features

### Essential Base Tools

- Modern CLI tools: eza, bat, ripgrep, fd, fzf
- Ghostty terminal with developer-optimized config
- Starship prompt with cloud/K8s segments
- Zsh with autosuggestions and syntax highlighting
- SSH macOS Keychain integration

### Network & Security

- Comprehensive scanning tools (nmap, masscan, zmap)
- Packet analysis (Wireshark, tcpdump, tshark)
- VPN tools (Tailscale, WireGuard, OpenVPN, FortiClient)
- SSL/TLS utilities

### Cloud & Infrastructure

- AWS, GCP, Azure CLI tools
- Kubernetes (kubectl, k9s, helm, stern)
- Infrastructure as Code (Terraform, Ansible, Pulumi)
- Container tools (Docker via OrbStack)

### Development

- Languages: Python, Node.js, Go, Rust
- IDEs: VS Code, GoLand, JetBrains Toolbox
- Version control: Git, GitHub CLI, Lazygit
- Databases: PostgreSQL, MySQL, Redis, SQLite

### Audio/Video Production

- OBS Studio with NDI plugin
- Final Cut Pro, Logic Pro
- Stream control (Elgato Stream Deck)
- Professional audio (Behringer X32, Shure wireless)
- NDI video suite

### Creative & Design

- OmniGraffle for diagrams
- PlantUML, Mermaid, Graphviz, D2
- DJ software (djay Pro, VirtualDJ)

### Communication & Work

- Video conferencing: Zoom, Teams
- Messaging: Slack, Discord, Signal, WhatsApp, Bluesky
- VPN: FortiClient, Tailscale

## Documentation

Full documentation is available at: **<https://mccainfamily.github.io/dotfiles/>**

- [Getting Started Guide](docs/getting-started/README.md)
- [Bundle System Guide](docs/bundle-system/README.md)
- [Deployment Guide](docs/deployment/README.md)
- [Configuration Guide](docs/configuration/README.md)
- [Quick Reference](docs/reference/quick-reference.md)
- [Troubleshooting](docs/troubleshooting.md)

---

## 🏢 MDM Deployment (Enterprise)

For automated deployment via ScaleFusion MDM to multiple users, see the [MDM Deployment Guide](docs/deployment/mdm.md).

The MDM deployment script (`scripts/mdm-deploy.sh`) is designed for:

- Multi-user macOS environments
- Centralized Homebrew installation (owned by admin)
- Automated profile-based deployments
- Configuration deployment to all users

**Individual users should use `user-install.sh` instead** - it installs Homebrew in their own account.

---

## Usage

### Install Additional Bundles

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --bundles "av-studio network-security"
```

### Install with Exclusions

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --profile everything --exclude "entertainment creative"
```

### Sync Current Setup

```bash
cd ~/.dotfiles
./scripts/brew-sync.sh
git add brew/Brewfile
git commit -m "Update packages"
git push
```

### Update Everything

```bash
cd ~/.dotfiles
./scripts/update.sh
```

### Create PR After Updates

```bash
cd ~/.dotfiles
./scripts/update-and-pr.sh "Add new security tools"
```

## Requirements

- macOS (tested on macOS 14+)
- Admin access for Homebrew installation
- Git

## License

MIT License - See [LICENSE](LICENSE) for details.

## Credits

Built with Homebrew, Starship, Ghostty, and OrbStack. Optimized for network engineering and cloud infrastructure operations.

## Contributing

See [CONTRIBUTING.md](docs/contributing.md) for contribution guidelines.
