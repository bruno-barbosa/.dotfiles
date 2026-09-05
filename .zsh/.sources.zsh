export ZSH_PATH=$HOME/.dotfiles/.zsh

# Platform detection (must be sourced first)
source $ZSH_PATH/.platform.zsh

# WSL-only settings. detect_os (above) exports IS_WSL, so this whole file --
# and the Windows-interop assumptions in it -- stays out of the way on macOS
# and on native Linux.
if [ "${IS_WSL:-false}" = "true" ]; then
  source $ZSH_PATH/.wsl.zsh
fi

# ZSH Sources
source $ZSH_PATH/aliases/.aliases.zsh
source $ZSH_PATH/functions/.functions.zsh
