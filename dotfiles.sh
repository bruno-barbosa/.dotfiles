#!/usr/bin/env bash

######################################
# Cross-platform dotfiles installer
# @author Bruno Barbosa
######################################

# Set strict error handling, but allow specific sections to handle their own errors
set -e

###############################################################################
# INITIALIZATION AND SETUP
###############################################################################

# Check if we're in the dotfiles directory
if [[ ! -f "./bin/setup.sh" ]]; then
  echo "Error: Please run this script from the dotfiles directory"
  exit 1
fi

# Parse command line arguments
UPDATE_MODE=false
case "$1" in
  --update)
    UPDATE_MODE=true
    ;;
  --help|-h)
    echo "Dotfiles installer - Cross-platform development environment setup"
    echo ""
    echo "Usage:"
    echo "  ./dotfiles.sh         - Fresh installation of dotfiles"
    echo "  ./dotfiles.sh --update - Update existing configuration and packages"
    echo "  ./dotfiles.sh --help   - Show this help message"
    echo ""
    echo "Features:"
    echo "  - Cross-platform support (macOS/Linux)"
    echo "  - Package manager setup (Homebrew/apt)"
    echo "  - Version managers (Volta, Ruby, pyenv)"
    echo "  - Zsh configuration with oh-my-zsh"
    echo "  - Tmux configuration"
    echo "  - Git configuration"
    echo ""
    exit 0
    ;;
  "")
    # No arguments - proceed with installation
    ;;
  *)
    echo "Unknown option: $1"
    echo "Use --help for usage information"
    exit 1
    ;;
esac

# Include libraries
source ./bin/setup.sh

###############################################################################
# PLATFORM DETECTION AND INITIALIZATION
###############################################################################

# Detect operating system
function detect_platform() {
  case "$(uname -s)" in
    Darwin)
      export OS="macOS"
      export IS_MACOS=true
      export IS_LINUX=false
      ;;
    Linux)
      export OS="Linux"
      export IS_MACOS=false
      export IS_LINUX=true
      ;;
    *)
      echo "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac

  bot "Detected OS: $OS"
}

detect_platform

# Show installation mode
if [[ "$UPDATE_MODE" == "true" ]]; then
  bot "Running in UPDATE mode - will refresh all settings and packages"
else
  bot "Running in INSTALL mode - will perform fresh installation"
fi

# Initialize error logging
init_error_log

###############################################################################
# INSTALLATION PLAN AND OVERVIEW
###############################################################################

bot "Hey there! I'm Eros, setting up your development environment for $OS."

bot "Installation Plan:"
todo_start "Set up package manager and install packages"
todo_start "Configure shell environment (zsh + oh-my-zsh + powerlevel10k)"
if [[ "$IS_MACOS" == "true" ]]; then
  todo_start "Apply macOS system defaults (optional)"
fi
todo_start "Configure vim editor and plugins"
todo_start "Configure git settings"
todo_start "Install development version managers (Volta, Ruby, pyenv)"
echo ""

bot "Let's start the installation process..."

###############################################################################
# SUDO CONFIGURATION AND PERMISSIONS
###############################################################################

# Request administrator rights and configure sudo (if needed)
if [[ "$IS_MACOS" == "true" ]]; then
  # Check if passwordless sudo is already configured
  if sudo grep -q "^%wheel.*NOPASSWD" "/etc/sudoers" 2>/dev/null || sudo -n true 2>/dev/null; then
    ok "Passwordless sudo already configured"
  else
    bot "I need you to enter your sudo password so I can install some things:"
    sudo -v

    # Keep-alive: update existing sudo time stamp until the script has finished
    while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" || exit
    done 2>/dev/null &

    bot "Do you want me to setup this machine to allow you to run sudo without a password?"
    bot "This is a macOS-specific configuration."
    read -r -p "Make sudo passwordless on macOS? [y|N] " response

    if [[ $response =~ (yes|y|Y) ]]; then
      # macOS uses different sed syntax
      sudo sed -i '' 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers 2>/dev/null
      if [[ $? != 0 ]]; then
        sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers 2>/dev/null
      fi
      sudo dscl . append /Groups/wheel GroupMembership $(whoami) 2>/dev/null
      bot "You can now run sudo commands without password!"
    fi
  fi

