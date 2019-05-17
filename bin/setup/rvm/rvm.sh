#!/usr/bin/env bash

######################################
# installs rvm and its dependencies
# @author Bruno Barbosa
######################################

function check.rvm() {
  run "checking rvm installation"
  rvm_bin=$(rvm --version) 2>&1 > /dev/null
  if [[ $? != 0 ]]; then
    action "installing rvm"
      gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
      \curl -sSL https://get.rvm.io | bash -s stable --ruby
      ok
      if [[ $? != 0 ]]; then
        error "unable to install rvm, script $0 abort!"
        exit 2
      fi
    fi
}

# gem installer helper function
function gem.install() {
   action "gem install $1 $2"
   gem install $1 $2
    if [[ $? != 0 ]]; then
        error "failed to install $1! aborting..."
    fi
ok
}

function gem.installer.start() {
    run "Installing gem defaults"
    while read ARG
        do
            gem.install "$ARG"
        done < ./bin/setup/rvm/gem_defaults.txt
}
