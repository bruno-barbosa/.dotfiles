#!/usr/bin/env zsh

###########################################
# Enhanced Git Aliases
###########################################

# Repository initialization
alias gnt='git init'
alias gcl='git clone'

# Basic Git Aliases
alias g='git'
alias gs='git status -sb'  # Short status with branch info
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'  # Interactive staging

# Commit aliases
alias gc='git commit -v'  # Verbose commit (shows diff)
alias gcm='git commit -m'
alias gca='git commit -v --amend'
alias gcan='git commit -v --amend --no-edit'
alias gcf='git commit --fixup'

# Branch management
alias gb='git branch'
alias gba='git branch -a'  # All branches (local + remote)
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout $(git_main_branch)'  # Checkout main/master
alias gcod='git checkout develop'

# Branch history - enhanced
alias gbh="git for-each-ref --sort=-committerdate refs/heads --format='%(HEAD)%(color:yellow)%(refname:short)|%(color:bold green)%(committerdate:relative)|%(color:blue)%(subject)|%(color:magenta)%(authorname)%(color:reset)'|column -ts'|'"

# Fetch, Pull, Push
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias gpr='git pull --rebase'
alias gp='git push'
alias gpf='git push --force-with-lease'  # Safer force push
alias gpsup='git push --set-upstream origin $(git_current_branch)'

# Rebase
alias grb='git rebase'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias grbm='git rebase $(git_main_branch)'

# Merge
alias gm='git merge'
alias gma='git merge --abort'
alias gmom='git merge origin/$(git_main_branch)'

# Stash
alias gsta='git stash'
alias gstaa='git stash apply'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gstd='git stash drop'
alias gstc='git stash clear'

# Diff
alias gd='git diff'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff'

# Log aliases with beautiful formatting
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glt='git log --graph --oneline --all'  # Existing alias
alias glogp='git log --pretty=format:"%C(yellow)%h%Creset %C(blue)%ad%Creset %C(green)%an%Creset %s" --date=short'
alias glogs='git log --stat'
alias glogf='git log --follow -p --'  # Follow file history

# Show
alias gsh='git show'
alias gshs='git show --stat'

# Tags
alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'

# Remote
alias gr='git remote'
alias grv='git remote -v'
alias gra='git remote add'
alias grrm='git remote remove'

# Reset
alias grh='git reset'
alias grhh='git reset --hard'
alias grhs='git reset --soft'

# Clean
alias gclean='git clean -fd'
alias gcleanx='git clean -fdx'  # Include ignored files

# Worktree
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'

# Better git blame with ignore whitespace
alias gbl='git blame -w'

# Show contributors
alias gcontrib='git shortlog -sn'

# Show files changed in last commit
alias git-last-files='git show --name-only --pretty=format:'

# Update all submodules
alias gsub='git submodule update --init --recursive'

# Show all git aliases
alias git-aliases='alias | grep "^g"'

# Conventional commit shortcuts (use git-conv subcommand)
alias gconv='git conv'
alias gfeat='git conv feat'
alias gfix='git conv fix'
alias gdocs='git conv docs'
alias gstyle='git conv style'
alias grefactor='git conv refactor'
alias gtest='git conv test'
alias gchore='git conv chore'
alias gperf='git conv perf'

# Other git subcommands shortcuts
alias gcb='git cb'  # Create branch
