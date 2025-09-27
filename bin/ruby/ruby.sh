#!/usr/bin/env bash

######################################
# Installs ruby/rvm and its dependencies
######################################

function check_ruby() {
  run "Checking RVM installation"

  # Check if RVM is already installed and working
  if command -v rvm >/dev/null 2>&1 && rvm --version >/dev/null 2>&1; then
    ok "RVM already installed"

    # Source RVM to ensure it's available in current session
    if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
      source "$HOME/.rvm/scripts/rvm"
    fi

    return 0
  fi

  action "Installing RVM (Ruby Version Manager)"

  # Install GPG keys (required for Linux/Ubuntu, optional for macOS)
  if [[ "$IS_LINUX" == "true" ]] || ! command -v gpg >/dev/null 2>&1; then
    run "Installing RVM GPG keys"
    local gpg_success=false

    # Try multiple keyservers
    local keyservers=(
      "hkp://pgp.mit.edu"
      "hkp://keys.gnupg.net"
      "keyserver.ubuntu.com"
    )

    for keyserver in "${keyservers[@]}"; do
      if gpg --keyserver "$keyserver" --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB 2>/dev/null; then
        gpg_success=true
        ok "GPG keys imported successfully from $keyserver"
        break
      fi
    done

    if [[ "$gpg_success" != "true" ]]; then
      warn "Failed to import GPG keys, but continuing with RVM installation..."
    fi
  else
    ok "Skipping GPG key installation on macOS (not required)"
  fi

  # Install RVM
  run "Downloading and installing RVM"
  if curl -sSL https://get.rvm.io | bash -s stable; then
    ok "RVM installation completed"

    # Source RVM immediately
    if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
      source "$HOME/.rvm/scripts/rvm"
      ok "RVM sourced successfully"

      # Fix RVM permissions
      run "Fixing RVM permissions"
      rvm fix-permissions system 2>/dev/null || true
      rvm fix-permissions user 2>/dev/null || true
      ok "RVM permissions fixed"
    else
      error "RVM script not found after installation"
      return 1
    fi

    # Verify RVM is working
    if command -v rvm >/dev/null 2>&1; then
      ok "RVM installation verified"

      # Install Ruby using RVM's default latest stable version
      run "Installing Ruby (latest stable version)"

      # Install Ruby
      local ruby_installed=false
      if rvm install ruby; then
        ruby_installed=true
        ok "Ruby installed successfully"
      else
        error "Failed to install Ruby"
        return 1
      fi

      if [[ "$ruby_installed" == "true" ]]; then
        # Set as default and use it
        run "Setting Ruby as default"

        # Set Ruby as default - RVM automatically sets installed ruby as default
        if rvm use ruby --default; then
          ok "Ruby set as default"
        else
          warn "Failed to set Ruby as default, but continuing..."
        fi

        # Reload RVM environment
        source "$HOME/.rvm/scripts/rvm"
        rvm use default >/dev/null 2>&1

        # Verify installation
        if command -v ruby >/dev/null 2>&1 && command -v gem >/dev/null 2>&1; then
          local installed_version=$(ruby --version 2>/dev/null | cut -d' ' -f2)
          ok "Ruby $installed_version ready"

          # Update RubyGems to latest version
          run "Updating RubyGems to latest version"
          if gem update --system --no-document --quiet; then
            ok "RubyGems updated successfully"
          else
            warn "RubyGems update failed, but continuing..."
          fi
        else
          error "Ruby installation verification failed"
          return 1
        fi
      else
        error "Ruby installation failed completely"
        return 1
      fi
    else
      error "RVM installation failed - command not available"
      return 1
    fi
  else
    error "RVM installation failed"
    return 1
  fi

  return 0
}

# gem installer helper function
function gem_install() {
  local gem_name="$1"
  local gem_options="$2"

  run "Installing gem: $gem_name $gem_options"

  # Ensure we're using RVM Ruby if available
  if command -v rvm >/dev/null 2>&1; then
    source "$HOME/.rvm/scripts/rvm"
    rvm use default
  fi

  if gem install "$gem_name" $gem_options; then
    ok "Successfully installed $gem_name"
    return 0
  else
    error "Failed to install gem: $gem_name"
    return 1
  fi
}

function gem_installer_start() {
  # Ensure RVM and Ruby are available and properly loaded
  if command -v rvm >/dev/null 2>&1; then
    # Source RVM to ensure we're using the right Ruby/gem
    source "$HOME/.rvm/scripts/rvm" >/dev/null 2>&1

    # Add RVM to PATH
    export PATH="$HOME/.rvm/bin:$PATH"

    # Use the current default Ruby
    rvm use default >/dev/null 2>&1

    # Force reload the environment
    [[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  fi

  # Check if both ruby and gem are available
  if ! command -v ruby >/dev/null 2>&1 || ! command -v gem >/dev/null 2>&1; then
    error "Ruby or gem command not available, skipping gem installation"
    return 1
  fi

  # Test if they actually work
  if ! ruby --version >/dev/null 2>&1 || ! gem --version >/dev/null 2>&1; then
    error "Ruby or gem not working properly, skipping gem installation"
    return 1
  fi

  local ruby_info
  ruby_info=$(ruby --version 2>/dev/null | cut -d' ' -f1-2)
  run "Installing gems from configuration (using $ruby_info)"

  # Load configuration using config functions
  load_configs

  # Get gems from configuration
  local gems_list=$(get_gems)
  local gems_to_install=()

  # Convert space-separated string to array
  if [[ -n "$gems_list" ]]; then
    read -ra gems_to_install <<< "$gems_list"
  fi

  # Skip gem installation if no gems configured
  if [[ ${#gems_to_install[@]} -eq 0 ]]; then
    ok "No gems configured in config.toml - skipping gem installation"
    return 0
  fi

  local success_count=0
  local total_count=${#gems_to_install[@]}

  run "Installing ${total_count} gems"

  for gem_name in "${gems_to_install[@]}"; do
    if gem_install "$gem_name"; then
      ((success_count++))
    fi
  done

  if [[ $success_count -eq $total_count ]]; then
    ok "All gems installed successfully ($success_count/$total_count)"
    return 0
  else
    warn "Some gems failed to install ($success_count/$total_count succeeded)"
    return 1
  fi
}
