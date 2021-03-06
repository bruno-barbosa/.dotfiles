export ZSH_PATH=$HOME/.dotfiles/zsh

# ZSH Sources

source $ZSH_PATH/antigen/antigen.zsh
antigen init $ZSH_PATH/.antigenrc
 
source $ZSH_PATH/.env.zsh
source $ZSH_PATH/bin/.font.zsh
source $ZSH_PATH/bin/.tmuxinator.zsh
source $ZSH_PATH/bin/.gitpair.zsh
source $ZSH_PATH/aliases/.aliases.zsh
source $ZSH_PATH/functions/.functions.zsh