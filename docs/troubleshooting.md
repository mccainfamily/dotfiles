# Troubleshooting

Common issues and their solutions.

## Installation Issues

### Homebrew Not Found

**Issue**: Command `brew` not found after installation

**Solution**:
\`\`\`bash

# For Apple Silicon

eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel

eval "$(/usr/local/bin/brew shellenv)"

# Reload shell

source ~/.zshrc
\`\`\`

### Permission Denied

**Issue**: Permission errors during installation

**Solution**:
\`\`\`bash

# Fix Homebrew permissions

sudo chown -R $(whoami) /opt/homebrew/*  # Apple Silicon
sudo chown -R $(whoami) /usr/local/*      # Intel
\`\`\`

### Bundle Not Found

**Issue**: "Bundle 'X' not found"

**Solution**:
\`\`\`bash

# List available bundles

./scripts/install-apps.sh --list-bundles

# Check if bundle file exists

ls brew/bundles/
\`\`\`

## Runtime Issues

### Starship Prompt Not Showing

**Issue**: Terminal prompt doesn't show Starship

**Solution**:
\`\`\`bash

# Verify installation

which starship
starship --version

# Check .zshrc has init

grep "starship init" ~/.zshrc

# Reload shell

source ~/.zshrc
\`\`\`

### SSH Keys Not Loading

**Issue**: SSH keys not automatically loaded

**Solution**:
\`\`\`bash

# Add key to macOS Keychain

ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Verify SSH config

cat ~/.ssh/config

# Test connection

ssh -T <git@github.com>
\`\`\`

### Tools Not in PATH

**Issue**: Installed tools not found in PATH

**Solution**:
\`\`\`bash

# Check PATH

echo $PATH | tr ':' '\n'

# Verify Homebrew in PATH

which brew

# Reload shell

source ~/.zshrc
\`\`\`

## Package Issues

### Package Installation Failed

**Issue**: Some packages failed to install

**Solution**:
\`\`\`bash

# Check Homebrew health

brew doctor

# Try installing package manually

brew install package-name

# Check logs

brew install package-name --verbose --debug
\`\`\`

### Cask Installation Requires Password

**Issue**: Cask installations keep asking for password

**Solution**: This is normal for GUI applications that need to be installed in /Applications.

## MDM Deployment Issues

### Temporary Sudo Still Present

**Issue**: Temporary sudo file not removed after 2 hours

**Solution**:
\`\`\`bash

# Manual removal

sudo rm /etc/sudoers.d/homebrew-cask-temp
\`\`\`

### Deployment Logs

**Location**: `/var/log/mdm-dotfiles-deploy.log`

\`\`\`bash

# View logs

tail -100 /var/log/mdm-dotfiles-deploy.log

# Follow logs in real-time

tail -f /var/log/mdm-dotfiles-deploy.log

# Search for errors

grep -i error /var/log/mdm-dotfiles-deploy.log
\`\`\`

## Network Tools Issues

### Wireshark Requires Admin

**Issue**: Wireshark needs admin for packet capture

**Solution**:
\`\`\`bash

# Add current user to access_bpf group

sudo dseditgroup -o edit -a $(whoami) -t user access_bpf
\`\`\`

### OrbStack Not Starting

**Issue**: OrbStack doesn't launch

**Solution**:
\`\`\`bash

# Check installation

brew list --cask | grep orbstack

# Reinstall

brew reinstall --cask orbstack

# Open manually

open -a OrbStack
\`\`\`

## Configuration Issues

### Git Not Using Correct Email

**Issue**: Git commits use wrong email

**Solution**:
\`\`\`bash

# Configure globally

git config --global user.email "<your@email.com>"
git config --global user.name "Your Name"

# Or edit config directly

nano ~/.gitconfig
\`\`\`

### Starship Config Not Loading

**Issue**: Starship configuration changes not applied

**Solution**:
\`\`\`bash

# Check config location

ls -la ~/.config/starship.toml

# Verify it's linked correctly

readlink ~/.config/starship.toml

# Reload shell

source ~/.zshrc
\`\`\`

## Getting More Help

Still having issues?

1. Check the [FAQ](faq.md)
2. Review [configuration guide](configuration/README.md)
3. Check [GitHub Issues](https://github.com/mccainfamily/dotfiles/issues)
4. Enable verbose logging and check logs
