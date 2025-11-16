# First Steps

What to do after installation.

## 1. Verify Installation

\`\`\`bash
brew --version
starship --version
git --version
\`\`\`

## 2. Configure Git

\`\`\`bash
git config --global user.name "Your Name"
git config --global user.email "<your@email.com>"
\`\`\`

## 3. Set Up SSH Keys

\`\`\`bash

# Generate key if needed

ssh-keygen -t ed25519 -C "<your@email.com>"

# Add to macOS Keychain

ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Copy public key

cat ~/.ssh/id_ed25519.pub | pbcopy
\`\`\`

## 4. Explore Your Tools

Check what's installed:
\`\`\`bash
brew list
\`\`\`

## 5. Customize

Create machine-specific config:
\`\`\`bash
nano ~/.zshrc.local
\`\`\`

## 6. Learn More

- [Configuration Guide](../configuration/README.md)
- [Quick Reference](../reference/quick-reference.md)
- [Available Packages](../reference/packages.md)
