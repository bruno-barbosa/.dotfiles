#!/usr/bin/env bash

######################################
# installs brew and its dependencies
# @author Bruno Barbosa
######################################

# verifies brew installation
function check.brew() {
  run "checking homebrew installation"
  brew_bin=$(which brew) 2>&1 >/dev/null
  if [[ $? != 0 ]]; then
    action "installing homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    if [[ $? != 0 ]]; then
      error "unable to install homebrew, script $0 abort!"
      exit 2
    fi
  else
    ok
    run "updating homebrew"
    brew update
    ok
    bot "before installing brew packages, can I upgrade outdated packages?"
    read -r -p "run brew upgrade? [y|N]" response
    if [[ $response =~ ^(y|yes|Y) ]]; then
      action "upgrading brew packages..."
      brew upgrade
    else
      ok "skipped brew packages upgrade."
    fi
  fi
}

# brew installer helper function
function brew.install() {
  run "brew $1 $2"
  brew list $1 >/dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    action "brew install $1 $2"
    brew install $1 $2
    if [[ $? != 0 ]]; then
      error "failed to install $1! aborting..."
    fi
  fi
  ok
}

# brew cask installer helper function
function brew.cask.install() {
  run "brew cask $1 $2"
  brew cask list $1 >/dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    action "brew install $1 $2"
    brew cask install $1 $2
    if [[ $? != 0 ]]; then
      error "failed to install $1! aborting..."
    fi
  fi
  ok
}

# Add brew and brew cask installations here
# TODO: implement function to install from a json file
function brew.installer.start() {
  brew tap caskroom/cask

  run "Installing brew defaults"
  while read ARG; do
    brew.install "$ARG"
  done <./bin/setup/brew/brew_defaults.txt

  run "tapping new homebrew repositories"
  brew tap homebrew/science
  brew tap homebrew/cask-fonts

  run "Installing cask defaults"
  while read ARG; do
    brew.cask.install "$ARG"
  done <./bin/setup/brew/cask_defaults.txt

}
