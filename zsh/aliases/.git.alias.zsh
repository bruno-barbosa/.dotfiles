# GIT ALIASES

# general git aliases
alias git commit='git cz'
alias gnt='git init'
alias gcl='git clone'
alias glt='git log --graph --oneline --all'
alias gbh= "git for-each-ref --sort=-committerdate refs/heads --format='%(HEAD)%(color:yellow)%(refname:short)|%(color:bold green)%(committerdate:relative)|%(color:blue)%(subject)|%(color:magenta)%(authorname)%(color:reset)'|column -ts'|'"
