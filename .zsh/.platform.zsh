# Platform Detection Utilities
# Detects the current platform and sets appropriate variables

# Detect OS
function detect_os() {
  case "$(uname -s)" in
    Darwin)
      export OS="macOS"
      export IS_MACOS=true
      export IS_LINUX=false
      export PACKAGE_MANAGER="brew"
      ;;
    Linux)
      export OS="Linux"
      export IS_MACOS=false
      export IS_LINUX=true
      if command -v apt-get >/dev/null 2>&1; then
        export PACKAGE_MANAGER="apt"
        export DISTRO="debian"
      elif command -v yum >/dev/null 2>&1; then
        export PACKAGE_MANAGER="yum"
        export DISTRO="rhel"
      elif command -v pacman >/dev/null 2>&1; then
        export PACKAGE_MANAGER="pacman"
        export DISTRO="arch"
      else
        export PACKAGE_MANAGER="unknown"
        export DISTRO="unknown"
      fi
      ;;
    *)
      export OS="Unknown"
      export IS_MACOS=false
      export IS_LINUX=false
      export PACKAGE_MANAGER="unknown"
      ;;
  esac
}

# Platform-specific path helper
function add_to_path() {
  local path_to_add="$1"
  if [ -d "$path_to_add" ]; then
    export PATH="$path_to_add:$PATH"
  fi
}

# Platform-specific alias helper
function alias_if_exists() {
  local alias_name="$1"
  local command_path="$2"
  if command -v "$command_path" >/dev/null 2>&1; then
    alias "$alias_name"="$command_path"
  fi
}

# Initialize platform detection
detect_os