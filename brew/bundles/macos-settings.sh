#!/bin/bash

################################################################################
# macOS Settings Bundle
#
# Configures macOS system preferences for optimal developer experience
# Includes trackpad, keyboard, scroll direction, gestures, and more
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

################################################################################
# Trackpad & Mouse Settings
################################################################################

configure_trackpad() {
    log_info "Configuring trackpad settings..."

    # Disable natural scrolling (reverse scroll direction)
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    log_success "Disabled natural scrolling"

    # Enable tap to click for this user and for the login screen
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    log_success "Enabled tap to click"

    # Enable three-finger drag
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    log_success "Enabled three-finger drag"

    # Increase tracking speed (0-3, 3 is fastest)
    defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5
    log_success "Set trackpad tracking speed"

    # Enable force click and haptic feedback
    defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool false
    defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -bool true
    log_success "Enabled Force Touch and haptic feedback"
}

################################################################################
# Keyboard Settings
################################################################################

configure_keyboard() {
    log_info "Configuring keyboard settings..."

    # Set keyboard repeat rate (1-2 is fast, 120 is slow)
    defaults write NSGlobalDomain KeyRepeat -int 2
    log_success "Set fast keyboard repeat rate"

    # Set delay until key repeat (15 is short, 120 is long)
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    log_success "Set short delay until key repeat"

    # Enable full keyboard access for all controls
    # (e.g. enable Tab in modal dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    log_success "Enabled full keyboard access"

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    log_success "Disabled press-and-hold for keys"

    # Set language and text formats
    defaults write NSGlobalDomain AppleLanguages -array "en-US"
    defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
    defaults write NSGlobalDomain AppleMetricUnits -bool false
    log_success "Set language and regional formats"
}

################################################################################
# Dock Settings
################################################################################

configure_dock() {
    log_info "Configuring Dock settings..."

    # Set the icon size of Dock items (default: 64)
    defaults write com.apple.dock tilesize -int 32
    log_success "Set Dock icon size to 48"

    # Enable magnification
    defaults write com.apple.dock magnification -bool true
    defaults write com.apple.dock largesize -int 64
    log_success "Enabled Dock magnification"

    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true
    log_success "Minimize windows into application icon"

    # Enable spring loading for all Dock items
    defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
    log_success "Enabled spring loading for Dock items"

    # Show indicator lights for open applications
    defaults write com.apple.dock show-process-indicators -bool true
    log_success "Enabled indicator lights for open apps"

    # Don't animate opening applications
    defaults write com.apple.dock launchanim -bool false
    log_success "Disabled opening animation for apps"

    # Speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float 0.1
    log_success "Sped up Mission Control animations"

    # Don't group windows by application in Mission Control
    defaults write com.apple.dock expose-group-by-app -bool false
    log_success "Disabled grouping windows by app in Mission Control"

    # Remove the auto-hiding Dock delay
    defaults write com.apple.dock autohide-delay -float 0
    # Remove the animation when hiding/showing the Dock
    defaults write com.apple.dock autohide-time-modifier -float 0
    log_success "Removed Dock auto-hide delay and animation"

    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true
    log_success "Enabled auto-hide for Dock"

    # Make Dock icons of hidden applications translucent
    defaults write com.apple.dock showhidden -bool true
    log_success "Made hidden app icons translucent"

    # Don't show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false
    log_success "Disabled recent applications in Dock"
}

################################################################################
# Finder Settings
################################################################################

configure_finder() {
    log_info "Configuring Finder settings..."

    # Show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true
    log_success "Enabled showing hidden files"

    # Show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    log_success "Enabled showing all file extensions"

    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    log_success "Enabled Finder status bar"

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    log_success "Enabled Finder path bar"

    # Display full POSIX path as Finder window title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    log_success "Enabled full path in Finder title"

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    log_success "Keep folders on top when sorting"

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    log_success "Set default search scope to current folder"

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    log_success "Disabled file extension change warning"

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    log_success "Disabled .DS_Store files on network/USB volumes"

    # Use list view in all Finder windows by default
    # Four-letter codes: `icnv`, `clmv`, `glyv`, `Nlsv`
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    log_success "Set default Finder view to list view"

    # Show the ~/Library folder
    chflags nohidden ~/Library
    log_success "Made ~/Library folder visible"

    # Show the /Volumes folder
    sudo chflags nohidden /Volumes 2>/dev/null || log_warning "Could not unhide /Volumes (requires sudo)"
}

################################################################################
# Screen & Display Settings
################################################################################

configure_screen() {
    log_info "Configuring screen settings..."

    # Require password immediately after sleep or screen saver begins
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    log_success "Enabled immediate password requirement after screensaver"

    # Save screenshots to ~/Pictures/Screenshots
    mkdir -p "${HOME}/Pictures/Screenshots"
    defaults write com.apple.screencapture location -string "${HOME}/Pictures/Screenshots"
    log_success "Set screenshot location to ~/Pictures/Screenshots"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"
    log_success "Set screenshot format to PNG"

    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    log_success "Disabled shadows in screenshots"

    # Enable subpixel font rendering on non-Apple LCDs
    defaults write NSGlobalDomain AppleFontSmoothing -int 2
    log_success "Enabled subpixel font rendering"

    # Enable HiDPI display modes (requires restart)
    sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true 2>/dev/null || log_warning "Could not enable HiDPI modes (requires sudo)"
}

