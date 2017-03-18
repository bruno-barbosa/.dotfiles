#!/usr/bin/env bash

######################################
# installs brew and its dependencies
# @author Bruno Barbosa
######################################

# verifies brew installation
function check.brew() {
  run "checking homebrew installation"
  brew_bin=$(which brew) 2>&1 > /dev/null
  if [[ $? != 0 ]]; then
    action "installing homebrew"
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
  brew list $1 > /dev/null 2>&1 | true
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
  brew cask list $1 > /dev/null 2>&1 | true
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

  run "installing caskroom casks"
  brew.install caskroom/cask/xquartz
  brew.install caskroom/cask/rstudio

  run "tapping new homebrew repositories"
  brew tap homebrew/science
  brew tap caskroom/fonts

  run "installing essential utilities"
  brew.install git
  brew.install yarn
  brew.install gpg
  brew.install gpg2
  brew.install libsvg
  brew.install curl
  brew.install libxml2
  brew.install gdal
  brew.install geos
  brew.install boost

  run "installing languages"
  brew.install R
  brew.install ruby
  brew.install python3
  brew.cask.install java

  run "installing databases"
  brew.install mongodb

  run "installing zsh"
  brew.install shpotify
  brew.install zsh
  brew.install zsh-completions


  run "installing utilities apps"
  brew.cask.install qlstephen
  brew.cask.install betterzipql
  brew.cask.install qlcolorcode
  brew.cask.install qlprettypatch
  brew.cask.install quicklook-csv
  brew.cask.install quicklook-json
  brew.cask.install font-fira-code

  run "installing core apps"
  brew.cask.install spotify
  brew.cask.isntall dashlane
  brew.cask.isntall evernote
  brew.cask.install google-chrome

  run "installing devloper apps"
  brew.cask.install atom
  brew.cask.install mactex
}
