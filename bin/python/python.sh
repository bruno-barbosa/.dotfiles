#!/usr/bin/env bash

######################################
# Installs pyenv and Python dependencies
######################################

function check_python() {
  run "Checking pyenv installation"

  # Check if pyenv is already installed and working
  if command -v pyenv >/dev/null 2>&1 && pyenv --version >/dev/null 2>&1; then
    ok "pyenv already installed"

    # Ensure pyenv is initialized in current session
    if [[ -d "$HOME/.pyenv" ]]; then
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"
    fi

    return 0
  fi

  action "Installing pyenv (Python Version Manager)"

  # Install pyenv using the official installer
  run "Downloading and installing pyenv"
  if curl https://pyenv.run | bash; then
    ok "pyenv installation completed"

    # Set up pyenv environment
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    # Initialize pyenv if available
    if command -v pyenv >/dev/null 2>&1; then
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"
      ok "pyenv initialized successfully"
    else
      error "pyenv installation failed - command not available"
      return 1
    fi

    # Install latest LTS Python version for package management
    run "Installing latest LTS Python version"

    # Get available Python versions and find the latest LTS (3.12.x series is current LTS)
    local available_versions
    available_versions=$(pyenv install --list 2>/dev/null | grep -E '^\s*3\.(12|11)\.[0-9]+$' | sed 's/^[[:space:]]*//' | sort -V -r)

    local installed_version=""
    local lts_installed=false

    # Try to install the latest available version from LTS series
    while IFS= read -r version; do
      if [[ -n "$version" ]]; then
        run "Attempting to install Python $version"
        if pyenv install "$version" 2>/dev/null || pyenv versions | grep -q "$version"; then
          installed_version="$version"
          lts_installed=true
          break
        fi
      fi
    done <<< "$available_versions"

    # Fallback to hardcoded versions if dynamic detection fails
    if [[ "$lts_installed" != "true" ]]; then
      warn "Could not detect available versions, trying fallback versions"
      local fallback_versions=("3.12.8" "3.12.7" "3.12.6" "3.11.11" "3.11.10" "3.11.9")

      for version in "${fallback_versions[@]}"; do
        run "Attempting fallback install of Python $version"
        if pyenv install "$version" 2>/dev/null || pyenv versions | grep -q "$version"; then
          installed_version="$version"
          lts_installed=true
          break
        fi
      done
    fi

    if [[ "$lts_installed" == "true" && -n "$installed_version" ]]; then
      pyenv global "$installed_version"
      ok "Python $installed_version (LTS) installed and set as global"

      # Ensure we're using the pyenv Python
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"

      # Upgrade pip in the pyenv environment
      run "Upgrading pip in pyenv environment"
      if python -m pip install --upgrade pip; then
        ok "pip upgraded successfully in pyenv environment"
      else
        warn "pip upgrade failed, but continuing..."
      fi
    else
      warn "Failed to install any Python LTS version, but pyenv is available"
    fi
  else
    error "pyenv installation failed"
    return 1
  fi

  return 0
}

# pip installer helper function
function python_install() {
  local package_name="$1"
  local package_options="$2"

  run "Installing Python package: $package_name $package_options"

  # Ensure we're using pyenv Python and pip
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
  fi

  if python -m pip install "$package_name" $package_options; then
    ok "Successfully installed $package_name"
    return 0
  else
    error "Failed to install Python package: $package_name"
    return 1
  fi
}

function python_installer_start() {
  # Ensure pyenv is initialized and Python/pip are available
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
  fi

  if ! command -v python >/dev/null 2>&1 || ! command -v pip >/dev/null 2>&1; then
    warn "Python or pip not available, skipping Python package installation"
    return 1
  fi

  run "Installing Python packages from configuration"

  # Load configuration using config functions
  load_configs

  # Get pip packages from configuration
  local packages_list=$(get_pip_packages)
  local packages_to_install=()

  # Convert space-separated string to array
  if [[ -n "$packages_list" ]]; then
    read -ra packages_to_install <<< "$packages_list"
  fi

  # Skip Python package installation if no packages configured
  if [[ ${#packages_to_install[@]} -eq 0 ]]; then
    ok "No Python packages configured in config.toml - skipping pip installation"
    return 0
  fi

  local success_count=0
  local total_count=${#packages_to_install[@]}

  run "Installing ${total_count} Python packages"

  for package_name in "${packages_to_install[@]}"; do
    if python_install "$package_name"; then
      ((success_count++))
    fi
  done

  if [[ $success_count -eq $total_count ]]; then
    ok "All Python packages installed successfully ($success_count/$total_count)"
    return 0
  else
    warn "Some Python packages failed to install ($success_count/$total_count succeeded)"
    return 1
  fi
}
