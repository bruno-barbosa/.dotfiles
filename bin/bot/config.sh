#!/usr/bin/env bash

######################################
# Configuration loader for YAML files
######################################

# Global variables to store configuration (bash 3.2+ compatible)
CONFIG_SETUP_PACKAGES_SHARED=""
CONFIG_SETUP_PACKAGES_DEBIAN=""
CONFIG_SETUP_PACKAGES_OSX=""
CONFIG_GEMS=""
CONFIG_PIP=""
CONFIG_NODE=""

# Install yq if not available (platform agnostic)
function _install_yq() {
    run "yq not found, attempting to install..."

    # Detect OS and install accordingly
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use Homebrew
        if command -v brew >/dev/null 2>&1; then
            run "installing yq via Homebrew..."
            if brew install yq; then
                ok "yq installed successfully"
                return 0
            else
                warn "failed to install yq via Homebrew"
            fi
        else
            warn "Homebrew not found on macOS"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - try different package managers
        if command -v apt-get >/dev/null 2>&1; then
            # Debian/Ubuntu - install via snap or direct download
            if command -v snap >/dev/null 2>&1; then
                run "installing yq via snap..."
                if sudo snap install yq; then
                    ok "yq installed successfully via snap"
                    return 0
                fi
            fi

            # Fallback to direct download
            run "installing yq via direct download..."
            if _install_yq_direct; then
                ok "yq installed successfully via direct download"
                return 0
            fi
        elif command -v yum >/dev/null 2>&1; then
            # RHEL/CentOS - direct download
            run "installing yq via direct download..."
            if _install_yq_direct; then
                ok "yq installed successfully"
                return 0
            fi
        elif command -v dnf >/dev/null 2>&1; then
            # Fedora - direct download
            run "installing yq via direct download..."
            if _install_yq_direct; then
                ok "yq installed successfully"
                return 0
            fi
        fi
    fi

    # Try pip as last resort (cross-platform)
    if command -v pip >/dev/null 2>&1 || command -v pip3 >/dev/null 2>&1; then
        run "attempting to install yq via pip..."
        local pip_cmd="pip"
        if command -v pip3 >/dev/null 2>&1; then
            pip_cmd="pip3"
        fi

        if $pip_cmd install yq; then
            ok "yq installed successfully via pip"
            return 0
        else
            warn "failed to install yq via pip"
        fi
    fi

    warn "could not install tomlq/yq automatically"
    return 1
}

# Install yq via direct download (GitHub releases)
function _install_yq_direct() {
    local install_dir="/usr/local/bin"
    local yq_url
    local yq_binary="yq"

    # Detect architecture
    local arch
    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        arm64|aarch64) arch="arm64" ;;
        armv7l) arch="arm" ;;
        *)
            warn "unsupported architecture: $(uname -m)"
            return 1
            ;;
    esac

    # Detect OS for binary name
    local os
    case "$(uname -s)" in
        Darwin) os="darwin" ;;
        Linux) os="linux" ;;
        *)
            warn "unsupported OS: $(uname -s)"
            return 1
            ;;
    esac

    # Construct download URL (using latest release)
    yq_url="https://github.com/mikefarah/yq/releases/latest/download/yq_${os}_${arch}"

    # Download and install
    if command -v curl >/dev/null 2>&1; then
        if sudo curl -L "$yq_url" -o "$install_dir/$yq_binary" && sudo chmod +x "$install_dir/$yq_binary"; then
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        if sudo wget "$yq_url" -O "$install_dir/$yq_binary" && sudo chmod +x "$install_dir/$yq_binary"; then
            return 0
        fi
    fi

    return 1
}

# Function to parse YAML and load configuration
function load_configs() {
    local config_file="${1:-$HOME/.dotfiles/.config/config.yaml}"

    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    fi

    run "loading configuration from $config_file"

    # Check if yq is available for YAML parsing
    if command -v yq >/dev/null 2>&1; then
        _load_config_with_yq "$config_file"
    else
        # Try to install yq if not available
        if _install_yq; then
            _load_config_with_yq "$config_file"
        else
            error "Failed to install yq and cannot parse YAML configuration"
            return 1
        fi
    fi

    ok "configuration loaded successfully"
}

# Load configuration using yq (if available)
function _load_config_with_yq() {
    local config_file="$1"

    # Load shared packages
    local shared_packages
    shared_packages=$(yq e '.setup.packages.shared[]' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$shared_packages" ]]; then
        CONFIG_SETUP_PACKAGES_SHARED="$shared_packages"
    fi

    # Load debian packages
    local debian_packages
    debian_packages=$(yq e '.setup.packages.debian[]' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$debian_packages" ]]; then
        CONFIG_SETUP_PACKAGES_DEBIAN="$debian_packages"
    fi

    # Load osx packages
    local osx_packages
    osx_packages=$(yq e '.setup.packages.osx[]' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$osx_packages" ]]; then
        CONFIG_SETUP_PACKAGES_OSX="$osx_packages"
    fi

    # Load gems
    local gems
    gems=$(yq e '.setup.packages.gems[]' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$gems" ]]; then
        CONFIG_GEMS="$gems"
    fi

    # Load pip packages
    local pip_packages
    pip_packages=$(yq e '.setup.packages.pip[]' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$pip_packages" ]]; then
        CONFIG_PIP="$pip_packages"
    fi

    # Load node packages
    local node_packages
    node_packages=$(yq e '.setup.packages.node[]' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$node_packages" ]]; then
        CONFIG_NODE="$node_packages"
    fi
}


# Get packages for current platformthi
function get_packages() {
    local platform="${1:-auto}"

    if [[ "$platform" == "auto" ]]; then
        if [[ "$IS_MACOS" == "true" ]]; then
            platform="osx"
        elif [[ "$IS_LINUX" == "true" ]]; then
            platform="debian"
        fi
    fi

    local shared_packages="${CONFIG_SETUP_PACKAGES_SHARED:-}"
    local platform_packages=""

    case "$platform" in
        "osx")
            platform_packages="${CONFIG_SETUP_PACKAGES_OSX:-}"
            ;;
        "debian")
            platform_packages="${CONFIG_SETUP_PACKAGES_DEBIAN:-}"
            ;;
    esac

    echo "$shared_packages $platform_packages" | xargs
}

# Get gems packages
function get_gems() {
    echo "${CONFIG_GEMS:-}" | xargs
}

# Get pip packages
function get_pip_packages() {
    echo "${CONFIG_PIP:-}" | xargs
}

# Get node packages
function get_node_packages() {
    echo "${CONFIG_NODE:-}" | xargs
}

# Print configuration (for debugging)
function print_config() {
    echo "=== Configuration ==="
    echo "Shared packages: ${CONFIG_SETUP_PACKAGES_SHARED:-none}"
    echo "Debian packages: ${CONFIG_SETUP_PACKAGES_DEBIAN:-none}"
    echo "OSX packages: ${CONFIG_SETUP_PACKAGES_OSX:-none}"
    echo "Gems: ${CONFIG_GEMS:-none}"
    echo "Pip packages: ${CONFIG_PIP:-none}"
    echo "Node packages: ${CONFIG_NODE:-none}"
    echo "===================="
}