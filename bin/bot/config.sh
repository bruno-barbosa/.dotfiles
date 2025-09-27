#!/usr/bin/env bash

######################################
# Configuration loader for TOML files
######################################

# Global associative arrays to store configuration
declare -A CONFIG_SETUP_PACKAGES_SHARED
declare -A CONFIG_SETUP_PACKAGES_DEBIAN
declare -A CONFIG_SETUP_PACKAGES_OSX
declare -A CONFIG_GEMS
declare -A CONFIG_PIP
declare -A CONFIG_NODE

# Function to parse TOML and load configuration
function load_configs() {
    local config_file="${1:-$HOME/.dotfiles/.config/config.toml}"

    if [[ ! -f "$config_file" ]]; then
        error "Configuration file not found: $config_file"
        return 1
    fi

    run "loading configuration from $config_file"

    # Check if tomlq is available for TOML parsing
    if command -v tomlq >/dev/null 2>&1; then
        _load_config_with_tomlq "$config_file"
    else
        _load_config_manual "$config_file"
    fi

    ok "configuration loaded successfully"
}

# Load configuration using tomlq (if available)
function _load_config_with_tomlq() {
    local config_file="$1"

    # Load shared packages
    local shared_packages
    shared_packages=$(tomlq -r '.setup.packages.shared[]?' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$shared_packages" ]]; then
        CONFIG_SETUP_PACKAGES_SHARED[packages]="$shared_packages"
    fi

    # Load debian packages
    local debian_packages
    debian_packages=$(tomlq -r '.setup.packages.debian[]?' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$debian_packages" ]]; then
        CONFIG_SETUP_PACKAGES_DEBIAN[packages]="$debian_packages"
    fi

    # Load osx packages
    local osx_packages
    osx_packages=$(tomlq -r '.setup.packages.osx[]?' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$osx_packages" ]]; then
        CONFIG_SETUP_PACKAGES_OSX[packages]="$osx_packages"
    fi

    # Load gems
    local gems
    gems=$(tomlq -r '.setup.packages.gems[]?' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$gems" ]]; then
        CONFIG_GEMS[packages]="$gems"
    fi

    # Load pip packages
    local pip_packages
    pip_packages=$(tomlq -r '.setup.packages.pip[]?' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$pip_packages" ]]; then
        CONFIG_PIP[packages]="$pip_packages"
    fi

    # Load node packages
    local node_packages
    node_packages=$(tomlq -r '.setup.packages.node[]?' "$config_file" 2>/dev/null | tr '\n' ' ')
    if [[ -n "$node_packages" ]]; then
        CONFIG_NODE[packages]="$node_packages"
    fi
}

# Manual TOML parsing (fallback when yq is not available)
function _load_config_manual() {
    local config_file="$1"
    local current_section=""
    local current_array=""
    local packages=""

    while IFS= read -r line; do
        # Remove leading/trailing whitespace
        line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        # Parse sections
        if [[ "$line" =~ ^\[(.+)\]$ ]]; then
            # Save previous array if we have one
            if [[ -n "$current_array" && -n "$packages" ]]; then
                _save_packages "$current_array" "$packages"
                packages=""
            fi

            current_section="${BASH_REMATCH[1]}"

            # Determine current array type
            case "$current_section" in
                "setup.packages") current_array="" ;;
                *) current_array="" ;;
            esac
            continue
        fi

        # Parse array definitions
        if [[ "$line" =~ ^([a-zA-Z_]+)[[:space:]]*=[[:space:]]*\[(.*)$ ]]; then
            # Save previous array if we have one
            if [[ -n "$current_array" && -n "$packages" ]]; then
                _save_packages "$current_array" "$packages"
                packages=""
            fi

            local array_name="${BASH_REMATCH[1]}"
            local array_content="${BASH_REMATCH[2]}"
            current_array="$array_name"

            # Handle single-line arrays
            if [[ "$array_content" =~ ^(.*)]\s*$ ]]; then
                array_content="${BASH_REMATCH[1]}"
                _parse_array_content "$array_content"
                _save_packages "$current_array" "$packages"
                packages=""
                current_array=""
            else
                _parse_array_content "$array_content"
            fi
            continue
        fi

        # Handle multi-line array content
        if [[ -n "$current_array" ]]; then
            if [[ "$line" =~ ^(.*)]\s*$ ]]; then
                # End of array
                local content="${BASH_REMATCH[1]}"
                _parse_array_content "$content"
                _save_packages "$current_array" "$packages"
                packages=""
                current_array=""
            else
                _parse_array_content "$line"
            fi
        fi
    done < "$config_file"

    # Save final array if we have one
    if [[ -n "$current_array" && -n "$packages" ]]; then
        _save_packages "$current_array" "$packages"
    fi
}

# Parse array content and extract package names
function _parse_array_content() {
    local content="$1"

    # Remove quotes and extract package names
    local extracted
    extracted=$(echo "$content" | grep -o '"[^"]*"' | sed 's/"//g' | tr '\n' ' ')
    if [[ -n "$extracted" ]]; then
        packages="$packages $extracted"
    fi
}

# Save packages to appropriate global array
function _save_packages() {
    local array_name="$1"
    local package_list="$2"

    # Trim whitespace
    package_list=$(echo "$package_list" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    case "$array_name" in
        "shared")
            CONFIG_SETUP_PACKAGES_SHARED[packages]="$package_list"
            ;;
        "debian")
            CONFIG_SETUP_PACKAGES_DEBIAN[packages]="$package_list"
            ;;
        "osx")
            CONFIG_SETUP_PACKAGES_OSX[packages]="$package_list"
            ;;
        "gems")
            CONFIG_GEMS[packages]="$package_list"
            ;;
        "pip")
            CONFIG_PIP[packages]="$package_list"
            ;;
        "node")
            CONFIG_NODE[packages]="$package_list"
            ;;
    esac
}

# Get packages for current platform
function get_packages() {
    local platform="${1:-auto}"

    if [[ "$platform" == "auto" ]]; then
        if [[ "$IS_MACOS" == "true" ]]; then
            platform="osx"
        elif [[ "$IS_LINUX" == "true" ]]; then
            platform="debian"
        fi
    fi

    local shared_packages="${CONFIG_SETUP_PACKAGES_SHARED[packages]:-}"
    local platform_packages=""

    case "$platform" in
        "osx")
            platform_packages="${CONFIG_SETUP_PACKAGES_OSX[packages]:-}"
            ;;
        "debian")
            platform_packages="${CONFIG_SETUP_PACKAGES_DEBIAN[packages]:-}"
            ;;
    esac

    echo "$shared_packages $platform_packages" | xargs
}

# Get gems packages
function get_gems() {
    echo "${CONFIG_GEMS[packages]:-}" | xargs
}

# Get pip packages
function get_pip_packages() {
    echo "${CONFIG_PIP[packages]:-}" | xargs
}

# Get node packages
function get_node_packages() {
    echo "${CONFIG_NODE[packages]:-}" | xargs
}

# Print configuration (for debugging)
function print_config() {
    echo "=== Configuration ==="
    echo "Shared packages: ${CONFIG_SETUP_PACKAGES_SHARED[packages]:-none}"
    echo "Debian packages: ${CONFIG_SETUP_PACKAGES_DEBIAN[packages]:-none}"
    echo "OSX packages: ${CONFIG_SETUP_PACKAGES_OSX[packages]:-none}"
    echo "Gems: ${CONFIG_GEMS[packages]:-none}"
    echo "Pip packages: ${CONFIG_PIP[packages]:-none}"
    echo "Node packages: ${CONFIG_NODE[packages]:-none}"
    echo "===================="
}