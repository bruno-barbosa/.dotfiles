#!/usr/bin/env bash

######################################
# Installs brew and its dependencies
######################################

# verifies brew installation
function check_brew() {
  run "Checking homebrew installation"
  brew_bin=$(which brew) 2>&1 >/dev/null
  if [[ $? != 0 ]]; then
    action "Installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if [[ $? != 0 ]]; then
      error "Unable to install homebrew, aborting installation!"
      exit 2
    fi
  else
    run "Updating homebrew"
    brew update
    bot "Before installing brew packages, would you like to upgrade outdated packages?"
    read -r -p "run brew upgrade? [y|N]" response
    if [[ $response =~ ^(y|yes|Y) ]]; then
      action "Upgrading brew packages"
      brew upgrade
    else
      ok "Skipped brew packages upgrade"
    fi
  fi
}

# brew installer helper function
function brew_install() {
  run "Checking if $1 is installed"
  brew list $1 >/dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    action "Installing $1 with homebrew"
    brew install $1 $2
    if [[ $? != 0 ]]; then
      error "Failed to install $1! Aborting..."
    fi
  else
    ok "$1 already installed"
  fi
}

# brew cask installer helper (updated for modern Homebrew)
function brew_cask_install() {
  run "Checking if cask $1 is installed"
  brew list --cask $1 >/dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    action "Installing cask $1 with homebrew"
    brew install --cask $1 $2
    if [[ $? != 0 ]]; then
      error "Failed to install $1! Aborting..."
    fi
  else
    ok "Cask $1 already installed"
  fi
}

# Install packages from configuration
function brew_installer_start() {
  # Load configuration if not already loaded
  if [[ -z "${CONFIG_SETUP_PACKAGES_OSX[packages]:-}" ]]; then
    load_configs
  fi

  # Get packages from configuration
  local packages_string
  packages_string=$(get_packages "osx")

  if [[ -z "$packages_string" ]]; then
    warn "No packages found in configuration for osx platform"
    return 0
  fi

  # Convert string to array
  read -ra packages <<< "$packages_string"

  run "Installing $(echo ${#packages[@]}) packages from configuration using Homebrew"

  # Tap homebrew/cask for GUI applications
  brew tap homebrew/cask 2>/dev/null || true

  # Install packages
  for package in "${packages[@]}"; do
    if [ -n "$package" ]; then
      # Check if it's a cask package (GUI applications)
      if brew info --cask "$package" >/dev/null 2>&1; then
        brew_cask_install "$package"
      else
        brew_install "$package"
      fi
    fi
  done

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
