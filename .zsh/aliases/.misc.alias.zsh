# MISCELLANEOUS AND GENERAL PURPOSE ALIASES

# kill chrome (cross-platform)
if [[ "$IS_MACOS" == "true" ]]; then
  alias chromekill='ps ux | grep "[C]hrome Helper --type=renderer" | grep -v extension-process | tr -s " " | cut -d " " -f2 | xargs kill'
else
  alias chromekill='pkill -f "chrome.*renderer"'
fi

# lock screen (platform-specific)
if [[ "$IS_MACOS" == "true" ]]; then
  alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
elif [[ "$IS_LINUX" == "true" ]]; then
  alias_if_exists afk 'gnome-screensaver-command -l'
  alias_if_exists afk 'xdg-screensaver lock'
  alias_if_exists afk 'loginctl lock-session'
fi

# cleanup files (platform-aware)
if [[ "$IS_MACOS" == "true" ]]; then
  alias cleanup='find . -type f -name "*.DS_Store" -ls -delete'
  alias emptytrash='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* "delete from LSQuarantineEvent"'
else
  alias cleanup='find . -type f -name "*~" -delete; find . -type f -name ".*.swp" -delete'
  alias emptytrash='rm -rf ~/.local/share/Trash/* 2>/dev/null || true'
fi

# reload resource
alias resource='source ~/.dotfiles/.zsh/.sources.zsh'

# check local ip and public ip
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'

# local ip (platform-aware)
if [[ "$IS_MACOS" == "true" ]]; then
  alias localip='ifconfig | grep "inet" | grep -v 127.0.0.1'
else
  alias localip='ip addr show | grep "inet " | grep -v 127.0.0.1'
fi

# package manager aliases (platform-specific)
if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
  alias install='brew install'
  alias search='brew search'
  alias update='brew update && brew upgrade'
elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
  alias install='sudo apt install'
  alias search='apt search'
  alias update='sudo apt update && sudo apt upgrade'
elif [[ "$PACKAGE_MANAGER" == "yum" ]]; then
  alias install='sudo yum install'
  alias search='yum search'
  alias update='sudo yum update'
elif [[ "$PACKAGE_MANAGER" == "pacman" ]]; then
  alias install='sudo pacman -S'
  alias search='pacman -Ss'
  alias update='sudo pacman -Syu'
fi