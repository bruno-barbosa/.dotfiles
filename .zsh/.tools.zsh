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

if command -v fzf >/dev/null 2>&1 && [ -n "${ZSH_VERSION:-}" ]; then
  # ctrl-r history / ctrl-t files, same chords as the PowerShell side.
  #
  # `fzf --zsh` only exists from fzf 0.48. Ubuntu 22.04 ships 0.29 and Debian
  # 12 ships 0.38, so on those the bindings have to come from the key-bindings
  # script the distro drops in /usr/share. Without this fallback the older
  # boxes silently lose ctrl-r/ctrl-t while PowerShell keeps them, which is
  # exactly the parity this file exists to guarantee.
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for _fzf_dir in \
      /usr/share/doc/fzf/examples \
      /usr/share/fzf/shell \
      /usr/share/zsh/vendor-completions \
      "${HOMEBREW_PREFIX:-/opt/homebrew}/opt/fzf/shell" \
      /usr/local/opt/fzf/shell
    do
      [ -f "$_fzf_dir/key-bindings.zsh" ] && source "$_fzf_dir/key-bindings.zsh"
      [ -f "$_fzf_dir/completion.zsh" ]   && source "$_fzf_dir/completion.zsh"
    done
    unset _fzf_dir
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

# ---------------------------------------------------------------- uv
# Python toolchain: version manager, package manager and tool runner.
# No init hook and no shims -- only completions are worth loading, and
# `uv generate-shell-completion` is cheap enough to run at startup.
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
  # uvx is a real binary shipped alongside uv, but it has its own
  # completion namespace.
  command -v uvx >/dev/null 2>&1 && eval "$(uvx --generate-shell-completion zsh)"
fi
