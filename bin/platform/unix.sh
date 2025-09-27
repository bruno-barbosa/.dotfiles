#!/usr/bin/env bash

######################################
# Linux package installer
######################################

# Detect Linux distribution (Debian-based only)
function detect_linux_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      ubuntu|debian)
        export DISTRO=$ID
        export DISTRO_VERSION=$VERSION_ID
        ;;
      *)
        export DISTRO="unsupported"
        ;;
    esac
  elif [ -f /etc/debian_version ]; then
    export DISTRO="debian"
  else
    export DISTRO="unsupported"
  fi
}

# Package installer for Debian-based distributions
function unix_install() {
  local package="$1"

  if [[ "$DISTRO" == "unsupported" ]]; then
    error "Unsupported Linux distribution. Only Debian-based systems (Ubuntu/Debian) are supported."
    return 1
  fi

  run "Installing $package on $DISTRO"

  if ! dpkg -l | grep -q "^ii  $package "; then
    action "Installing $package with apt"
    sudo apt install -y "$package"
    if [[ $? -ne 0 ]]; then
      error "Failed to install $package"
      return 1
    fi
  else
    ok "$package already installed"
  fi
}

# Install packages from configuration
function unix_installer_start() {
  detect_linux_distro

  # Load configuration if not already loaded
  if [[ -z "${CONFIG_SETUP_PACKAGES_DEBIAN:-}" ]]; then
    load_configs
  fi

  # Get packages from configuration
  local packages_string
  packages_string=$(get_packages "debian")

  if [[ -z "$packages_string" ]]; then
    warn "No packages found in configuration for debian platform"
    return 0
  fi

  # Convert string to array - bash 3.2+ compatible
  local packages=()
  if [[ -n "$packages_string" ]]; then
    # Use bash 3.2+ compatible array conversion
    IFS=' ' read -ra packages <<< "$packages_string"
  fi

  run "Installing $(echo ${#packages[@]}) packages from configuration"

  # Check if we're on a supported distribution
  if [[ "$DISTRO" == "unsupported" ]]; then
    error "Unsupported Linux distribution. Only Debian-based systems (Ubuntu/Debian) are supported."
    return 1
  fi

  # Install packages (no adjustment needed for Debian-based systems)
  for package in "${packages[@]}"; do
    if [ -n "$package" ]; then
      unix_install "$package"
    fi
  done

  ok "Finished installing packages from configuration"
}

# Function to check if package is available (Debian-based only)
function check_unix_package() {
  local package="$1"

  if [[ "$DISTRO" == "unsupported" ]]; then
    return 1
  fi

  apt-cache show "$package" >/dev/null 2>&1
}

# Function to configure passwordless sudo for Linux
function setup_passwordless_sudo() {
  local username=$(whoami)
  local sudoers_file="/etc/sudoers.d/${username}_nopasswd"

  run "Checking if passwordless sudo is already configured"

  # Check if passwordless sudo is already configured
  if sudo -n true 2>/dev/null; then
    ok "Passwordless sudo already configured"
    return 0
  fi

  action "Setting up passwordless sudo for user: $username"

  # Check if user is in sudo group
  if ! groups "$username" | grep -q '\bsudo\b'; then
    run "Adding user to sudo group"
    if sudo usermod -aG sudo "$username"; then
      ok "User added to sudo group"
    else
      error "Failed to add user to sudo group"
      return 1
    fi
  else
    ok "User already in sudo group"
  fi

  # Create sudoers configuration file
  run "Creating sudoers configuration for passwordless sudo"

  local sudoers_content="${username} ALL=(ALL) NOPASSWD:ALL"

  # Write the configuration using a temporary file and validate it
  local temp_file="/tmp/sudoers_${username}_$$"

  if echo "$sudoers_content" > "$temp_file"; then
    # Validate the sudoers file
    if sudo visudo -c -f "$temp_file"; then
      # Move the validated file to the proper location
      if sudo cp "$temp_file" "$sudoers_file" && sudo chmod 440 "$sudoers_file"; then
        ok "Passwordless sudo configured successfully"

        # Clean up temporary file
        sudo rm -f "$temp_file"

        # Verify the configuration works
        run "Verifying passwordless sudo configuration"
        if sudo -n true 2>/dev/null; then
          ok "Passwordless sudo verification successful"
          return 0
        else
          warn "Passwordless sudo configuration may require a new login session"
          return 0
        fi
      else
        error "Failed to install sudoers configuration"
        sudo rm -f "$temp_file"
        return 1
      fi
    else
      error "Invalid sudoers configuration"
      sudo rm -f "$temp_file"
      return 1
    fi
  else
    error "Failed to create temporary sudoers file"
    return 1
  fi
}