# MISCELLANEOUS AND GENERAL PURPOSE ALIASES

# kill chrome
alias chromekill='ps ux | grep "[C]hrome Helper --type=renderer" | grep -v extension-process | tr -s " " | cut -d " " -f2 | xargs kill'

# lock screen
alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# empty trash and remove .ds_store files
alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'
alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* "delete from LSQuarantineEvent"'

# update everything
alias update='sudo softwareupdate -i -a; brew update; brew upgrade --all; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update'

# reload resource
alias resource='source $ZSH_SOURCES/.sources.zsh'

# check local ip and public ip
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ifconfig | grep "inet" | grep -v 127.0.0.1'
