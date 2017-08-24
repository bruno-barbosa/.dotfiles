#!/usr/bin/env bash

######################################
# configures git
# @author Bruno Barbosa
######################################


function git.config() {
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

}
