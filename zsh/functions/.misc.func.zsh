# MISCELLANOUS AND GENERAL PURPOSE FUNCTIONS

# create a directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# copy contents of file to clipboard
function copy() {
	pbcopy < "$@"
}

# count total lines of code on current directory
function codecount() {
  cloc "$@" --exclude-dir=node_modules,bower_components,vendor
}

# kill specified port
function kill.port() {
  lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9
  echo "Port" $1 "found and killed."
}

# determine total size of file or directory an argument can be passed
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}

# given a port number kill it
function kill.port() {
  lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9
  echo "Port" $1 "found and killed."
}

# creates a targz file, an argument can also be passed
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # OS X `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";
	echo "${tmpFile}.gz created successfully.";
}

function extract () {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xvjf $1    ;;
      *.tar.gz)    tar xvzf $1    ;;
      *.tar.xz)    tar Jxvf $1    ;;
      *.bz2)       bunzip2 $1     ;;
      *.rar)       rar x $1       ;;
      *.gz)        gunzip $1      ;;
      *.tar)       tar xvf $1     ;;
      *.tbz2)      tar xvjf $1    ;;
      *.tgz)       tar xvzf $1    ;;
      *.zip)       unzip -d `echo $1 | sed 's/\(.*\)\.zip/\1/'` $1;;
      *.Z)         uncompress $1  ;;
      *.7z)        7z x $1        ;;
      *)           echo "don't know how to extract '$1'" ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

# simple calculator
function calc() {
	local result="";
	result="$(printf "scale=10;$*\n" | bc --mathlib | tr -d '\\\n')";
	#                       └─ default (when `--mathlib` is used) is 20
	#
	if [[ "$result" == *.* ]]; then
		# improve the output for decimal numbers
		printf "$result" |
		sed -e 's/^\./0./'        `# add "0" for cases like ".5"` \
		    -e 's/^-\./-0./'      `# add "0" for cases like "-.5"`\
		    -e 's/0*$//;s/\.$//';  # remove trailing zeros
	else
		printf "$result";
	fi;
	printf "\n";
}

function up() {
  times=$1
  while [ "$times" -gt "0" ]; do
    cd ..
    times=$(($times - 1))
  done
}

function count() {
  total=$1
  for ((i=total; i>0; i--)); do sleep 1; printf "Time remaining $i secs \r"; done
  echo -e "\a"
}


function update() {
	if [ $1 == 'zsh' ]; then
		(
			git clone https://github.com/bhilburn/powerlevel9k.git ~/.dotfiles/zsh/.oh-my-zsh/custom/themes/powerlevel9k
		);
	else
		(
			sudo softwareupdate -i -a
			brew update
			brew upgrade
			brew cleanup
			npm update -g
			sudo gem update --system
			sudo gem update
		)
	fi;
}

function weather() { 
	curl -s "wttr.in/$1?m1"
}