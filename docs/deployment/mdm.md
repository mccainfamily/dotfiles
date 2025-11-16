# MDM Deployment

Complete guide for deploying dotfiles via Mobile Device Management (MDM) systems.

## Overview

The `mdm-deploy.sh` script provides enterprise-grade dotfiles deployment:

✅ Clones dotfiles repository  
✅ Installs Homebrew centrally (owned by admin user)  
✅ Installs packages via modular bundle system  
✅ Deploys configs to all users on the system  
✅ Complete audit logging  
✅ Environment variable configuration  
✅ Idempotent - safe to run multiple times  

## Supported MDM Platforms

- Jamf Pro
- Kandji
- ScaleFusion  
- Mosyle
- Any MDM that supports script execution as root

## Quick Start

### Basic MDM Script

Create a script in your MDM platform:

```bash
#!/bin/bash

# Download deployment script
curl -fsSL https://raw.githubusercontent.com/mccainfamily/dotfiles/main/scripts/mdm-deploy.sh -o /tmp/mdm-deploy.sh
chmod +x /tmp/mdm-deploy.sh

# Run deployment
/tmp/mdm-deploy.sh 2>&1 | tee /var/log/mdm-dotfiles-deploy.log

# Cleanup
rm /tmp/mdm-deploy.sh

exit 0
```

**Run As:** Root  
**Trigger:** Manual, on enrollment, or recurring

### Customized Deployment

Configure via environment variables:

```bash
#!/bin/bash

# Configuration
export DOTFILES_REPO="https://github.com/YOUR_ORG/dotfiles.git"
export DOTFILES_BRANCH="production"
export ADMIN_USER="localadmin"
export INSTALL_PROFILE="work"
export EXCLUDE_BUNDLES="entertainment creative"

# Download and run
curl -fsSL https://raw.githubusercontent.com/YOUR_ORG/dotfiles/production/scripts/mdm-deploy.sh -o /tmp/mdm-deploy.sh
chmod +x /tmp/mdm-deploy.sh
/tmp/mdm-deploy.sh 2>&1 | tee /var/log/mdm-dotfiles-deploy.log
rm /tmp/mdm-deploy.sh

exit 0
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_REPO` | `https://github.com/mccainfamily/dotfiles.git` | Git repository URL |
| `DOTFILES_BRANCH` | `main` | Branch to checkout |
| `ADMIN_USER` | `${SUDO_USER}` or `administrator` | User who will own Homebrew |
| `DEPLOY_TO_ALL_USERS` | `true` | Deploy configs to all users |
| `INSTALL_PROFILE` | `everything` | Profile to install |
| `INSTALL_BUNDLES` | (empty) | Specific bundles to install |
| `EXCLUDE_BUNDLES` | (empty) | Bundles to exclude from profile |

### Profile vs Bundles

**Using a Profile (Recommended):**

```bash
export INSTALL_PROFILE="work"
```

**Using Specific Bundles:**

```bash
export INSTALL_PROFILE=""  # Clear profile
export INSTALL_BUNDLES="base development communication work"
```

**Excluding Bundles:**

```bash
export INSTALL_PROFILE="everything"
export EXCLUDE_BUNDLES="entertainment creative"
```

## Deployment Process

### Step 1: Pre-flight Checks

- Verifies script running as root
- Validates admin user exists
- Checks admin user is in admin group
- Detects macOS architecture (Apple Silicon vs Intel)

### Step 2: Clone Repository

Clones to `/var/root/.dotfiles`:

```bash
sudo -u root git clone -b ${DOTFILES_BRANCH} ${DOTFILES_REPO} /var/root/.dotfiles
```

### Step 3: Install Homebrew

Installs as admin user (not root):

- Apple Silicon: `/opt/homebrew`
- Intel: `/usr/local`

