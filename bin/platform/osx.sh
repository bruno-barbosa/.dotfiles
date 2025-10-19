#!/usr/bin/env bash

######################################
# Installs brew and its dependencies
######################################

# verifies brew installation
function check_brew() {
  run "Checking for existing homebrew installation..."

  # Check if brew command exists - this can be slow on first run
  local brew_bin
  if brew_bin=$(command -v brew 2>/dev/null); then
    ok "Homebrew found at: $brew_bin"

    # Clean up any stale lock files
    local lock_dir="/opt/homebrew/var/homebrew/locks"
    if [[ -d "$lock_dir" && "$(ls -A "$lock_dir" 2>/dev/null)" ]]; then
      run "Removing stale Homebrew lock files..."
      rm -rf "$lock_dir"/* 2>/dev/null || true
      ok "Homebrew locks cleaned"
    fi

    run "Updating homebrew repositories (this may take a moment)..."
    if brew update; then
      ok "Homebrew repositories updated successfully"
    else
      warn "Homebrew update encountered issues, but continuing..."
    fi

    # Check for outdated packages
    run "Checking for outdated packages..."
    local outdated_count
    outdated_count=$(brew outdated --quiet | wc -l | xargs)

    if [[ "$outdated_count" -gt 0 ]]; then
      bot "Found $outdated_count outdated package(s). Would you like to upgrade them?"
      read -r -p "run brew upgrade? [y|N] " response
      if [[ $response =~ ^(y|yes|Y) ]]; then
        action "Upgrading $outdated_count outdated package(s) (this may take several minutes)..."
        if brew upgrade; then
          ok "Package upgrade completed successfully"
        else
          warn "Some packages failed to upgrade, but continuing..."
        fi
      else
        ok "Skipped brew packages upgrade"
      fi
    else
      ok "All packages are up to date"
    fi
  else
    action "Homebrew not found - installing now..."
    run "Downloading Homebrew installer (this may take a moment)..."

    # Install Homebrew with progress indication
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      ok "Homebrew installation completed"

      # Set up environment for different architectures
      run "Setting up Homebrew environment..."
      if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        ok "Homebrew environment configured (Apple Silicon)"
      elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        ok "Homebrew environment configured (Intel)"
      else
        error "Homebrew installation completed but brew command not found"
        return 1
      fi

      # Verify installation
      if command -v brew >/dev/null 2>&1; then
        local brew_version=$(brew --version | head -1)
        ok "Homebrew ready: $brew_version"
      else
        error "Homebrew installation failed - command not available"
        return 1
      fi
    else
      error "Homebrew installation failed"
      return 1
    fi
  fi
}

# brew installer helper function
function brew_install() {
  # Check if already installed (quietly)
  if brew list $1 >/dev/null 2>&1; then
    ok "    ✓ $1 already installed"
    return 0
  fi

  # Install the package
  if brew install $1 $2 >/dev/null 2>&1; then
    ok "    ✓ $1 installed successfully"
    return 0
  else
    error "    ✗ Failed to install $1"
    return 1
  fi
}

# brew cask installer helper (updated for modern Homebrew)
function brew_cask_install() {
  # Check if already installed (quietly)
  if brew list --cask $1 >/dev/null 2>&1; then
    ok "    ✓ $1 already installed"
    return 0
  fi

  # Install the cask
  if brew install --cask $1 $2 >/dev/null 2>&1; then
    ok "    ✓ $1 installed successfully"
    return 0
  else
    error "    ✗ Failed to install $1"
    return 1
  fi
}

# Install packages from configuration
function brew_installer_start() {
  # Load configuration if not already loaded
  if [[ -z "${CONFIG_SETUP_PACKAGES_OSX:-}" ]]; then
    load_configs
  fi

  # Get packages from configuration
  local packages_string
  packages_string=$(get_packages "osx")

  if [[ -z "$packages_string" ]]; then
    warn "No packages found in configuration for osx platform"
    return 0
  fi

  # Convert string to array - bash 3.2+ compatible
  local packages=()
  if [[ -n "$packages_string" ]]; then
    # Use bash 3.2+ compatible array conversion
    IFS=' ' read -ra packages <<< "$packages_string"
  fi

  local total_packages=${#packages[@]}
  run "Installing $total_packages packages from configuration using Homebrew"

  # Tap homebrew/cask for GUI applications
  run "Setting up Homebrew cask tap for GUI applications..."
  if brew tap homebrew/cask 2>/dev/null; then
    ok "Homebrew cask tap ready"
  else
    warn "Homebrew cask tap failed, but continuing..."
  fi

  # Install packages with progress tracking
  local current=0
  local failed_packages=()

  for package in "${packages[@]}"; do
    if [ -n "$package" ]; then
      ((current++))
      run "[$current/$total_packages] Processing package: $package"

      # Check if it's a cask package (GUI applications)
      run "  → Determining package type for $package..."
      if brew info --cask "$package" >/dev/null 2>&1; then
        run "  → Installing $package as cask (GUI application)..."
        if ! brew_cask_install "$package"; then
          failed_packages+=("$package (cask)")
        fi
      else
        run "  → Installing $package as formula (CLI tool)..."
        if ! brew_install "$package"; then
          failed_packages+=("$package (formula)")
        fi
      fi
    fi
  done

  # Report installation results
  local failed_count=${#failed_packages[@]}
  local success_count=$((total_packages - failed_count))

  if [[ $failed_count -eq 0 ]]; then
    ok "All $total_packages packages installed successfully"
  else
    warn "$failed_count package(s) failed to install:"
    for failed_pkg in "${failed_packages[@]}"; do
      warn "  → $failed_pkg"
    done
    warn "Successfully installed $success_count/$total_packages packages"
  fi

  ok "Finished installing packages from configuration"
}

# macOS System Defaults Configuration
function apply_macos_system_defaults() {
  run "Applying macOS system defaults"

  # Close any open System Preferences/Settings panes to prevent conflicts
  osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
  osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

  ###############################################################################
  # General UI/UX                                                               #
  ###############################################################################

  # Disable transparency in the menu bar and elsewhere
  defaults write com.apple.universalaccess reduceTransparency -bool true

  # Always show scrollbars
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

  # Expand save and print panels by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Disable automatic termination of inactive apps
  defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

  # Disable automatic capitalization, dashes, periods, and quotes (annoying when typing code)
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

  ###############################################################################
  # Trackpad, keyboard, and input                                               #
  ###############################################################################

  # Trackpad: enable tap to click
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

  # Disable "natural" scrolling
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

  # Enable full keyboard access for all controls (Tab in modal dialogs)
  defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

  # Disable press-and-hold for keys in favor of key repeat
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  # Set fast keyboard repeat rate
  defaults write NSGlobalDomain KeyRepeat -int 2
  defaults write NSGlobalDomain InitialKeyRepeat -int 15

  ###############################################################################
  # Screen                                                                      #
  ###############################################################################

  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0

  # Save screenshots to the desktop in PNG format
  defaults write com.apple.screencapture location -string "${HOME}/Desktop"
  defaults write com.apple.screencapture type -string "png"
  defaults write com.apple.screencapture disable-shadow -bool true

  ###############################################################################
  # Finder                                                                      #
  ###############################################################################

  # Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons
  defaults write com.apple.finder QuitMenuItem -bool true

  # Disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true

  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true

  # Show status bar and path bar
  defaults write com.apple.finder ShowStatusBar -bool true
  defaults write com.apple.finder ShowPathbar -bool true

  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true

  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

  # Disable warning when changing a file extension
  defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Use list view in all Finder windows by default
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

  # Show the ~/Library folder
  chflags nohidden ~/Library

  ###############################################################################
  # Dock                                                                        #
  ###############################################################################

  # Set the icon size of Dock items to 36 pixels
  defaults write com.apple.dock tilesize -int 36

  # Change minimize/maximize window effect to scale
  defaults write com.apple.dock mineffect -string "scale"

  # Show indicator lights for open applications in the Dock
  defaults write com.apple.dock show-process-indicators -bool true

  # Don't animate opening applications from the Dock
  defaults write com.apple.dock launchanim -bool false

  # Speed up Mission Control animations
  defaults write com.apple.dock expose-animation-duration -float 0.1

  # Don't automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false

  # Remove the auto-hiding Dock delay and animation
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true

  # Don't show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false

  ###############################################################################
  # Safari                                                                      #
  ###############################################################################

  # Show the full URL in the address bar
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

  # Prevent Safari from opening 'safe' files automatically after downloading
  defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

  # Enable the Develop menu and Web Inspector
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

  # Enable "Do Not Track"
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  ###############################################################################
  # Kill affected applications                                                  #
  ###############################################################################

  for app in "Activity Monitor" \
    "Contacts" \
    "Dock" \
    "Finder" \
    "Mail" \
    "Messages" \
    "Photos" \
    "Safari" \
    "SystemUIServer" \
    "cfprefsd"; do
    killall "${app}" &> /dev/null || true
  done

  ok "macOS system defaults applied successfully"
  warn "Some changes require a logout/restart to take effect"
}
