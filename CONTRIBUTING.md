# Contributing to Dotfiles

Thank you for contributing to this dotfiles repository! This guide will help you set up your development environment and understand the workflow.

## Quick Start

Initialize your development environment with a single command:

```bash
make init
```

This will:

- Install Homebrew (if not already installed)
- Install the `dotfiles-dev` bundle (pre-commit, shellcheck, markdownlint, etc.)
- Install pre-commit git hooks

## Development Setup

### Prerequisites

- macOS (this dotfiles repository is macOS-specific)
- Git
- Basic command-line knowledge

### Initial Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/mccainfamily/dotfiles.git
   cd dotfiles
   ```

2. **Initialize development environment:**

   ```bash
   make init
   ```

   This single command will:
   - Install Homebrew if needed (via `scripts/single-user-homebrew-install.sh`)
   - Install the `dotfiles-dev` bundle with all development tools
   - Set up pre-commit git hooks

   Or manually:

   ```bash
   make install-deps    # Install Homebrew + dotfiles-dev bundle
   make install-hooks   # Install pre-commit hooks
   ```

3. **Verify setup:**

   ```bash
   make check          # Run all validation checks
   ```

## Development Workflow

### Making Changes

1. **Create a new branch:**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes:**
   - Add/modify Brewfiles in `brew/bundles/`
   - Update profiles in `brew/profiles/profiles.conf`
   - Add custom scripts if needed

3. **Validate your changes:**

   ```bash
   make check          # Run all validation checks
   ```

4. **Test your changes:**

   ```bash
   # Test a specific bundle
   make show-bundle BUNDLE=base

   # Test installation (dry-run recommended first)
   bash scripts/install-apps.sh --help
   ```

5. **Commit your changes:**

   ```bash
   git add .
   git commit -m "feat: add new data-science bundle"
   # Pre-commit hooks will run automatically
   ```

### Conventional Commits

This repository enforces [Conventional Commits](https://www.conventionalcommits.org/) format for all commit messages. This ensures clear, consistent commit history and enables automated changelog generation.

#### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Commit Types

- **feat:** A new feature
- **fix:** A bug fix
- **docs:** Documentation only changes
- **style:** Changes that don't affect code meaning (whitespace, formatting)
- **refactor:** Code change that neither fixes a bug nor adds a feature
- **perf:** Performance improvement
- **test:** Adding missing tests or correcting existing tests
- **build:** Changes to build system or dependencies
- **ci:** Changes to CI configuration files and scripts
- **chore:** Other changes that don't modify src or test files

#### Examples

```bash
# Adding a new bundle
git commit -m "feat: add data-science bundle with Python tools"

# Fixing a bug
git commit -m "fix: resolve shellcheck warning in base.sh"

# Documentation update
git commit -m "docs: update CONTRIBUTING.md with bundle examples"

# Updating dependencies
git commit -m "chore: update pre-commit hooks to latest versions"

# With scope
git commit -m "feat(bundles): add microcontrollers bundle for Arduino/RPi"

# With body
git commit -m "fix: remove --no-lock flag from install-apps.sh

The --no-lock flag is not supported in older versions of Homebrew
Bundle, causing installation failures on some systems."
```

#### Enforcement

The conventional commits format is enforced by a pre-commit hook. If your commit message doesn't follow the format, the commit will be rejected with a helpful error message.

To fix a rejected commit:

```bash
# Amend your commit message
git commit --amend

# Or use the --no-verify flag (not recommended)
git commit --no-verify -m "your message"
```

### Pre-commit Hooks

Pre-commit hooks run automatically before each commit to ensure code quality:

- **Conventional commits:** Enforces commit message format
- **File checks:** Large files, merge conflicts, trailing whitespace
- **Shell script validation:** Shellcheck linting
- **Markdown linting:** markdownlint
- **Secret detection:** Prevents accidental credential commits
- **Brewfile validation:** Ensures Brewfiles are syntactically correct
- **YAML validation:** Validates configuration files

#### Running hooks manually

```bash
# Run all hooks on all files
make pre-commit-run

# Run specific hook
pre-commit run <hook-id> --all-files

# Update hooks to latest versions
make pre-commit-update
```

## Repository Structure

```
dotfiles/
├── brew/
│   ├── bundles/           # Individual software bundles
│   │   ├── *.Brewfile     # Homebrew packages
│   │   ├── *.Appfile      # Mac App Store apps
│   │   ├── *.sh           # Custom installation scripts
│   │   └── dotfiles-dev.Brewfile  # Development tools for this repo
│   └── profiles/
│       └── profiles.conf  # Installation profiles
├── scripts/               # Utility scripts
│   ├── install-apps.sh    # Main installation script
│   ├── single-user-homebrew-install.sh  # Homebrew installer
│   └── user-install.sh    # User setup script
├── config/                # Configuration files
├── .pre-commit-config.yaml # Pre-commit hook configuration
├── Makefile               # Development tasks
└── README.md              # User documentation
```

### Development Bundle

The `dotfiles-dev` bundle contains all tools needed for developing this repository:

- **pre-commit**: Git hooks framework
- **shellcheck**: Shell script linter
- **markdownlint-cli**: Markdown linter
- **yamllint**: YAML linter
- **detect-secrets**: Secret detection tool

This bundle is automatically installed when you run `make init`.

## Creating New Bundles

### 1. Create a Brewfile

```bash
# Example: Create a new bundle for data science tools
cat > brew/bundles/data-science.Brewfile << 'EOF'
# Data Science Bundle
# Tools for data analysis and machine learning