elif [[ "$IS_LINUX" == "true" ]]; then
  # Check if passwordless sudo is already configured
  if sudo -n true 2>/dev/null; then
    ok "Passwordless sudo already configured"
  else
    bot "Linux detected. Requesting sudo access for installation..."
    sudo -v

    bot "Would you like to setup passwordless sudo for this user?"
    bot "This will allow you to run sudo commands without entering your password."
    read -r -p "Setup passwordless sudo? [y|N] " sudo_response

    if [[ $sudo_response =~ ^(y|yes|Y) ]]; then
      if setup_passwordless_sudo; then
        bot "Passwordless sudo has been configured successfully!"
      else
        warn "Passwordless sudo setup failed, but continuing installation..."
      fi
    else
      bot "Skipped passwordless sudo setup"
    fi
  fi
fi

###############################################################################
# PACKAGE MANAGER SETUP
###############################################################################

echo ""
action "Package Manager Setup"
todo_progress "Set up package manager and install packages"

if [[ "$IS_MACOS" == "true" ]]; then
  run "Checking Homebrew installation"
  local error_output
  if error_output=$(check_brew 2>&1); then
    if ! brew_installer_start; then
      warn "Some Homebrew packages failed to install, but continuing..."
    fi
  else
    error "Failed to setup Homebrew"
    log_error "Homebrew setup failed" "$error_output"
    exit 1
  fi

  if [[ "$UPDATE_MODE" == "true" ]]; then
    run "Updating Homebrew packages"
    if ! safe_run "brew update && brew upgrade" "Homebrew package updates"; then
      warn "Some Homebrew updates failed, but continuing..."
    fi
  fi

  run "Cleaning up Homebrew cache"
  safe_run "brew cleanup --force" "Homebrew cleanup" || true
  rm -rf /Library/Caches/Homebrew/* 2>/dev/null || true

elif [[ "$IS_LINUX" == "true" ]]; then
  run "Installing essential Linux packages"
  if ! unix_installer_start; then
    warn "Some Linux packages failed to install, but continuing..."
  fi
fi

todo_complete "Set up package manager and install packages"

###############################################################################
# SHELL ENVIRONMENT CONFIGURATION
###############################################################################

echo ""
action "Shell Environment Setup"
todo_progress "Configure shell environment (zsh + oh-my-zsh)"

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  run "Installing oh-my-zsh"
  local error_output
  if error_output=$(sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 2>&1); then
    ok "oh-my-zsh installed successfully"
  else
    # Try alternative installation method if the first one fails
    if [ -d "$HOME/.oh-my-zsh" ]; then
      ok "oh-my-zsh appears to be installed (detected after install attempt)"
    else
      warn "oh-my-zsh installation had issues, but continuing..."
      log_error "oh-my-zsh installation failed" "$error_output"
    fi
  fi
else
  ok "oh-my-zsh already installed"
fi

# Install powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
  run "Installing powerlevel10k theme"
  local error_output
  if error_output=$(git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" 2>&1); then
    ok "powerlevel10k theme installed successfully"

    # Inform user about p10k configuration
    bot "Powerlevel10k has been installed!"
    bot "After installation completes, restart your terminal or run 'source ~/.zshrc'"
    bot "Then run 'p10k configure' to set up your prompt."
  else
    warn "Failed to install powerlevel10k theme"
    log_error "powerlevel10k theme installation failed" "$error_output"
  fi
else
  ok "powerlevel10k theme already installed"
fi

# Install zsh plugins
run "Installing zsh plugins"

# Install zsh-autosuggestions plugin
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  local error_output
  if error_output=$(git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" 2>&1); then
    ok "zsh-autosuggestions plugin installed"
  else
    warn "Failed to install zsh-autosuggestions plugin"
    log_error "zsh-autosuggestions plugin installation failed" "$error_output"
  fi
else
  ok "zsh-autosuggestions plugin already installed"
fi

# Install zsh-syntax-highlighting plugin
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  local error_output
  if error_output=$(git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" 2>&1); then
    ok "zsh-syntax-highlighting plugin installed"
  else
    warn "Failed to install zsh-syntax-highlighting plugin"
    log_error "zsh-syntax-highlighting plugin installation failed" "$error_output"
  fi
else
  ok "zsh-syntax-highlighting plugin already installed"
fi

todo_complete "Configure shell environment (zsh + oh-my-zsh)"

###############################################################################
# PLATFORM-SPECIFIC CONFIGURATIONS
###############################################################################

# macOS system defaults (optional)
if [[ "$IS_MACOS" == "true" ]]; then
  echo ""
  action "macOS System Defaults (Optional)"
  todo_progress "Apply macOS system defaults (optional)"

  bot "Would you like to apply macOS system defaults?"
  bot "This will configure Dock, Finder, Safari, keyboard settings, and other macOS preferences for development."
  read -r -p "Apply macOS system defaults? [y|N] " response

  if [[ $response =~ ^(y|yes|Y) ]]; then
    if apply_macos_system_defaults; then
      todo_complete "Apply macOS system defaults (optional)"
    else
      todo_failed "Apply macOS system defaults (optional)"
    fi
  else
    todo_skip "Apply macOS system defaults (optional)"
  fi
fi

###############################################################################
# VIM EDITOR CONFIGURATION
###############################################################################

echo ""
action "Vim Editor Configuration"
todo_progress "Configure vim editor and plugins"

# Link vim configuration files
run "Linking vim configuration"
link_dotfile "$HOME/.dotfiles/.vim/.vimrc" "$HOME/.vimrc"
ok "vim configuration linked"

# Link vim directory
run "Linking vim directory"
if [[ -L "$HOME/.vim" ]]; then
  rm "$HOME/.vim"
elif [[ -d "$HOME/.vim" ]]; then
  mv "$HOME/.vim" "$HOME/.vim.bkp" 2>/dev/null || true
fi
ln -sf "$HOME/.dotfiles/.vim" "$HOME/.vim"
ok "vim directory linked"

# Install and configure vim-plug
run "Installing vim-plug plugin manager"
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
  if curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
    ok "vim-plug installed successfully"

    # Install plugins automatically if vim is available
    if command -v vim >/dev/null 2>&1; then
      run "Installing vim plugins"
      vim +PlugInstall +qall --not-a-term &>/dev/null && ok "vim plugins installed" || warn "Some vim plugins may have failed to install"
    fi
  else
    warn "vim-plug installation failed, but continuing..."
  fi
else
  ok "vim-plug already installed"

  # Ask user if they want to update vim plugins
  if command -v vim >/dev/null 2>&1; then
    bot "Would you like to update vim-plug and all vim plugins?"
    bot "This will update vim-plug itself and all installed plugins to their latest versions."
    read -r -p "Update vim plugins? [y|N] " vim_update_response

    if [[ $vim_update_response =~ ^(y|yes|Y) ]]; then
      run "Updating vim-plug"
      if curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim; then
        ok "vim-plug updated successfully"
      else
        warn "vim-plug update failed, but continuing..."
      fi

      run "Updating vim plugins"
      if vim +PlugUpdate +qall --not-a-term &>/dev/null; then
        ok "vim plugins updated successfully"
      else
        warn "Some vim plugin updates may have failed"
      fi

      run "Cleaning unused vim plugins"
      if vim +PlugClean! +qall --not-a-term &>/dev/null; then
        ok "vim plugins cleaned successfully"
      else
        warn "vim plugin cleanup may have failed"
      fi
    else
      ok "Skipped vim plugin updates"
    fi
  fi
fi

todo_complete "Configure vim editor and plugins"

###############################################################################
# DOTFILES CONFIGURATION (REMAINING)
###############################################################################

echo ""
action "Dotfiles Configuration"

# Link remaining configuration files (zsh and tmux)
run "Linking zsh configuration"
link_dotfile "$HOME/.dotfiles/.zsh/.zshrc" "$HOME/.zshrc"
ok "zsh configuration linked"

run "Linking tmux configuration"
link_dotfile "$HOME/.dotfiles/.config/.tmux.conf" "$HOME/.tmux.conf"
ok "tmux configuration linked"

###############################################################################
# GIT CONFIGURATION
###############################################################################

echo ""
action "Git Configuration"
todo_progress "Configure git settings"

if ! git_config; then
  warn "Git configuration setup had issues - you may need to configure manually"
  todo_failed "Configure git settings"
else
  todo_complete "Configure git settings"
fi

###############################################################################
# VERSION MANAGERS INSTALLATION
###############################################################################

echo ""
action "Version Managers Setup"
todo_progress "Install development version managers (Volta, Ruby, pyenv)"

# Ruby Version Manager (RVM)
bot "Would you like to install RVM (Ruby Version Manager)?"
bot "RVM allows you to easily install and manage multiple Ruby versions."
read -r -p "Install RVM and Ruby? [y|N] " ruby_response

if [[ $ruby_response =~ ^(y|yes|Y) ]]; then
  run "Setting up Ruby version manager (rvm)"
  set +e  # Temporarily disable exit on error for this section
  if check_ruby; then
    if [[ "$UPDATE_MODE" == "true" ]]; then
      safe_run "rvm get stable" "RVM update"
    fi

    # Install gems (gem_installer_start handles environment setup)
    run "Proceeding with gem installation"
    if ! gem_installer_start; then
      warn "Some gems failed to install, but continuing..."
    fi

    ok "Ruby setup completed"
  else
    warn "Ruby setup had issues, but continuing installation..."
  fi
  set -e  # Re-enable exit on error
else
  ok "Skipped Ruby installation"
fi

# Node.js Version Manager (Volta)
bot "Would you like to install Volta (Node.js Toolchain Manager)?"
bot "Volta allows you to easily install and manage Node.js, npm, and yarn versions."
read -r -p "Install Volta and Node.js? [y|N] " node_response

if [[ $node_response =~ ^(y|yes|Y) ]]; then
  run "Setting up Volta (Node.js toolchain manager)"
  set +e  # Temporarily disable exit on error for this section
  if check_node; then
    if ! node_installer_start; then
      warn "Some Node.js packages failed to install, but continuing..."
    fi
    ok "Volta setup completed"
  else
    warn "Volta setup had issues, but continuing installation..."
  fi
  set -e  # Re-enable exit on error
else
  ok "Skipped Volta installation"
fi

# Python Version Manager (pyenv)
bot "Would you like to install pyenv (Python Version Manager)?"
bot "pyenv allows you to easily install and manage multiple Python versions."
read -r -p "Install pyenv and Python packages? [y|N] " python_response

if [[ $python_response =~ ^(y|yes|Y) ]]; then
  run "Setting up Python version manager (pyenv)"
  set +e  # Temporarily disable exit on error for this section
  if check_python; then
    if [[ "$UPDATE_MODE" == "true" ]]; then
      safe_run "pip install --upgrade pip" "pip upgrade"
    fi
    if ! python_installer_start; then
      warn "Some Python packages failed to install, but continuing..."
    fi
    ok "Python setup completed"
  else
    warn "Python/pip setup had issues, but continuing installation..."
  fi
  set -e  # Re-enable exit on error
else
  ok "Skipped Python/pyenv installation"
fi

todo_complete "Install development version managers (Volta, Ruby, pyenv)"

# R configuration (macOS only)
if [[ "$IS_MACOS" == "true" ]]; then
  action "Setting up R and enabling rJava support"
  R CMD javareconf JAVA_CPPFLAGS=-I/System/Library/Frameworks/JavaVM.framework/Headers 2>/dev/null || true
  ok "R configuration completed"
fi

###############################################################################
# COMPLETION AND SUMMARY
###############################################################################

echo ""

if [[ "$UPDATE_MODE" == "true" ]]; then
  success "✅ Dotfiles update completed successfully!"
  bot "All configurations have been refreshed and packages updated."
else
  success "✅ Dotfiles installation completed successfully!"
  bot "Your development environment is now configured."
  bot "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
fi

# Show error summary
show_error_summary

bot "Usage:"
bot "  ./dotfiles.sh         - Fresh installation"
bot "  ./dotfiles.sh --update - Update existing configuration"
bot ""
bot "Enjoy your enhanced development environment! 🚀"

echo ""

if [[ "$UPDATE_MODE" == "true" ]]; then
  success "✅ Dotfiles update completed successfully!"
  bot "All configurations have been refreshed and packages updated."
else
  success "✅ Dotfiles installation completed successfully!"
  bot "Your development environment is now configured."
  bot "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
fi

# Show error summary
show_error_summary

bot "Usage:"
bot "  ./dotfiles.sh         - Fresh installation"
bot "  ./dotfiles.sh --update - Update existing configuration"
bot ""
bot "Enjoy your enhanced development environment\! 🚀"
