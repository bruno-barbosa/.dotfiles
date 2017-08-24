export ZSH_PATH=$HOME/.dotfiles/zsh

source $ZSH_PATH/antigen/antigen.zsh
antigen init $ZSH_PATH/.antigenrc

source $ZSH_PATH/oh-my-zsh/oh-my-zsh.sh

source $ZSH_PATH/.env.zsh
source $ZSH_PATH/bin/.font.zsh
source $ZSH_PATH/bin/.rvm.zsh
source $ZSH_PATH/bin/.nvm.zsh
source $ZSH_PATH/bin/.spotify.zsh
source $ZSH_PATH/aliases/.aliases.zsh
source $ZSH_PATH/functions/.functions.zsh
