# Development

Information for developers working on the dotfiles system.

## Repository Structure

\`\`\`
dotfiles/
├── brew/
│   ├── bundles/          # Individual bundle Brewfiles
│   └── profiles/         # Profile configurations
├── config/              # Configuration files
├── scripts/             # Installation scripts
└── docs/                # GitBook documentation
\`\`\`

## Creating New Bundles

1. Create a new Brewfile in `brew/bundles/`:
\`\`\`bash
cat > brew/bundles/my-bundle.Brewfile << 'BUNDLEEOF'

# My Bundle Description

brew "tool1"
brew "tool2"
cask "app1"
BUNDLEEOF
\`\`\`

2. Add to a profile in `brew/profiles/profiles.conf`

3. Test installation

## Testing

Test locally before deployment:
\`\`\`bash
./scripts/install-apps.sh --bundles "your-bundle"
\`\`\`

## Documentation

Update docs when adding features:

- Add bundle descriptions
- Update profile tables
- Add troubleshooting tips
