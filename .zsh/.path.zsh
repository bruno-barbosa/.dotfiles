# Environment Variables and PATH Configuration

# Go configuration
export GOPATH=$HOME/.go

# Node environments (Volta)
export VOLTA_HOME="$HOME/.volta"

# Python environments (pyenv)
export PYENV_ROOT="$HOME/.pyenv"

# Platform-specific environment variables
if [[ "$IS_MACOS" == "true" ]]; then
  # macOS-specific environments
  export ANDROID_HOME="~/Library/Android/sdk"
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
elif [[ "$IS_LINUX" == "true" ]]; then
  # Linux-specific environments can be added here
  export ANDROID_HOME="$HOME/Android/Sdk"
fi

# Common paths for all Unix systems
add_to_path "/usr/local/sbin"
add_to_path "/usr/local/bin"
add_to_path "$HOME/.local/bin"

# Version managers
add_to_path "$VOLTA_HOME/bin"
add_to_path "$HOME/.rvm/bin"
add_to_path "$HOME/.pyenv/bin"

# Go paths
add_to_path "$HOME/.go/bin"
add_to_path "$HOME/go/bin"

# Rust/Cargo
add_to_path "$HOME/.cargo/bin"

# Platform-specific paths
if [[ "$IS_MACOS" == "true" ]]; then
  # macOS-specific paths
  add_to_path "/opt/homebrew/bin"
  add_to_path "/usr/local/opt"
elif [[ "$IS_LINUX" == "true" ]]; then
  # Linux-specific paths
  add_to_path "/snap/bin"
  add_to_path "/usr/games"
  add_to_path "/usr/local/games"
fi

# Initialize version managers (only if installed)
# pyenv initialization
if [[ -d "$PYENV_ROOT/bin" ]]; then
  add_to_path "$PYENV_ROOT/bin"
  if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
  fi
fi

# RVM initialization (only if installed)
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  source "$HOME/.rvm/scripts/rvm"
fi

# GVM initialization (only if installed)
if [[ -s "$HOME/.gvm/scripts/gvm" ]]; then
  source "$HOME/.gvm/scripts/gvm"
fi

