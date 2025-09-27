#!/usr/bin/env bash

######################################
# Configures git
######################################


function git_config() {
  # Check if git configuration needs to be set up
  local needs_config=false

  # Check for placeholder values
  if grep -q 'user = GITHUBUSER\|GITHUBEMAIL\|GITHUBFULLNAME' ./.config/.gitconfig 2>/dev/null; then
    needs_config=true
  # Check if git config exists but ask user if they want to reconfigure
  elif [[ -f ./.config/.gitconfig ]] && git config --file ./.config/.gitconfig user.name >/dev/null 2>&1; then
    local current_name=$(git config --file ./.config/.gitconfig user.name 2>/dev/null)
    local current_email=$(git config --file ./.config/.gitconfig user.email 2>/dev/null)

    if [[ -n "$current_name" && -n "$current_email" ]]; then
      bot "Git is already configured with:"
      bot "  Name: $current_name"
      bot "  Email: $current_email"
      read -r -p "Would you like to reconfigure git settings? [y|N] " reconfigure
      if [[ $reconfigure =~ ^(y|yes|Y) ]]; then
        needs_config=true
      else
        ok "Using existing git configuration"
      fi
    else
      needs_config=true
    fi
  else
    needs_config=true
  fi

  if [[ "$needs_config" == "true" ]]; then
      read -r -p "What is your github.com username? " githubuser

    # Try to get full name from system (cross-platform)
    if [[ "$IS_MACOS" == "true" ]]; then
      fullname=`osascript -e "long user name of (system info)" 2>/dev/null`
      if [[ -n "$fullname" ]];then
        lastname=$(echo $fullname | awk '{print $2}');
        firstname=$(echo $fullname | awk '{print $1}');
      fi

      if [[ -z $lastname ]]; then
        lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //" 2>/dev/null`
      fi
      if [[ -z $firstname ]]; then
        firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //" 2>/dev/null`
      fi
      email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //" 2>/dev/null`
    else
      # Linux - try to get from passwd/finger or environment
      fullname=$(getent passwd $(whoami) | cut -d: -f5 | cut -d, -f1 2>/dev/null)
      if [[ -n "$fullname" ]]; then
        firstname=$(echo $fullname | awk '{print $1}')
        lastname=$(echo $fullname | awk '{$1=""; print $0}' | xargs)
      fi
    fi

    if [[ ! "$firstname" ]];then
      response='n'
    else
      echo -e "I see that your full name is $COL_YELLOW$firstname $lastname$COL_RESET"
      read -r -p "Is this correct? [Y|n] " response
    fi

    if [[ $response =~ ^(no|n|N) ]];then
      read -r -p "What is your first name? " firstname
      read -r -p "What is your last name? " lastname
    fi
    fullname="$firstname $lastname"

    bot "Great $fullname, "

    if [[ ! $email ]];then
      response='n'
    else
      echo -e "The best I can make out, your email address is $COL_YELLOW$email$COL_RESET"
      read -r -p "Is this correct? [Y|n] " response
    fi

    if [[ $response =~ ^(no|n|N) ]];then
      read -r -p "What is your email? " email
      if [[ ! $email ]];then
        error "you must provide an email to configure .gitconfig"
        exit 1
      fi
    fi


    run "replacing items in .gitconfig with your info ($COL_YELLOW$fullname, $email, $githubuser$COL_RESET)"

    # test if gnu-sed or osx sed

    sed -i "s/GITHUBFULLNAME/$firstname $lastname/" ./.config/.gitconfig > /dev/null 2>&1
    local sed_status=$?
    if [[ $sed_status != 0 ]]; then
      echo
      run "looks like you are using OSX sed rather than gnu-sed, accommodating"
      sed -i '' "s/GITHUBFULLNAME/$firstname $lastname/" ./.config/.gitconfig;
      sed -i '' 's/GITHUBEMAIL/'$email'/' ./.config/.gitconfig;
      sed -i '' 's/GITHUBUSER/'$githubuser'/' ./.config/.gitconfig;
    else
      echo
      bot "looks like you are already using gnu-sed. woot!"
      sed -i 's/GITHUBEMAIL/'$email'/' ./.config/.gitconfig;
      sed -i 's/GITHUBUSER/'$githubuser'/' ./.config/.gitconfig;
    fi
    run "linking gitconfig to home directory"
    # Remove existing .gitconfig if it exists
    if [ -L "$HOME/.gitconfig" ]; then
      rm "$HOME/.gitconfig"
    elif [ -f "$HOME/.gitconfig" ]; then
      mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup"
      echo "Existing .gitconfig backed up to .gitconfig.backup"
    fi
    ln -s ~/.dotfiles/.config/.gitconfig "$HOME/.gitconfig"
    ok "Global gitconfig linked to ~/.gitconfig"
  fi

  # Always ensure .gitconfig is linked to home directory (even if not reconfiguring)
  run "ensuring gitconfig is linked to home directory"
  if [ ! -L "$HOME/.gitconfig" ] || [ "$(readlink "$HOME/.gitconfig")" != "$HOME/.dotfiles/.config/.gitconfig" ]; then
    if [ -L "$HOME/.gitconfig" ]; then
      rm "$HOME/.gitconfig"
    elif [ -f "$HOME/.gitconfig" ]; then
      mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$(date +%s)"
      run "Existing .gitconfig backed up"
    fi
    ln -s ~/.dotfiles/.config/.gitconfig "$HOME/.gitconfig"
    ok "gitconfig linked to home directory"
  else
    ok "gitconfig already properly linked"
  fi
}
