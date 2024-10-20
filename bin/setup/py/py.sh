#!/usr/bin/env bash

######################################
# installs py and its dependencies
# @author Bruno Barbosa
######################################

function check.py() {
  pip_bin=$(pip3 --version) 2>&1 >/dev/null
  if [ $? != 0 ]; then
    action "installing pip"
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    rm -rf get-pip.py
    rm -rf /usr/local/bin/pip # override python2 pip with python3's version
    ln -s $(which pip3) /usr/local/bin/pip
  fi

  run "upgrade global pip to latest"
  pip3 install --upgrade pip
}

# gem installer helper function
function py.install() {
  action "py install $1 $2"
  pip install $1 $2
  if [[ $? != 0 ]]; then
    error "failed to install $1! aborting... \n"
  fi
}

function py.installer.start() {
  if [[ -s ./bin/setup/py/py_defaults.txt ]]; then
    run "Installing py defaults"
    while read ARG; do
      py.install "$ARG"
    done <./bin/setup/py/py_defaults.txt
  else
    warn "no py defaults found skipping... \n"
  fi
}
