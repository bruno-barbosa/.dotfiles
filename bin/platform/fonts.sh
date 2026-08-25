#!/usr/bin/env bash
# =====================================================================
#  bin/platform/fonts.sh
#  Installs Maple Mono NF (Nerd Font patched) on macOS and Linux.
#
#  The fonts are NOT vendored in this repo on purpose: the NF archive is
#  ~21MB zipped / ~38MB extracted, which every clone would pay for
#  forever. Windows installs the same family via the scoop nerd-fonts
#  bucket (see .config/config.yaml -> setup.packages.windows).
#
#  Scratch files go to mktemp -d and are left for the OS to reap, so
#  this script never deletes anything.
# =====================================================================

set -euo pipefail

FONT_NAME="MapleMono-NF"
FONT_REPO="subframe7536/maple-font"

font_already_installed() {
  if command -v fc-list >/dev/null 2>&1; then
    fc-list 2>/dev/null | grep -qi "Maple Mono NF" && return 0
  fi
  # macOS has no fontconfig by default
  [ -f "$HOME/Library/Fonts/MapleMono-NF-Regular.ttf" ] && return 0
  [ -f "$HOME/.local/share/fonts/MapleMono-NF-Regular.ttf" ] && return 0
  return 1
}

install_font_from_release() {
  local target_dir="$1"
  local tmp
  tmp="$(mktemp -d)"

  local url="https://github.com/${FONT_REPO}/releases/latest/download/${FONT_NAME}.zip"
  echo "  downloading ${FONT_NAME} from ${FONT_REPO}"
  if ! curl -fsSL -o "$tmp/font.zip" "$url"; then
    echo "  !! failed to download $url" >&2
    return 1
  fi

  mkdir -p "$target_dir"
  unzip -qo "$tmp/font.zip" -d "$tmp/extracted"
  find "$tmp/extracted" -name '*.ttf' -exec cp -f {} "$target_dir/" \;
  echo "  installed to $target_dir  (scratch left in $tmp)"
}

install_font_macos() {
  if command -v brew >/dev/null 2>&1; then
    brew install --cask font-maple-mono-nf && return 0
  fi
  install_font_from_release "$HOME/Library/Fonts"
}

install_font_linux() {
  install_font_from_release "$HOME/.local/share/fonts"
  if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
  fi
}

install_fonts() {
  if font_already_installed; then
    echo "  Maple Mono NF already installed"
    return 0
  fi

  case "$(uname -s)" in
    Darwin) install_font_macos ;;
    Linux)  install_font_linux ;;
    *)      echo "  unsupported platform for font install: $(uname -s)" >&2; return 1 ;;
  esac
}

# allow both `source fonts.sh` and direct execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  install_fonts
fi