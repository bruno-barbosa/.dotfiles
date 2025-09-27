#!/usr/bin/env bash

######################################
# Error handling and logging utilities
######################################

# Initialize error log file (will be set up after OS detection)
ERROR_LOG="${HOME}/.dotfiles/errors.log"

# Function to initialize error log (only called when first error occurs)
function init_error_log() {
  # Remove existing log if it exists to start fresh
  if [[ -f "$ERROR_LOG" ]]; then
    rm -f "$ERROR_LOG"
  fi

  # Ensure the directory exists
  local error_dir="$(dirname "$ERROR_LOG")"
  mkdir -p "$error_dir" 2>/dev/null || true

  # Initialize the error log
  echo "=== Dotfiles Installation Error Log ===" > "$ERROR_LOG"
  echo "Date: $(date)" >> "$ERROR_LOG"
  echo "OS: ${OS:-Unknown}" >> "$ERROR_LOG"
  echo "Mode: $([ "${UPDATE_MODE:-false}" == "true" ] && echo "UPDATE" || echo "INSTALL")" >> "$ERROR_LOG"
  echo "=======================================" >> "$ERROR_LOG"
  echo "" >> "$ERROR_LOG"

  # Verify the log file was created
  if [[ ! -f "$ERROR_LOG" ]]; then
    echo "WARNING: Failed to create error log at $ERROR_LOG" >&2
    return 1
  fi
}

# Function to log errors to file
function log_error() {
  local description="$1"
  local error_output="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  # Initialize log if it doesn't exist
  if [[ ! -f "$ERROR_LOG" ]]; then
    init_error_log
  fi

  # Log the error
  {
    echo "[$timestamp] ERROR: $description"
    if [[ -n "$error_output" ]]; then
      echo "Output:"
      echo "$error_output"
    fi
    echo "---"
    echo ""
  } >> "$ERROR_LOG"

}

# Function to safely run commands that might fail but shouldn't stop the script
function safe_run() {
  local cmd="$1"
  local description="$2"
  local error_output

  # Capture both stdout and stderr
  if error_output=$(eval "$cmd" 2>&1); then
    return 0
  else
    warn "$description failed, but continuing installation..."
    log_error "$description" "$error_output"
    return 1
  fi
}

# Function to get error count from log file
function get_error_count() {
  local count
  if [[ -f "$ERROR_LOG" ]]; then
    count=$(grep -c "ERROR:" "$ERROR_LOG" 2>/dev/null || echo "0")
  else
    count="0"
  fi
  echo "$count"
}

# Function to clean up error log if no errors occurred
function cleanup_error_log() {
  local error_count
  error_count=$(get_error_count | tr -d '\n\r ' | head -n1)

  if [[ "${error_count:-0}" -eq 0 ]] 2>/dev/null; then
    rm -f "$ERROR_LOG" 2>/dev/null || true
    return 0
  else
    return 1
  fi
}

# Function to display error summary
function show_error_summary() {
  # Check if error log exists - if not, no errors occurred
  if [[ ! -f "$ERROR_LOG" ]]; then
    ok "No errors occurred during installation."
    return 0
  fi

  local error_count
  error_count=$(get_error_count | tr -d '\n\r ' | head -n1)

  if [[ "${error_count:-0}" -gt 0 ]] 2>/dev/null; then
    warn "⚠️  $error_count errors occurred during installation."
    bot "Check $ERROR_LOG for detailed error information."
    return 1
  else
    ok "No errors occurred during installation."
    cleanup_error_log
    return 0
  fi
}