#!/usr/bin/env bash

######################################
# Installs uv (Python package and version manager) and the Python CLI tools
# listed under setup.packages.python in .config/config.yaml.
#
# uv replaces the pyenv + pip pair this used to run: it installs and pins
# CPython builds itself (`uv python install`), keeps global CLI tools in
# isolated environments (`uv tool install`), and resolves project
# dependencies. One static binary, no compiler toolchain, no shims in the
# prompt path.
######################################

# Where uv's own installer puts the binary. Already on PATH via .path.zsh,
# but this script also has to work in the middle of a fresh install, before
# any new shell has been started.
UV_BIN_DIR="$HOME/.local/bin"

# Make uv callable in the current session regardless of how it was installed.
function _ensure_uv_on_path() {
  if [[ -d "$UV_BIN_DIR" ]] && [[ ":$PATH:" != *":$UV_BIN_DIR:"* ]]; then
    export PATH="$UV_BIN_DIR:$PATH"
  fi
}

function check_python() {
  run "Checking uv installation"

  _ensure_uv_on_path

  # Check if uv is already installed and working
  if command -v uv >/dev/null 2>&1 && uv --version >/dev/null 2>&1; then
    ok "uv already installed ($(uv --version))"
  else
    action "Installing uv (Python package and version manager)"

    # Prefer the platform package manager where there is one, so uv is
    # upgraded alongside everything else; fall back to the official installer.
    local installed=false

    if [[ "$IS_MACOS" == "true" ]] && command -v brew >/dev/null 2>&1; then
      run "Installing uv via Homebrew"
      if brew install uv; then
        installed=true
      else
        warn "Homebrew install of uv failed, falling back to the official installer"
      fi
    fi

    if [[ "$installed" != "true" ]]; then
      run "Downloading and installing uv"
      if curl -LsSf https://astral.sh/uv/install.sh | sh; then
        installed=true
      fi
    fi

    _ensure_uv_on_path

    if [[ "$installed" == "true" ]] && command -v uv >/dev/null 2>&1; then
      ok "uv installation completed ($(uv --version))"
    else
      error "uv installation failed - command not available"
      return 1
    fi
  fi

  # Install a managed CPython. `uv python install` with no argument grabs the
  # latest stable release; uv downloads a prebuilt standalone interpreter, so
  # unlike pyenv this needs no build-time dev headers.
  run "Installing the latest managed CPython"
  if uv python install; then
    # --managed-python so this reports uv's interpreter rather than whichever
    # system python3 happens to be first on PATH.
    local python_version
    python_version=$(uv run --no-project --managed-python python --version 2>/dev/null)
    ok "Managed Python ready${python_version:+ ($python_version)}"
  else
    warn "Could not install a managed Python, but uv is available"
  fi

  return 0
}

# uv tool installer helper function
function python_install() {
  local package_name="$1"
  local package_options="$2"

  run "Installing Python tool: $package_name $package_options"

  # `uv tool install` gives each tool its own virtualenv and links the entry
  # points into ~/.local/bin - the equivalent of pipx, not of `pip install -g`.
  if uv tool install "$package_name" $package_options; then
    ok "Successfully installed $package_name"
    return 0
  else
    error "Failed to install Python tool: $package_name"
    return 1
  fi
}

function python_installer_start() {
  _ensure_uv_on_path

  if ! command -v uv >/dev/null 2>&1; then
    warn "uv not available, skipping Python tool installation"
    return 1
  fi

  run "Installing Python tools from configuration"

  # Load configuration using config functions
  load_configs

  # Get python tools from configuration
  local packages_list=$(get_python_tools)
  local packages_to_install=()

  # Convert space-separated string to array - bash 3.2+ compatible
  if [[ -n "$packages_list" ]]; then
    IFS=' ' read -ra packages_to_install <<< "$packages_list"
  fi

  # Skip Python tool installation if none configured
  if [[ ${#packages_to_install[@]} -eq 0 ]]; then
    ok "No Python tools configured in config.yaml - skipping uv tool installation"
    return 0
  fi

  local success_count=0
  local total_count=${#packages_to_install[@]}

  run "Installing ${total_count} Python tools"

  for package_name in "${packages_to_install[@]}"; do
    if python_install "$package_name"; then
      ((success_count++))
    fi
  done

  if [[ $success_count -eq $total_count ]]; then
    ok "All Python tools installed successfully ($success_count/$total_count)"
    return 0
  else
    warn "Some Python tools failed to install ($success_count/$total_count succeeded)"
    return 1
  fi
}
