# Quick Start

Get up and running in 5 minutes.

## TL;DR

\`\`\`bash

# Clone and install

git clone <https://github.com/mccainfamily/dotfiles.git> ~/.dotfiles
cd ~/.dotfiles
./scripts/install-apps.sh --profile developer

# Restart terminal

source ~/.zshrc
\`\`\`

Done! See [First Steps](first-steps.md) for what to do next.

## Quick Commands

### List Available Options

\`\`\`bash
./scripts/install-apps.sh --list-profiles
./scripts/install-apps.sh --list-bundles
\`\`\`

### Install a Profile

\`\`\`bash
./scripts/install-apps.sh --profile network-engineer
\`\`\`

### Install Custom Bundles

\`\`\`bash
./scripts/install-apps.sh --bundles "base development diagrams"
\`\`\`

### Update Packages

\`\`\`bash
./scripts/update.sh
\`\`\`

### Sync Installed Packages

\`\`\`bash
./scripts/brew-sync.sh
\`\`\`

## Next Steps

- [Configure your environment](../configuration/README.md)
- [Learn about bundles](../bundle-system/README.md)
- [Explore installed tools](../reference/packages.md)
