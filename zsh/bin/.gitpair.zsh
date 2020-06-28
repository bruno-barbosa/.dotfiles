function sp {
  git branch > /dev/null 2>&1 || return 1
  git config user.initials
}
