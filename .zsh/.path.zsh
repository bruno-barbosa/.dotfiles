# Environment Variables and PATH Configuration

# Go configuration
export GOPATH=$HOME/.go

# Node environments (Volta)
export VOLTA_HOME="$HOME/.volta"

# Python toolchain (uv). Where `uv tool install` links tool entry points --
# this is uv's own default, pinned so it stays put if XDG_BIN_HOME is ever
# set. The directory itself is added to PATH below.
export UV_TOOL_BIN_DIR="$HOME/.local/bin"

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

# Git subcommands
add_to_path "$HOME/.dotfiles/.config/git/subcommands"

# Version managers
add_to_path "$VOLTA_HOME/bin"
add_to_path "$HOME/.rbenv/bin"

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
  # rustup is keg-only on Homebrew; expose cargo/rustc proxies
  add_to_path "/opt/homebrew/opt/rustup/bin"
elif [[ "$IS_LINUX" == "true" ]]; then
  # Linux-specific paths
  add_to_path "/snap/bin"
  add_to_path "/usr/games"
  add_to_path "/usr/local/games"
fi

# Initialize version managers (only if installed)
# uv needs no init hook: it is a single binary in ~/.local/bin, with no
# shims and nothing to eval at shell start.

# rbenv initialization (only if installed)
if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

# GVM initialization (only if installed)
if [[ -s "$HOME/.gvm/scripts/gvm" ]]; then
  source "$HOME/.gvm/scripts/gvm"
fi

