# Frequently Asked Questions

## General Questions

### What is this dotfiles repository?

A modular, role-based development environment for macOS with 210+ packages organized into bundles and profiles. It's optimized for network engineering, DevOps, and cloud infrastructure work.

### Do I need to install everything?

No! That's the point of the bundle system. Choose a profile that matches your needs, or select specific bundles.

### Can I use this on multiple Macs?

Yes! That's one of the main use cases. Sync your changes via Git and deploy to multiple machines.

### Is this only for network engineers?

No. While optimized for network/cloud work, there are profiles for developers, security professionals, creative work, and general use.

## Installation Questions

### Do I need admin access?

Yes, admin access is required to install Homebrew and system packages.

### How long does installation take?

10-60 minutes depending on the profile and your internet speed.

### Can I uninstall everything?

Yes. Use `brew uninstall` for individual packages or `brew bundle cleanup` to remove packages not in the Brewfile.

### Will this overwrite my existing configuration?

Existing config files are backed up with a `.backup` extension before being replaced.

## Bundle and Profile Questions

### What's the difference between bundles and profiles?

- **Bundles** are collections of related packages (e.g., "network-security")
- **Profiles** are pre-configured combinations of bundles (e.g., "network-engineer" = base + network-security + cloud-infrastructure + more)

### Can I create my own profile?

Yes! Edit `brew/profiles/profiles.conf` and add your own profile definition.

### Can I mix profiles?

No, choose one profile. But you can create a custom profile that combines what you need.

### What if I only want a few specific tools?

Use custom bundle selection:
\`\`\`bash
./scripts/install-apps.sh --bundles "base development"
\`\`\`

## Package Management Questions

### How do I add new packages?

1. Install manually: `brew install package-name`
2. Sync to Brewfile: `./scripts/brew-sync.sh`
3. Commit changes: `git add brew/Brewfile && git commit`

### How do I update packages?

\`\`\`bash
./scripts/update.sh
\`\`\`

### How do I remove packages?

\`\`\`bash
brew uninstall package-name
./scripts/brew-sync.sh
\`\`\`

## Configuration Questions

### Where are configuration files stored?

- Dotfiles repo: `~/.dotfiles/config/`
- Your home: Symlinks pointing to the repo

### Can I customize configurations?

Yes! Edit files in `~/.dotfiles/config/` or create `~/.zshrc.local` for machine-specific settings.

### How do I update configurations?

Edit files in the repo, commit, and push. Pull on other machines.

## MDM Deployment Questions

### What is MDM deployment?

Mobile Device Management deployment for automated setup on managed Macs via ScaleFusion.

### Do I need MDM?

No, MDM is optional for enterprise use. Manual installation works fine.

### Can I use other MDM solutions?

The scripts are designed for ScaleFusion but can be adapted for other MDMs.

## Troubleshooting Questions

### A package failed to install, what now?

Check `brew doctor` for issues, then try installing the package manually with `brew install package-name --verbose`.

### Starship prompt isn't showing

Make sure it's installed (`starship --version`) and `~/.zshrc` has the init line. Reload with `source ~/.zshrc`.

### SSH keys aren't loading automatically

Add to macOS Keychain:
\`\`\`bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
\`\`\`

## Security Questions

### Is it safe to store dotfiles in Git?

Yes, but **never commit**:

- SSH private keys
- API tokens or secrets
- `.env` files with credentials

### What about the Proton suite and security tools?

These are included in the `security-privacy` bundle for enhanced privacy and security.

### Why does the MDM script need sudo?

Homebrew and cask installations require admin privileges to install to system directories.

## Contributing Questions

### Can I contribute to this project?

Yes! See the [Contributing Guide](contributing.md).

### How do I report bugs?

Open an issue on [GitHub](https://github.com/mccainfamily/dotfiles/issues).

### Can I fork this for my own use?

Absolutely! It's MIT licensed. Fork and customize as needed.

## Still Have Questions?

- Check the [Troubleshooting Guide](troubleshooting.md)
- Review the [Configuration Guide](configuration/README.md)
- Open an issue on GitHub
