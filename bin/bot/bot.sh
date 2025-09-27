#!/usr/bin/env bash

######################################
# Human-readable output with emotes
# Inspired by Claude CLI design
######################################

# Colors
ESC_SEQ="\x1b["
COLOR_RESET=$ESC_SEQ"39;49;00m"
COLOR_RED=$ESC_SEQ"31;01m"
COLOR_GREEN=$ESC_SEQ"32;01m"
COLOR_YELLOW=$ESC_SEQ"33;01m"
COLOR_BLUE=$ESC_SEQ"34;01m"
COLOR_MAGENTA=$ESC_SEQ"35;01m"
COLOR_CYAN=$ESC_SEQ"36;01m"
COLOR_GRAY=$ESC_SEQ"90;01m"

# Simple completion indicator
function ok() {
    echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} $1"
}

# Main bot messages - clean and friendly
function bot() {
    echo -e "\n${COLOR_CYAN}●${COLOR_RESET} $1"
}

# Running indicator - minimal and clean
function run() {
    echo -e "  ${COLOR_GRAY}→${COLOR_RESET} $1"
}

# Action starting - clear and prominent
function action() {
    echo -e "\n${COLOR_BLUE}▶${COLOR_RESET} $1"
}

# Warning messages with appropriate emphasis
function warn() {
    echo -e "  ${COLOR_YELLOW}⚠${COLOR_RESET} $1"
}

# Error messages - clear but not overwhelming
function error() {
    echo -e "  ${COLOR_RED}✗${COLOR_RESET} $1"
}

# Success messages - celebratory
function success() {
    echo -e "\n${COLOR_GREEN}🎉${COLOR_RESET} $1\n"
}

# Todo-style progress tracking
function todo_start() {
    echo -e "  ${COLOR_GRAY}☐${COLOR_RESET} $1"
}

function todo_progress() {
    echo -e "  ${COLOR_BLUE}⚬${COLOR_RESET} $1"
}

function todo_complete() {
    echo -e "  ${COLOR_GREEN}☑${COLOR_RESET} $1"
}

function todo_skip() {
    echo -e "  ${COLOR_YELLOW}◦${COLOR_RESET} $1 (skipped)"
}

function todo_failed() {
    echo -e "  ${COLOR_RED}☒${COLOR_RESET} $1 (failed)"
}
