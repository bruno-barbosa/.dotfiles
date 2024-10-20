#!/usr/bin/env bash

######################################
# wip
# @author Bruno Barbosa
######################################

# include libraries
source ./bin/setup/setup.sh

bot "Hey there! I'm Eros, \n I will be installing and tweaking your system settings. Let's start..."

# Request administrator rights
if sudo grep -q "# %wheel ALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then

  bot "I need you to enter your sudo password so I can install some things:"
  # Ask for the administrator password upfront
  sudo -v

  # Keep-alive: update existing sudo time stamp until the script has finished
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &

  bot "Do you want me to setup this machine to allow you to run sudo without a password?\nPlease read here to see what I am doing:\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

  read -r -p "Make sudo passwordless? [y|N] " response

  if [[ $response =~ (yes|y|Y) ]]; then
    sed --version 2>&1 >/dev/null
    sudo sed -i '' 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
    if [[ $? == 0 ]]; then
      sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
    fi
    sudo dscl . append /Groups/wheel GroupMembership $(whoami)
    bot "You can now run sudo commands without password!"
  fi
fi

####
# Install brew and its dependencies
# add new brew && cask installations here
####
run "checking brew installation & installing brew cask"
check.brew
brew.installer.start
ok

run "cleaning up brew & cask"
brew cleanup --force
rm -rf /Library/Caches/Homebrew/*
ok

run "installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
ok

####
# Move .zscrc file to home directory
####
run "backing up old zshrc file and copying new configurations"
mv $HOME/.zshrc $HOME/.zshrc.bkp
ln -s ~/.dotfiles/zsh/.zshrc $HOME

run "backing up old tmux.conf file and copying new configurations"
mv $HOME/.tmux.conf $HOME/.tmux.conf.bkp
ln -s ~/.dotfiles/tmux/.tmux.conf $HOME
ok

####
# Install rvm and its dependencies
####
check.rvm
gem.installer.start
ok

####
# Install nvm and its dependencies
####
check.nvm
ok

####
# Install pyenv and its dependencies
####
check.py
py.installer.start
ok

####
# Setting up R and enabling rJava support
####
run "setting up R and enabling rJava support"
R CMD javareconf JAVA_CPPFLAGS=-I/System/Library/Frameworks/JavaVM.framework/Headers
ok

####
# Configure .gitconfig file
####
run "initiating git.config configuration"
git.config
ok
