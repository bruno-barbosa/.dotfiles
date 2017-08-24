#!/usr/bin/env bash

######################################
# installs nvm and its dependencies
# @author Bruno Barbosa
######################################

function check.nvm() {
  run "checking nvm installation"
  rvm_bin=$(nvm --version) 2>&1 > /dev/null
  if [[ $? != 0 ]]; then
    action "installing nvm"
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.4/install.sh | bash
      if [[ $? != 0 ]]; then
        error "unable to install nvm, script $0 abort!"
        exit 2
      else
        nvm install --lts
        ok
      fi
    fi
}