```bash
sudo -u ${ADMIN_USER} /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 4: Install Packages

Runs `install-apps.sh` with configured profile/bundles:

```bash
sudo -u ${ADMIN_USER} /var/root/.dotfiles/scripts/install-apps.sh --profile ${INSTALL_PROFILE}
```

This installs:

- Homebrew packages (.Brewfile files)
- Mac App Store apps (.Appfile files)
- Runs custom scripts (.sh files)

### Step 5: Deploy to All Users

For each user on the system:

**Creates symlinks:**

- `.zshrc` → `~/.dotfiles/config/.zshrc`
- `.bashrc` → `~/.dotfiles/config/.bashrc`
- `.bash_profile` → `~/.dotfiles/config/.bash_profile`
- `.gitconfig` → `~/.dotfiles/config/.gitconfig`
- `.ssh/config` → `~/.dotfiles/config/ssh_config`
- `.config/starship.toml` → `~/.dotfiles/config/starship.toml`

**Creates directories:**

- `~/src/github.com` (Go workspace)
- `~/.ssh/sockets` (SSH connection sharing)
- `~/.config` (XDG config dir)

### Step 6: Audit Logging

All actions logged to `/var/log/mdm-dotfiles-deploy.log`:

```
[2025-01-22 14:30:15] [AUDIT] [admin] [PID:12345] [DEPLOY_START] Beginning MDM deployment
[2025-01-22 14:30:16] [INFO] Cloning repository from https://github.com/mccainfamily/dotfiles.git
[2025-01-22 14:30:20] [INFO] Installing Homebrew as user: admin
[2025-01-22 14:35:42] [INFO] Installing profile: everything
[2025-01-22 14:55:10] [INFO] Deploying configs to user: admin
[2025-01-22 14:55:15] [INFO] Deploying configs to user: jdoe
[2025-01-22 14:55:18] [AUDIT] [admin] [PID:12345] [DEPLOY_COMPLETE] Deployment successful
```

## Platform-Specific Setup

### Jamf Pro

1. **Create Script:**
   - Go to Settings → Computer Management → Scripts
   - Click "+ New"
   - Paste MDM script
   - Set to run as root

2. **Create Policy:**
   - Go to Computers → Policies
   - Click "+ New"
   - Add script to policy
   - Set trigger (enrollment, recurring, self-service)
   - Scope to target computers

### ScaleFusion

1. **Go to Scripts:**
   - Dashboard → Scripts → Create Script

2. **Configure:**
   - Name: "Deploy Dotfiles"
   - OS: macOS
   - Run As: Root
   - Paste script content

3. **Deploy:**
   - Select target devices
   - Run immediately or schedule

### Kandji

1. **Create Custom Script:**
   - Library → Custom Scripts → New Script

2. **Configure:**
   - Execution Frequency: Once per device
   - Run As: root
   - Paste script

3. **Assign to Blueprint:**
   - Add to appropriate blueprint
   - Deploy to devices

## Customization

### Fork for Your Organization

1. **Fork Repository:**

   ```bash
   # On GitHub
   https://github.com/mccainfamily/dotfiles → Fork
   ```

2. **Customize:**
   - Edit bundles in `brew/bundles/`
   - Modify configs in `config/`
   - Update profiles in `brew/profiles/profiles.conf`

3. **Update MDM Script:**

   ```bash
   export DOTFILES_REPO="https://github.com/YOUR_ORG/dotfiles.git"
   export DOTFILES_BRANCH="main"
   export INSTALL_PROFILE="corporate-standard"
   ```

### Custom Profiles

Create organization-specific profiles in `brew/profiles/profiles.conf`:

```bash
# Corporate profiles
PROFILE_CORPORATE_DEV="base development cloud-infrastructure communication"
PROFILE_CORPORATE_ANALYST="base diagrams communication monitoring"
PROFILE_CORPORATE_EXEC="base communication entertainment"
```

Then deploy:

```bash
export INSTALL_PROFILE="corporate-dev"
```

### Custom Bundles

Create new bundles in `brew/bundles/`:

```bash
# File: brew/bundles/corporate-tools.Brewfile
tap "your-org/corporate"
brew "corporate-vpn-client"
brew "corporate-security-agent"

