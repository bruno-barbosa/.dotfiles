# NVM FUNCTIONS

# Upgrade nvm to latest version
function nvm.upgrade() {
	(
	  cd "$NVM_DIR"
	  git fetch origin
	  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" origin`
	) && . "$NVM_DIR/nvm.sh"
}

function nvm.latest() {
	(
		current=$(nvm version)
		nvm install node --resinstall-packages-from="${current:1:${#current}-1}"
		nvm alias default node
	)
}

function nvm.lts() {
	(
	current=$(nvm version)
	nvm install --lts --resinstall-packages-from="${current:1:${#current}-1}"
	nvm alias lts lts
	)
}
