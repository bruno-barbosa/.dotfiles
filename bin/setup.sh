#!/usr/bin/env bash

# Repo root, derived from this file's own location rather than assumed to be
# ~/.dotfiles, so the checkout can live anywhere. dotfiles.sh exports the same
# value before sourcing us; honour it when set.
if [[ -z "${DOTFILES_ROOT:-}" ]]; then
  DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
export DOTFILES_ROOT
export BIN_PATH="${DOTFILES_ROOT}/bin"

# Common utilities
source ${BIN_PATH}/bot/bot.sh
source ${BIN_PATH}/bot/error.sh
source ${BIN_PATH}/bot/config.sh
source ${BIN_PATH}/bot/utils.sh
source ${BIN_PATH}/git/git.sh
source ${BIN_PATH}/ruby/ruby.sh
source ${BIN_PATH}/python/python.sh
source ${BIN_PATH}/node/node.sh

# Platform-specific setup
if [[ "$(uname -s)" == "Darwin" ]]; then
  source ${BIN_PATH}/platform/osx.sh
elif [[ "$(uname -s)" == "Linux" ]]; then
  source ${BIN_PATH}/platform/unix.sh
fi
