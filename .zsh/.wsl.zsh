# =====================================================================
#  .zsh/.wsl.zsh
#  WSL-only shell configuration.
#  Sourced from .sources.zsh only when .platform.zsh set IS_WSL=true, so
#  everything in here is safe to keep in version control: on macOS and on
#  bare Linux the file is never read.
# =====================================================================

# ------------------------------------------------- opening things
# WSL has no X/Wayland browser and no xdg-open, so anything that wants to
# open a URL -- `gh auth login`, a dev server, an OAuth redirect, python's
# webbrowser module -- silently does nothing.
#
# The usual fix is wslu, which provides wslview. That package is gone from
# the Ubuntu archives (absent in 26.04; ubuntu-wsl no longer depends on it),
# so the repo ships bin/wsl/wsl-open to do the same job with cmd.exe. wslu
# is still preferred where it exists -- on an older release, or installed by
# hand -- and wsl-open defers to it too.
#
# bin/wsl also goes on PATH, which puts an xdg-open on it: the symlink next
# to wsl-open. That deliberately shadows xdg-utils' xdg-open, which cannot
# work here anyway -- it has no desktop session to hand the URL to -- and it
# catches the tools that call xdg-open directly instead of reading $BROWSER.
add_to_path "$HOME/.dotfiles/bin/wsl"

if command -v wslview >/dev/null 2>&1; then
  BROWSER="$(command -v wslview)"
else
  BROWSER="$HOME/.dotfiles/bin/wsl/wsl-open"
fi
export BROWSER