################################################################################
# Safari & WebKit Settings
################################################################################

configure_safari() {
    log_info "Configuring Safari settings..."

    # Close Safari if it's running to allow preference changes
    if pgrep -x "Safari" > /dev/null; then
        log_warning "Safari is running. Attempting to close Safari..."
        killall "Safari" &> /dev/null || true
        sleep 2
    fi

    # Privacy: don't send search queries to Apple
    if defaults write com.apple.Safari UniversalSearchEnabled -bool false 2>/dev/null && \
       defaults write com.apple.Safari SuppressSearchSuggestions -bool true 2>/dev/null; then
        log_success "Disabled sending search queries to Apple"
    else
        log_warning "Could not configure Safari search settings (sandboxed preferences)"
    fi

    # Show the full URL in the address bar
    if defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true 2>/dev/null; then
        log_success "Enabled showing full URLs in Safari"
    else
        log_warning "Could not configure Safari URL display (sandboxed preferences)"
    fi

    # Enable Safari's debug menu
    if defaults write com.apple.Safari IncludeInternalDebugMenu -bool true 2>/dev/null; then
        log_success "Enabled Safari debug menu"
    else
        log_warning "Could not enable Safari debug menu (sandboxed preferences)"
    fi

    # Enable the Develop menu and the Web Inspector
    if defaults write com.apple.Safari IncludeDevelopMenu -bool true 2>/dev/null && \
       defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true 2>/dev/null && \
       defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true 2>/dev/null; then
        log_success "Enabled Safari Developer menu"
    else
        log_warning "Could not enable Safari Developer menu (sandboxed preferences)"
    fi

    # Enable "Do Not Track"
    if defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true 2>/dev/null; then
        log_success "Enabled Do Not Track in Safari"
    else
        log_warning "Could not enable Do Not Track (sandboxed preferences)"
    fi

    log_info "Note: Safari preferences may need to be configured manually in Safari > Settings"
    log_info "Safari uses sandboxed preferences which may require manual configuration"
}

################################################################################
# Activity Monitor Settings
################################################################################

configure_activity_monitor() {
    log_info "Configuring Activity Monitor settings..."

    # Show the main window when launching Activity Monitor
    defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
    log_success "Show main window when launching Activity Monitor"

    # Visualize CPU usage in the Activity Monitor Dock icon
    defaults write com.apple.ActivityMonitor IconType -int 5
    log_success "Show CPU usage in Activity Monitor Dock icon"

    # Show all processes in Activity Monitor
    defaults write com.apple.ActivityMonitor ShowCategory -int 0
    log_success "Show all processes in Activity Monitor"

    # Sort Activity Monitor results by CPU usage
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0
    log_success "Sort Activity Monitor by CPU usage"
}

################################################################################
# Miscellaneous Settings
################################################################################

configure_misc() {
    log_info "Configuring miscellaneous settings..."

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    log_success "Enabled expanded save panel by default"

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    log_success "Enabled expanded print panel by default"

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    log_success "Set default save location to disk (not iCloud)"

    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
    log_success "Auto-quit printer app after jobs complete"

    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    log_success "Disabled 'Are you sure' dialog for applications"

    # Disable automatic capitalization
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    log_success "Disabled automatic capitalization"

    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    log_success "Disabled smart dashes"

    # Disable automatic period substitution
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
    log_success "Disabled automatic period substitution"

    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    log_success "Disabled smart quotes"

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    log_success "Disabled auto-correct"

    # Enable AirDrop over Ethernet and on unsupported Macs
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
    log_success "Enabled AirDrop over Ethernet"

    # Increase sound quality for Bluetooth headphones/headsets
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
    log_success "Increased Bluetooth audio quality"
}

################################################################################
# Restart Required Services
################################################################################

restart_services() {
    log_info "Restarting affected applications and services..."

    # Kill affected applications
    for app in "Activity Monitor" \
        "cfprefsd" \
        "Dock" \
        "Finder" \
        "Safari" \
        "SystemUIServer"; do
        killall "${app}" &> /dev/null || true
    done

    log_success "Restarted affected applications"
    log_warning "Some changes may require a full logout/restart to take effect"
}

################################################################################
# Main
################################################################################

main() {
    log_info "Configuring macOS system settings..."
    echo

    configure_trackpad
    echo

    configure_keyboard
    echo

    configure_dock
    echo

    configure_finder
    echo

    configure_screen
    echo

    configure_safari
    echo

    configure_activity_monitor
    echo

    configure_misc
    echo

    restart_services
    echo

    log_success "macOS settings configuration complete!"
    log_info "Please log out and back in for all changes to take effect"
}

main "$@"
