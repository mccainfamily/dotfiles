# Available Modules

This page provides a complete reference of all available modules in the dotfiles system.

## Module Structure

Each module uses a unified naming system where a single module name can have up to three file types:

- **`<module>.Brewfile`** - Homebrew formulas and casks
- **`<module>.Appfile`** - Mac App Store applications
- **`<module>.sh`** - Custom installation scripts

When you install a module, **all available file types** are installed automatically.

## Core Modules

### base (Brewfile + Script)

**Essential tools required for all users**

The base module is **required** and must be included in every profile. It provides the foundation for all other modules.

**Contents:**

- Unix utilities: coreutils, findutils, grep, sed, wget, curl, rsync
- Shell tools: bash, zsh, zsh-autosuggestions, zsh-syntax-highlighting, tmux, starship
- Basic dev tools: git, gh (GitHub CLI)
- Modern CLI tools: jq, yq, fzf, ripgrep, bat, eza, fd, htop, btop
- Terminal: Ghostty terminal emulator
- Browser: Google Chrome
- Fonts: Developer fonts (Fira Code, JetBrains Mono, etc.)

**Custom Script:** Configures shell environment, Starship prompt, and SSH integration

## Development Modules

### development (Brewfile + Appfile)

**Programming languages, IDEs, and development tools**

**Homebrew Packages:**

- Languages: Python (pyenv), Node.js (nvm), Go, Rust
- IDEs: Visual Studio Code, JetBrains Toolbox
- Version Control: lazygit, git-delta, gh
- API/Web: httpie, grpcurl, postman
- Databases: PostgreSQL, MySQL, Redis, SQLite
- Code Quality: shellcheck, hadolint, yamllint
- Build Tools: make, cmake, gradle, maven

**App Store:**

- GoLand (JetBrains IDE)
- Other development tools from Mac App Store

### cloud-infrastructure (Brewfile)

**Cloud platforms and Infrastructure as Code tools**

**Contents:**

- AWS: awscli, aws-vault, chamber, aws-sam-cli
- GCP: google-cloud-sdk
- Azure: azure-cli
- Kubernetes: kubectl, k9s, helm, kubectx, kubens, stern, kustomize
- IaC: terraform, terragrunt, ansible, pulumi, packer
- Containers: OrbStack (Docker Desktop replacement)
- Service Mesh: istioctl, linkerd

## Security & Network Modules

### network-security (Brewfile)

**Network scanning, packet analysis, and diagnostics**

**Contents:**

- Scanning: nmap, masscan, zmap, arp-scan, rustscan
- Packet Analysis: wireshark, tcpdump, tshark, ngrep
- Diagnostics: mtr, iperf3, speedtest-cli, bandwhich
- DNS: dig, dog, dnsmasq, dnstracer, dnsperf
- SSL/TLS: openssl, mkcert, certbot, cfssl
- VPN: wireguard-tools, openvpn, sshuttle
- Network Testing: hping, vegeta, wrk, ab
- Protocol Tools: socat, netcat

### security-privacy (Brewfile)

**Encryption, secure communications, and hardware security**

**Contents:**

- Encryption: gnupg, age, sops, pass
- Secrets: HashiCorp Vault CLI
- Anonymity: tor, torsocks, proxychains-ng
- Yubikey: yubikey-manager, ykman, yubikey-personalization, yubico-piv-tool, pam-u2f, libu2f-host, libfido2
- Browsers: Tor Browser, Brave Browser, Firefox
- Communications: Signal, Proton suite (VPN, Mail, Pass, Drive), Keybase
- Hardware Security: Yubico Authenticator, YubiKey Manager GUI, GPG Suite

## Creative & Media Modules

### creative (Brewfile + Appfile)

**Design and creative tools**

**Homebrew Packages:**

- cmatrix (fun terminal visualization)
- Image processing tools

**App Store:**

- Logic Pro (professional audio production)
- OmniGraffle (diagramming and design)

### av-studio (Brewfile + Appfile + Script)

**Audio/video editing, live production, and DJ software**

**Homebrew Packages:**

- OBS Studio (streaming and recording)
- NDI tools and plugins
- Stream utilities
- Audio/video codecs

**App Store:**

- Final Cut Pro (professional video editing)
- X32-Mix (Behringer mixer control)
- djay Pro (professional DJ software)
- VirtualDJ Home (DJ mixing)

**Custom Script:** Configures OBS plugins and NDI integration

### diagrams (Brewfile)

**Diagram and visualization tools**

**Contents:**

- CLI Tools: plantuml, mermaid-cli, graphviz, d2, ditaa
- GUI Tools: drawio, xmind, freeplane
- Use Cases: UML diagrams, C4 models, flowcharts, network diagrams, mind maps

## Communication & Entertainment

### communication (Brewfile)

**Video conferencing and messaging**

**Contents:**

- Video Conferencing: Zoom, Microsoft Teams
- Messaging: Slack, Discord, Signal
- Social: WhatsApp, Bluesky

### entertainment (Brewfile + Appfile)

**Music, audiobooks, and reading**

**Homebrew Packages:**

- Spotify (music streaming)
- Audible (audiobooks)
- Amazon Kindle (e-books)

**App Store:**

- Endel (personalized soundscapes for focus)

### games (Brewfile)

**Gaming platforms and games**

**Contents:**

- Steam (gaming platform)
- Game installers and launchers

**Note:** War Thunder can be installed via Steam or from <https://warthunder.com>

## Productivity & Work

### work (Brewfile)

**Professional tools and VPN**

**Contents:**

- FortiClient VPN
- Professional productivity applications
- Enterprise tools

### monitoring (Brewfile + Appfile)

**Metrics, observability, and monitoring tools**

**Homebrew Packages:**

- Prometheus (metrics collection)
- Grafana (visualization)
- Telegraf (metrics agent)
- Loki (log aggregation)
- Promtail (log collector)

**App Store:**

- AvertX Remote (security camera monitoring)

## Module File Type Reference

| Module | Brewfile | Appfile | Script |
|--------|----------|---------|--------|
| base | ✓ | | ✓ |
| network-security | ✓ | | |
| cloud-infrastructure | ✓ | | |
| development | ✓ | ✓ | |
| security-privacy | ✓ | | |
| diagrams | ✓ | | |
| monitoring | ✓ | ✓ | |
| creative | ✓ | ✓ | |
| av-studio | ✓ | ✓ | ✓ |
| communication | ✓ | | |
| entertainment | ✓ | ✓ | |
| games | ✓ | | |
| work | ✓ | | |

## Installing Modules

To install specific modules:

```bash
cd ~/.dotfiles
./scripts/install-apps.sh --bundles "base development creative"
```

Remember: When you specify a module name, all its file types (Brewfile, Appfile, and custom script) are installed automatically.

## Next Steps

- Learn about [Profiles](profiles.md) - pre-configured module combinations
- Create [Custom Modules](custom-bundles.md) for your specific needs
