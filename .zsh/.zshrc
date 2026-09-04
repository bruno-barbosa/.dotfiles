# This file is zsh-only: setopt, autoload, zle, bindkey and oh-my-zsh itself
# have no bash equivalents, so sourcing it from bash spewed a page of
# "command not found" before dying on the first zsh-only conditional. Bail out
# with one line that says what to run instead. `return` covers a `source`d
# file; the `exit` fallback covers someone running this file directly.
if [ -z "${ZSH_VERSION:-}" ]; then
  echo "~/.zshrc is zsh-only and this shell is not zsh. Run 'exec zsh' instead." >&2
  return 1 2>/dev/null || exit 1
fi

export ZSH="$HOME/.oh-my-zsh"

source $HOME/.dotfiles/.zsh/.sources.zsh
source $HOME/.dotfiles/.zsh/.path.zsh

ZSH_THEME=""   # prompt comes from starship -- see .tools.zsh at the end of this file
ZSH_COLORIZE_TOOL="chroma"
ZSH_COLORIZE_STYLE="colorful"

# Uncomment the following line to use case-sensitive completion.
#CASE_SENSITIVE="false"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Command auto-correction is off: it prompts "did you mean ...?" on anything it
# does not recognise, which fires constantly on git subcommands and one-off
# binaries. Set to "true" to bring it back.
ENABLE_CORRECTION="false"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# Kept in step with the PSReadLine options in .pwsh/profile.ps1, so history
# behaves the same in both shells: same depth (MaximumHistoryCount 10000),
# no duplicates (-HistoryNoDuplicates), and writes that survive several
# terminals open at once.
setopt APPEND_HISTORY          # add to the file, never truncate it
setopt INC_APPEND_HISTORY      # write as commands run, not just at exit
setopt SHARE_HISTORY           # new shells pick up other sessions' commands
setopt HIST_IGNORE_ALL_DUPS    # a repeated command keeps only its newest entry
setopt HIST_IGNORE_SPACE       # leading space keeps a command out of history
setopt HIST_REDUCE_BLANKS      # tidy up whitespace before storing
setopt HIST_VERIFY             # expand !! onto the line instead of running it

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# Base plugins for all platforms
plugins=(
  aws
  bundler
  colorize
  common-aliases
  docker
  dotenv
  git
  git-extras
  git-flow
  golang
  npm
  python
  rake
  rbenv
  ruby
  ssh
  ssh-agent
  sudo
  terraform
  volta
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Platform-specific plugins
if [[ "$(uname -s)" == "Darwin" ]]; then
  plugins+=(macos)
elif [[ "$(uname -s)" == "Linux" ]]; then
  plugins+=(command-not-found)
  # Add archlinux plugin if on Arch
  if [ -f /etc/arch-release ]; then
    plugins+=(archlinux)
  fi
  # Add ubuntu plugin if on Ubuntu
  if [ -f /etc/lsb-release ] && grep -q "Ubuntu" /etc/lsb-release; then
    plugins+=(ubuntu)
  fi
fi

# User configuration

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"



# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# Better history
# Credits to https://coderwall.com/p/jpj_6q/zsh-better-history-searching-with-arrow-keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

source $ZSH/oh-my-zsh.sh

# Modern CLI tools + starship prompt.
# Sourced last, after oh-my-zsh, because oh-my-zsh sets its own prompt and
# would otherwise clobber starship.
source $HOME/.dotfiles/.zsh/.tools.zsh