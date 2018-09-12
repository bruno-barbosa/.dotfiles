
#  Android SDK home
export ANDROID_HOME="~/Library/Android/sdk"

# Cask environments
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# NVM environments
export NVM_DIR="/Users/bruno/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Default priority path
export GOPATH=$HOME/.go:$HOME/Projects/Personal/go:$HOME/Projects/Yewno/go
export PATH=/usr/local/opt/python/libexec/bin:$HOME/Library/Python/2.7/bin:$HOME/Library/Python/3.7/bin:$PATH:$HOME/.go/bin:$HOME/Projects/Personal/go/bin:$HOME/Projects/Yewno/go/bin
