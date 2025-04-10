#  Android SDK home
export ANDROID_HOME="~/Library/Android/sdk"

# Cask environments
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Node environments

# GO environments
export GOPATH=$HOME/.go

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

[[ -s "/home/bruno/.gvm/scripts/gvm" ]] && source "/home/bruno/.gvm/scripts/gvm"
