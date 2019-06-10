export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

# Only shows rvm version on directories with ruby files
prompt_rvmShowVersion() {
  for file in $PWD/*.rb
  do
    if [[ -f ${file} ]]; then
      local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
      [ "$gemset" != "" ] && gemset="@$gemset"

      local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')

      if [[ -n "$version$gemset" ]]; then
        "$1_prompt_segment" "$0" "$2" "black" "249" "$version$gemset" 'RUBY_ICON'
      fi
    break
    fi
  done > /dev/null 2>&1
}
