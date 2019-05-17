
#  Android SDK home
export ANDROID_HOME="~/Library/Android/sdk"

# Cask environments
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# NVM environments
export NVM_DIR="$HOME/.nvm"

# PYENV environments
export PYENV_ROOT=$HOME/.pyenv

# GO environments priority path
export GOPATH=$HOME/.go

# NVM
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Pyenv
eval "$(pyenv init -)"