brew "python"
brew "jupyter"
brew "numpy"
cask "rstudio"
EOF
```

### 2. (Optional) Create an Appfile

```bash
cat > brew/bundles/data-science.Appfile << 'EOF'
# Mac App Store applications for data science
# (Currently no MAS apps for data science)
EOF
```

### 3. (Optional) Create a custom script

```bash
cat > brew/bundles/data-science.sh << 'EOF'
#!/bin/bash
# Custom setup for data science tools
pip install pandas scikit-learn matplotlib
EOF

chmod +x brew/bundles/data-science.sh
```

### 4. Update profiles.conf

```bash
# Add to brew/profiles/profiles.conf
# In the "Available Modules" section:
#   - data-science         : Data analysis and machine learning tools

# Add to PROFILE_EVERYTHING if appropriate:
PROFILE_EVERYTHING="base ... data-science"
```

### 5. Validate and test

```bash
make check
bash scripts/install-apps.sh --show-bundle data-science
```

## Makefile Commands

The Makefile provides commands for **development tasks only**. For installing applications, use `install-apps.sh` directly.

### Setup Commands

| Command | Description |
|---------|-------------|
| `make init` | Initialize complete development environment |
| `make install-deps` | Install development dependencies |
| `make install-hooks` | Install pre-commit git hooks |

### Validation Commands

| Command | Description |
|---------|-------------|
| `make check` | Run all validation checks |
| `make validate-brewfiles` | Validate Brewfile syntax |
| `make validate-scripts` | Validate shell scripts |
| `make validate-yaml` | Validate YAML files |
| `make test` | Alias for `check` |

### Maintenance Commands

| Command | Description |
|---------|-------------|
| `make fix-permissions` | Fix script file permissions |
| `make clean` | Clean up temporary files |
| `make update-secrets-baseline` | Update secrets detection baseline |

### Documentation Commands

| Command | Description |
|---------|-------------|
| `make help` | Display all available commands |

### Installation Commands (use install-apps.sh)

For installing applications and viewing bundles, use the `install-apps.sh` script directly:

```bash
# List available options
bash scripts/install-apps.sh --list-profiles
bash scripts/install-apps.sh --list-bundles

# Show bundle contents
bash scripts/install-apps.sh --show-bundle base

# Install using a profile
bash scripts/install-apps.sh --profile work

# Install specific bundles
bash scripts/install-apps.sh --bundles "base development"

# Install with exclusions
bash scripts/install-apps.sh --profile everything --exclude "entertainment games"

# Get help
bash scripts/install-apps.sh --help
```

## Testing

### Test Brewfile Syntax

```bash
make validate-brewfiles
```

### Test Shell Scripts

```bash
make validate-scripts
```

### Test Installation (Dry Run)

```bash
# Review what would be installed
bash scripts/install-apps.sh --profile base
```

### Run Pre-commit Hooks

```bash
make pre-commit-run
```

## Code Style Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Include descriptive header comments
- Use shellcheck-compliant code
- Make scripts executable: `chmod +x script.sh`
- Use the logging functions from base.sh:

  ```bash
  log_info "Information message"
  log_success "Success message"
  log_warning "Warning message"
  log_error "Error message"
  ```

### Brewfiles

- Add comments describing packages
- Group related packages with section headers
- Use consistent formatting:

  ```ruby
  brew "package-name"    # Description
  cask "app-name"        # Description
  ```

### Markdown

- Use consistent heading levels
- Include code blocks with language specification
- Keep lines under 120 characters when possible
- Fix issues reported by markdownlint

## Troubleshooting

### Pre-commit hooks fail

```bash
# See what failed
git commit -v

# Fix permissions
make fix-permissions

# Re-run validation
make check
```

### Shellcheck errors

```bash
# Run shellcheck directly
shellcheck brew/bundles/your-script.sh

# See specific rule
shellcheck --wiki
```

### Secret detection false positives

```bash
# Update the baseline to exclude false positives
make update-secrets-baseline
```

## Getting Help

- **Makefile commands:** `make help`
- **Installation script:** `bash scripts/install-apps.sh --help`
- **Pre-commit hooks:** `pre-commit --help`
- **Issues:** Open an issue on GitHub

## Pull Request Process

1. Ensure all validation checks pass: `make check`
2. Update documentation if needed
3. Commit with conventional commit messages (see [Conventional Commits](#conventional-commits))
4. Pre-commit hooks will run automatically
5. Push to your fork and create a pull request
6. Ensure CI checks pass (if configured)
7. PR title should also follow conventional commits format

## License

See [LICENSE](LICENSE) file for details.
