#!/usr/bin/env bash

######################################
# wip
# @author Bruno Barbosa
######################################

# include libraries
source ./bin/setup/.setup.zsh

bot "Hey there! I'm SimpliBot, \n I will be installing and tweaking your system settings. Let's start..."

# Request administrator rights
if sudo grep -q "# %wheel ALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then

  bot "I need you to enter your sudo password so I can install some things:"
  # Ask for the administrator password upfront
  sudo -v

  # Keep-alive: update existing sudo time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  bot "Do you want me to setup this machine to allow you to run sudo without a password?\nPlease read here to see what I am doing:\nhttp://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n"

  read -r -p "Make sudo passwordless? [y|N] " response

  if [[ $response =~ (yes|y|Y) ]];then
      sed --version 2>&1 > /dev/null
      sudo sed -i '' 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
      if [[ $? == 0 ]];then
          sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
      fi
      sudo dscl . append /Groups/wheel GroupMembership $(whoami)
      bot "You can now run sudo commands without password!"
  fi
fi

####
# Install brew and its dependencies
# add new brew && cask installations here
####
check.brew
brew.install zsh
brew.install git
brew.install gpg
brew.isntall gpg2
brew.install ruby
brew.isntall mongodb
brew.install shpotify
brew tap caskroom/cask
brew.install zsh-completions

run "Installing utilities apps"
brew.cask.install qlstephen
brew.cask.install betterzipql
brew.cask.install qlcolorcode
brew.cask.install qlprettypatch
brew.cask.install quicklook-csv
brew.cask.install quicklook-json

run "Installing core apps"
brew.cask.install spotify
brew.cask.isntall dashlane
brew.cask.isntall evernote
brew.cask.install google-chrome

run "Installing devloper apps"
brew.cask.install atom

run "Installing miscellaneous apps"

run "Cleaning up brew cask"
brew cleanup --force
rm -rf /Library/Caches/Homebrew/*


###
# Install fonts
###
run "installing powerline fonts"
./zsh/fonts/install.sh
ok

###
# Install rvm and its dependencies
###
check.rvm

###
# Install rvm and its dependencies
###
check.nvm

###
# Move .zscrc file to home directory
###
run "backing up old zshrc file and copying new configurations"
mv $HOME/.zshrc .zshrc.bkp
mv ./bin/configs/.zshrc $HOME

# Configure .gitconfig file
###
grep 'user = GITHUBUSER' ./bin/.gitconfig > /dev/null 2>&1
if [[ $? = 0 ]]; then
    read -r -p "What is your github.com username? " githubuser

  fullname=`osascript -e "long user name of (system info)"`

  if [[ -n "$fullname" ]];then
    lastname=$(echo $fullname | awk '{print $2}');
    firstname=$(echo $fullname | awk '{print $1}');
  fi

  if [[ -z $lastname ]]; then
    lastname=`dscl . -read /Users/$(whoami) | grep LastName | sed "s/LastName: //"`
  fi
  if [[ -z $firstname ]]; then
    firstname=`dscl . -read /Users/$(whoami) | grep FirstName | sed "s/FirstName: //"`
  fi
  email=`dscl . -read /Users/$(whoami)  | grep EMailAddress | sed "s/EMailAddress: //"`

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

  sed -i "s/GITHUBFULLNAME/$firstname $lastname/" ./bin/.gitconfig > /dev/null 2>&1 | true
  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    echo
    run "looks like you are using OSX sed rather than gnu-sed, accommodating"
    sed -i '' "s/GITHUBFULLNAME/$firstname $lastname/" ./bin/.gitconfig;
    sed -i '' 's/GITHUBEMAIL/'$email'/' ./bin/.gitconfig;
    sed -i '' 's/GITHUBUSER/'$githubuser'/' ./bin/.gitconfig;
  else
    echo
    bot "looks like you are already using gnu-sed. woot!"
    sed -i 's/GITHUBEMAIL/'$email'/' ./bin/.gitconfig;
    sed -i 's/GITHUBUSER/'$githubuser'/' ./bin/.gitconfig;
  fi
  run "copying gitconfig to home directory"
  mv ./bin/.gitconfig $HOME
fi
