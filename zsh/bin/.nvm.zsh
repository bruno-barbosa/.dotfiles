# Set NVM_DIR if it isn't already defined
[[ -z "$NVM_DIR" ]] && export NVM_DIR="$HOME/.nvm"

# Load nvm if it exists
[[ -f "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# Only shows nvm version on directories with nodejs files
prompt_nvmShowVersion() {
  if [[ -f $PWD/package.json ]]; then
    local node_version=$(node -v 2>/dev/null)
    [[ -z "${node_version}" ]]  && return

    "$1_prompt_segment" "$0" "$2" "green" "white" "${node_version:1}" 'NODE_ICON'
  fi
}
