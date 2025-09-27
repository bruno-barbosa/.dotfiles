#!/usr/bin/env bash

######################################
# Installs ruby/rbenv and its dependencies
######################################

function check_ruby() {
  run "Checking rbenv installation"

  # Check if rbenv is already installed and working
  if command -v rbenv >/dev/null 2>&1 && rbenv --version >/dev/null 2>&1; then
    ok "rbenv already installed"
    return 0
  fi

  action "Installing rbenv (Ruby Version Manager)"

  # Install rbenv
  run "Downloading and installing rbenv"

  if [[ -d "$HOME/.rbenv" ]]; then
    warn "rbenv directory already exists, updating..."
    cd "$HOME/.rbenv" && git pull
  else
    if git clone https://github.com/rbenv/rbenv.git ~/.rbenv; then
      ok "rbenv cloned successfully"
    else
      error "Failed to clone rbenv"
      return 1
    fi
  fi

  # Add rbenv to PATH for this session
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"

  # Compile dynamic bash extension (optional, for faster operation)
  run "Compiling rbenv dynamic bash extension"
  cd ~/.rbenv && src/configure && make -C src >/dev/null 2>&1 || warn "Failed to compile rbenv extension, but continuing..."

  # Install ruby-build plugin
  run "Installing ruby-build plugin"

  if [[ -d "$HOME/.rbenv/plugins/ruby-build" ]]; then
    warn "ruby-build already exists, updating..."
    cd "$HOME/.rbenv/plugins/ruby-build" && git pull
  else
    if git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build; then
      ok "ruby-build installed successfully"
    else
      error "Failed to install ruby-build"
      return 1
    fi
  fi

  # Verify rbenv is working
  if command -v rbenv >/dev/null 2>&1; then
    ok "rbenv installation verified"

    # Install Ruby using rbenv
    run "Installing Ruby (latest stable version)"

    # Check OpenSSL version to determine best Ruby version
    local openssl_version=$(openssl version | awk '{print $2}' | cut -d. -f1)
    local ruby_version=""

    if [[ "$openssl_version" == "3" ]]; then
      # OpenSSL 3.x detected - install Ruby 3.1+ for compatibility
      run "OpenSSL 3.x detected, installing Ruby 3.1+ for compatibility"

      # Try to install latest stable Ruby versions with OpenSSL 3.x support
      # Ruby 3.3 has the best OpenSSL 3.x support
      for version in "3.3.6" "3.3.5" "3.3.4" "3.2.6" "3.2.5" "3.1.6"; do
        run "Trying to install Ruby $version..."
        if rbenv install "$version" 2>/dev/null; then
          ruby_version="$version"
          ok "Ruby $version installed successfully with OpenSSL 3.x support"
          break
        fi
      done

      if [[ -z "$ruby_version" ]]; then
        error "Failed to install Ruby with OpenSSL 3.x compatibility"
        return 1
      fi
    else
      # OpenSSL 1.x - install latest stable Ruby
      ruby_version="3.3.6"
      run "Installing Ruby $ruby_version"

      if rbenv install "$ruby_version" 2>/dev/null; then
        ok "Ruby $ruby_version installed successfully"
      else
        error "Failed to install Ruby $ruby_version"
        return 1
      fi
    fi

    # Set as global default
    run "Setting Ruby $ruby_version as global default"
    if rbenv global "$ruby_version"; then
      ok "Ruby $ruby_version set as default"
    else
      warn "Failed to set Ruby as default, but continuing..."
    fi

    # Rehash rbenv
    rbenv rehash

    # Verify installation
    if command -v ruby >/dev/null 2>&1 && command -v gem >/dev/null 2>&1; then
      local installed_version=$(ruby --version 2>/dev/null | cut -d' ' -f2)
      ok "Ruby $installed_version ready"

      # Update RubyGems to latest version
      run "Updating RubyGems to latest version"
      if gem update --system --no-document --quiet; then
        ok "RubyGems updated successfully"
        rbenv rehash
      else
        warn "RubyGems update failed, but continuing..."
      fi
    else
      error "Ruby installation verification failed"
      return 1
    fi
  else
    error "rbenv installation failed - command not available"
    return 1
  fi

  return 0
}

# gem installer helper function
function gem_install() {
  local gem_name="$1"
  local gem_options="$2"

  run "Installing gem: $gem_name $gem_options"

  # Ensure we're using rbenv Ruby if available
  if command -v rbenv >/dev/null 2>&1; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
  fi

  if gem install "$gem_name" $gem_options --no-document; then
    ok "Successfully installed $gem_name"
    rbenv rehash 2>/dev/null || true
    return 0
  else
    error "Failed to install gem: $gem_name"
    return 1
  fi
}

function gem_installer_start() {
  # Ensure rbenv and Ruby are available and properly loaded
  if command -v rbenv >/dev/null 2>&1; then
    # Initialize rbenv
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
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

  # Convert space-separated string to array - bash 3.2+ compatible
  if [[ -n "$gems_list" ]]; then
    IFS=' ' read -ra gems_to_install <<< "$gems_list"
  fi

  # Skip gem installation if no gems configured
  if [[ ${#gems_to_install[@]} -eq 0 ]]; then
    ok "No gems configured in config.yaml - skipping gem installation"
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
