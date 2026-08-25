# =====================================================================
#  .zsh/.tools.zsh
#  Prompt + modern CLI initialisation for zsh (macOS / Linux / WSL).
#  Deliberately mirrors .pwsh/profile.ps1 so both shells behave alike.
#  Sourced at the END of .zshrc -- oh-my-zsh sets its own prompt and
#  would clobber starship if this ran earlier.
# =====================================================================

# ---------------------------------------------------------- starship
# Same file the PowerShell side loads: one prompt on all three platforms.
export STARSHIP_CONFIG="$HOME/.dotfiles/.config/starship/starship.toml"
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ------------------------------------------------------------ zoxide
# Wraps cd: still behaves like cd for real paths, and learns as you go.
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# --------------------------------------------------------------- fzf
export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border=rounded --info=inline \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

if command -v fzf >/dev/null 2>&1; then
  # ctrl-r history / ctrl-t files, same chords as the PowerShell side
  if [ -n "${ZSH_VERSION:-}" ]; then
    source <(fzf --zsh) 2>/dev/null || true
  fi
fi

# --------------------------------------------------------------- eza
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l  --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
fi

# --------------------------------------------------------------- bat
# Not aliased over cat on purpose -- scripts expect real cat.
if command -v bat >/dev/null 2>&1; then
  export BAT_THEME="Catppuccin Mocha"
  alias bcat='bat --style=full'
elif command -v batcat >/dev/null 2>&1; then
  # Debian/Ubuntu ship the binary as batcat
  export BAT_THEME="Catppuccin Mocha"
  alias bat='batcat'
  alias bcat='batcat --style=full'
fi