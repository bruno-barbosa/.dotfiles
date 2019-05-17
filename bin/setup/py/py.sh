#!/usr/bin/env bash

######################################
# installs py and its dependencies
# @author Bruno Barbosa
######################################

function check.py() {
  brew link --overwrite python
  
  pip_bin=$(pip --version) 2>&1 > /dev/null
  if [ $? != 0 ]; then
    action "installing pip"
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    rm -rf get-pip.py
  fi

  run "upgrade global pip to latest"
  pip install --upgrade pip
}

# gem installer helper function
function py.install() {
   action "py install $1 $2"
   pip install $1 $2
    if [[ $? != 0 ]]; then
        error "failed to install $1! aborting..."
    fi
ok
}

function py.installer.start() {
    run "Installing py defaults"
    while read ARG
        do
            py.install "$ARG"
        done < ./bin/setup/py/py_defaults.txt
}