# Use in profile
PROFILE_CORPORATE="base corporate-tools communication"
```

## Security Considerations

### Homebrew Ownership

Homebrew installed as admin user, **not root**:

- ✅ Prevents privilege escalation
- ✅ Allows admin to manage packages
- ✅ Standard Homebrew best practice

### Configuration Deployment

- User home directories remain user-owned
- Symlinks created with correct ownership
- SSH directories set to `700` permissions
- SSH configs set to `600` permissions

### Audit Trail

Complete audit logging provides:

- Who triggered deployment (admin user)
- When deployment occurred
- What was installed
- Any errors or issues
- All actions sent to system log (`logger`)

### Repository Access

Consider using:

- Private GitHub repository for custom configurations
- Deploy keys with read-only access
- Personal access tokens with minimal scope

## Troubleshooting

### Check Deployment Log

```bash
sudo tail -f /var/log/mdm-dotfiles-deploy.log
```

### Verify Homebrew Installation

```bash
# As admin user
sudo -u admin /opt/homebrew/bin/brew --version

# Check ownership
ls -la /opt/homebrew
```

### Test Package Installation

```bash
# As admin user
sudo -u admin /opt/homebrew/bin/brew list
```

### Re-run Deployment

Safe to re-run - deployment is idempotent:

```bash
# Re-run via MDM or manually
sudo /var/root/.dotfiles/scripts/mdm-deploy.sh
```

### User Config Issues

```bash
# Check symlinks for specific user
ls -la /Users/username/.zshrc
ls -la /Users/username/.ssh/config

# Manually deploy to user
sudo -u username ln -sf /var/root/.dotfiles/config/.zshrc /Users/username/.zshrc
```

### Permission Issues

```bash
# Fix Homebrew ownership
sudo chown -R admin:admin /opt/homebrew

# Fix dotfiles ownership
sudo chown -R root:wheel /var/root/.dotfiles
```

## Monitoring and Maintenance

### Verify Deployment Status

Query MDM platform for:

- Script execution status
- Exit codes (0 = success)
- Log output
- Deployment timestamp

### Update Deployments

Deploy updated dotfiles:

1. Push changes to your dotfiles repository
2. Re-run MDM script on target devices
3. Script will `git pull` latest changes
4. Updated packages/configs deployed

### Periodic Updates

Schedule recurring MDM policy:

- Weekly or monthly
- Keeps dotfiles current
- Applies security updates
- Deploys to new users

## Advanced Configuration

### Conditional Deployment

Use MDM smart groups:

```bash
# In MDM script
if [[ $(hostname) == *"dev"* ]]; then
    export INSTALL_PROFILE="development"
elif [[ $(hostname) == *"qa"* ]]; then
    export INSTALL_PROFILE="work"
else
    export INSTALL_PROFILE="base"
fi
```

### Department-Specific Profiles

```bash
# Get user's department from directory service
DEPARTMENT=$(dscl . -read /Users/${ADMIN_USER} department | awk '{print $2}')

case "$DEPARTMENT" in
    "Engineering")
        export INSTALL_PROFILE="development"
        ;;
    "Design")
        export INSTALL_PROFILE="creative"
        ;;
    *)
        export INSTALL_PROFILE="base"
        ;;
esac
```

### Multi-Site Deployment

```bash
# Determine site from subnet
SUBNET=$(ipconfig getifaddr en0 | cut -d. -f1-3)

case "$SUBNET" in
    "10.1.1")
        export DOTFILES_REPO="https://github.com/org/dotfiles-site-sf.git"
        ;;
    "10.1.2")
        export DOTFILES_REPO="https://github.com/org/dotfiles-site-ny.git"
        ;;
esac
```

## Files and Locations

| Location | Purpose |
|----------|---------|
| `/var/root/.dotfiles` | Cloned repository (root) |
| `/opt/homebrew` | Homebrew (Apple Silicon) |
| `/usr/local` | Homebrew (Intel) |
| `/var/log/mdm-dotfiles-deploy.log` | Deployment log |
| `/Users/*/` | User home directories |
| `~/.zshrc`, `~/.ssh/config`, etc. | Symlinked configs |

## Next Steps

- [Bundle System](../bundle-system/README.md) - Understanding bundles
- [Configuration](../configuration/README.md) - Config file details
- [Individual Installation](manual.md) - For comparison
