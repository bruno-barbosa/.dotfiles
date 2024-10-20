#  Android SDK home
export ANDROID_HOME="~/Library/Android/sdk"

# Cask environments
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# NVM environments
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# GO environments
export GOPATH=$HOME/.go

# Python Environments
export PYENV_ROOT=$HOME/.pyenv
export GVM_ROOT=$HOME/.gvm

eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -s "/home/bruno/.gvm/scripts/gvm" ]] && source "/home/bruno/.gvm/scripts/gvm"
