#!/usr/bin/env bash
export BIN_PATH=$HOME/.dotfiles/bin

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