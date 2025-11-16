# Idempotency Verification

This document describes the idempotency guarantees of the dotfiles installation system.

## What is Idempotency?

Idempotency means that running an operation multiple times produces the same result as running it once. For installation scripts, this means:

- Re-running installation won't break existing configurations
- Already-installed packages are skipped gracefully
- Existing files are preserved (with backups when necessary)
- Configuration changes are applied only when needed

## Idempotency Guarantees

### user-install.sh

**Git Repository Management:**

- ✅ If dotfiles directory exists and is a git repo, it will be updated (git pull)
- ✅ If update fails (local changes), script continues with warning
- ✅ Non-git directories are left unchanged with a warning

**Homebrew Installation:**

- ✅ Skips installation if Homebrew already exists
- ✅ Updates Homebrew only if not updated in last 24 hours
- ✅ Continues if update fails (network issues)

**Shell Environment:**

- ✅ Checks for existing shellenv entry before adding to profiles
- ✅ Won't duplicate Homebrew paths in shell startup files

**Configuration Symlinks:**

- ✅ Checks if symlink already points to correct location
- ✅ Only updates symlink if target has changed
- ✅ Backs up existing files with timestamps before symlinking
- ✅ Preserves permissions on SSH config files

**Directory Creation:**

- ✅ mkdir -p ensures directories are created only if missing
- ✅ Appropriate permissions set on sensitive directories (SSH: 700)

**VS Code CLI:**

- ✅ Checks if symlink already exists and points to correct location
- ✅ Only creates symlink if VS Code is installed
- ✅ Gracefully handles permission issues

### install-apps.sh

**Bundle Installation:**

- ✅ `brew bundle install` is idempotent by design
- ✅ Only installs missing packages from Brewfile/Appfile
- ✅ Skips already-installed packages automatically
- ✅ Updates existing packages if outdated

**Custom Scripts:**

- ✅ Custom bundle scripts (.sh files) are always executed
- ✅ Each custom script must implement its own idempotency checks

### base.sh

**eza Aliases:**

- ✅ Checks for existing `alias ls=` before adding
- ✅ Won't duplicate aliases in .zshrc or .bashrc
- ✅ Creates shell config files if they don't exist

**Starship Prompt:**

- ✅ Checks for existing `starship init` before adding
- ✅ Won't duplicate initialization code
- ✅ Verifies config file exists before setup

**Ghostty Terminal:**

- ✅ Checks if config already exists
- ✅ Preserves existing configurations completely
- ✅ Only creates new config if none exists

### av-studio.sh

**Shure Wireless Workbench:**

- ✅ Checks if application already installed at /Applications/
- ✅ Skips installation if found
- ✅ Provides manual instructions if direct download unavailable

## Testing Idempotency

To verify idempotency, run the installation twice:

```bash
# First run
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash

# Second run (should complete without errors)
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/user-install.sh | bash
```

### Expected Behavior on Second Run

1. **Git Repository:** Updates if possible, continues if not
2. **Homebrew:** Skips update if recently updated
3. **Packages:** Brew reports "already installed" for each package
4. **Symlinks:** Messages indicate "already linked correctly"
5. **Configs:** Existing configurations preserved
6. **Custom Scripts:** May run again but should detect existing state

### What Gets Updated vs Preserved

**Updated:**

- Git repository (pulled to latest)
- Homebrew package versions (if outdated)
- Symlink targets (if pointing to wrong location)

**Preserved:**

- Custom shell configurations in .zshrc/.bashrc
- Existing SSH keys and configurations
- Modified Ghostty settings
- Backed up config files (*.backup.TIMESTAMP)

## Safety Features

### Backup System

- Config files backed up with timestamp: `.backup.20250122-143015`
- Backups created only for regular files, not symlinks
- Backups preserved even on multiple runs

### Permission Handling

- SSH config chmod 600 (user read/write only)
- SSH directory chmod 700 (user access only)
- Graceful handling of permission denied errors

### Error Handling

- Scripts continue if non-critical operations fail
- Clear warning messages for failed operations
- Exit only on critical failures (git clone, Homebrew install)

## Best Practices for Custom Scripts

When creating custom bundle scripts (.sh files):

```bash
# Always check if already installed
if [ -d "/Applications/YourApp.app" ]; then
    log_warning "YourApp is already installed"
    return 0
fi

# Always check if configuration exists
if [ -f "${HOME}/.config/yourapp/config" ]; then
    log_info "YourApp config already exists, skipping"
    return 0
fi

# Use idempotent operations
mkdir -p "${CONFIG_DIR}"  # Creates only if missing
ln -sf source target       # Force creates symlink (safe)
```

## Troubleshooting

### "Directory exists but is not a git repository"

- Manually remove directory or move it: `mv ~/.dotfiles ~/.dotfiles.old`
- Re-run installation

### "Could not auto-update repository (may have local changes)"

- Review local changes: `cd ~/.dotfiles && git status`
- Commit or stash changes: `git stash`
- Re-run installation

### "Cannot write to /opt/homebrew/bin"

- Some operations require write access to Homebrew directory
- Either: Run `sudo chown -R $(whoami) /opt/homebrew` once
- Or: Run specific commands with sudo as shown in warnings

### Duplicate Aliases or Init Code

- Should not happen with current scripts
- If it does, manually edit .zshrc/.bashrc to remove duplicates
- Report as bug with output of `grep -n "alias ls\|starship init" ~/.zshrc`

## Version History

- **2025-01-22:** Full idempotency implementation
  - Git repo update instead of re-clone
  - Symlink target verification
  - Homebrew update throttling (24h)
  - Comprehensive state checking
