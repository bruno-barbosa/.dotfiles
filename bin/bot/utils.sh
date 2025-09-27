#!/usr/bin/env bash

######################################
# Utility functions for dotfiles
######################################

# Helper function for creating symlinks
function link_dotfile() {
  local source_file="$1"
  local target_file="$2"
  local backup_file="${target_file}.bkp"

  # Remove existing symlink or backup existing file
  if [[ -L "$target_file" ]]; then
    rm "$target_file"
  elif [[ -f "$target_file" ]]; then
    if [[ "$UPDATE_MODE" == "true" ]] || [[ ! -f "$backup_file" ]]; then
      mv "$target_file" "$backup_file" 2>/dev/null || true
    fi
  fi

  # Create new symlink
  ln -sf "$source_file" "$target_file"
}

# Additional utility functions can be added here as needed