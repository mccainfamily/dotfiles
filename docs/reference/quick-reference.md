# Dotfiles Quick Reference

## Essential Commands

### Diagram Creation

```bash
# PlantUML (UML, C4)
plantuml diagram.puml

# Mermaid (Flowcharts)
mmdc -i flow.mmd -o flow.png

# Graphviz (Network diagrams)
dot -Tpng network.dot -o network.png

# D2 (Modern diagrams)
d2 system.d2 output.svg
```

### VS Code

```bash
code .                  # Open current directory
code file.txt          # Open file
c.                     # Alias for code .
```

### Go Development

```bash
cd ~/src/github.com    # Your projects
go build              # Build project
go test               # Run tests
```

### SSH Management

```bash
# Add key to keychain (one-time)
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# List loaded keys
ssh-add -l

# Test GitHub
ssh -T git@github.com
```

### PR Automation

```bash
cd ~/.dotfiles
./scripts/update-and-pr.sh "Add new tools"
```

### Proton Suite

```bash
open -a "Proton Mail"
open -a "Proton Pass"
open -a "Proton Drive"
open -a ProtonVPN
```

### Yubikey

```bash
ykman info                          # Device info
ykman oath accounts list            # List 2FA accounts
ykman oath accounts code GitHub     # Get 2FA code
yk-code                            # Quick OTP
```

### Network Tools

```bash
nmap -sn 192.168.1.0/24            # Network scan
sudo tcpdump -i en0                # Packet capture
mtr google.com                     # Trace route
speedtest                          # Speed test
```

### Kubernetes

```bash
k get pods                         # List pods
kctx                              # Switch context
kns                               # Switch namespace
k9s                               # K8s TUI
```

### Docker/OrbStack

```bash
d ps                              # List containers
dc up                             # Compose up
orb                               # OrbStack GUI
```

### Security

```bash
gpg --list-keys                   # List GPG keys
gpg-enc file.txt recipient@email  # Encrypt file
tor-status                        # Check Tor
```

## File Locations

| Item | Location |
|------|----------|
| Dotfiles | `~/.dotfiles` |
| Go Projects | `~/src/github.com` |
| SSH Config | `~/.ssh/config` |
| Starship Config | `~/.config/starship.toml` |
| Ghostty Config | `~/.config/ghostty/config` |
| Local Customizations | `~/.zshrc.local` |

## Deployment

### Configure MDM Script

Edit `scripts/mdm-deploy.sh`:

```bash
DOTFILES_REPO="https://github.com/YOUR_USERNAME/dotfiles.git"
```

### Deploy via ScaleFusion

```bash
curl -fsSL https://raw.githubusercontent.com/YOU/dotfiles/main/scripts/mdm-deploy.sh | sudo bash
```

## Update Workflow

1. Install new tools: `brew install tool`
2. Create PR: `./scripts/update-and-pr.sh "Add tool"`
3. Review and merge on GitHub

## Package Categories

- **Network Security**: 30+ tools (nmap, wireshark, etc.)
- **Secure Communications**: 15+ tools (Signal, Proton suite, etc.)
- **Yubikey**: 10+ tools
- **Cloud/IaC**: 25+ tools (AWS, K8s, Terraform)
- **Development**: 50+ tools
- **Diagrams**: 5+ tools (PlantUML, Mermaid, etc.)
- **Total**: 210+ packages

## Support

- [README.md](README.md) - Full documentation
- [MDM_DEPLOYMENT.md](MDM_DEPLOYMENT.md) - Deployment guide
- Logs: `/var/log/mdm-dotfiles-deploy.log`
