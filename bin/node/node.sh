#!/usr/bin/env bash

######################################
# Installs Volta (Node.js toolchain manager)
######################################

function check_node() {
  run "Checking Volta installation"

  # Check if Volta is already installed and working
  if command -v volta >/dev/null 2>&1 && volta --version >/dev/null 2>&1; then
    ok "Volta already installed"

    # Ensure Volta is initialized in current session
    if [[ -d "$HOME/.volta" ]]; then
      export VOLTA_HOME="$HOME/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"
    fi

    return 0
  fi

  action "Installing Volta (Node.js Toolchain Manager)"

  # Install Volta using the official installer
  run "Downloading and installing Volta"
  if curl https://get.volta.sh | bash; then
    ok "Volta installation completed"

    # Set up Volta environment
    export VOLTA_HOME="$HOME/.volta"
    export PATH="$VOLTA_HOME/bin:$PATH"

    # Source Volta for immediate use
    if [[ -f "$VOLTA_HOME/load.sh" ]]; then
      source "$VOLTA_HOME/load.sh"
    fi

    # Verify Volta is working
    if command -v volta >/dev/null 2>&1; then
      ok "Volta installation verified"

      # Install latest LTS Node.js
      run "Installing latest LTS Node.js"
      if volta install node; then
        ok "Node.js LTS installed successfully"
      else
        warn "Node.js installation failed, but Volta is available"
      fi
    else
      error "Volta installation failed - command not available"
      return 1
    fi
  else
    error "Volta installation failed"
    return 1
  fi

  return 0
}

# npm package installer helper function
function node_install() {
  local package_name="$1"
  local package_options="$2"

  run "Installing Node.js package: $package_name $package_options"

  if npm install -g "$package_name" $package_options; then
    ok "Successfully installed $package_name"
    return 0
  else
    error "Failed to install Node.js package: $package_name"
    return 1
  fi
}

function node_installer_start() {
  # Ensure npm is available
  if ! command -v npm >/dev/null 2>&1; then
    warn "npm command not available, skipping Node.js package installation"
    return 1
  fi

  run "Installing Node.js packages from configuration"

  # Load configuration using config functions
  load_configs

  # Get node packages from configuration
  local packages_list=$(get_node_packages)
  local packages_to_install=()

  # Convert space-separated string to array
  if [[ -n "$packages_list" ]]; then
    read -ra packages_to_install <<< "$packages_list"
  fi

  # Skip Node.js package installation if no packages configured
  if [[ ${#packages_to_install[@]} -eq 0 ]]; then
    ok "No Node.js packages configured in config.toml - skipping npm installation"
    return 0
  fi

  local success_count=0
  local total_count=${#packages_to_install[@]}

  run "Installing ${total_count} Node.js packages"

  for package_name in "${packages_to_install[@]}"; do
    # Skip npm and yarn as they're handled separately by Volta
    if [[ "$package_name" == "npm" || "$package_name" == "yarn" ]]; then
      ok "Skipping $package_name (managed by Volta)"
      ((success_count++))
      continue
    fi

    if node_install "$package_name"; then
      ((success_count++))
    fi
  done

  if [[ $success_count -eq $total_count ]]; then
    ok "All Node.js packages installed successfully ($success_count/$total_count)"
    return 0
  else
    warn "Some Node.js packages failed to install ($success_count/$total_count succeeded)"
    return 1
  fi
}