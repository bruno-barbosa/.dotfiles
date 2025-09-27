# MISCELLANEOUS AND GENERAL PURPOSE FUNCTIONS
# Cross-platform compatibility for macOS and Linux

# create a directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# copy contents of file to clipboard (cross-platform)
function copy() {
	if [[ "$IS_MACOS" == "true" ]]; then
		pbcopy < "$@"
	elif command -v xclip >/dev/null 2>&1; then
		xclip -selection clipboard < "$@"
	elif command -v xsel >/dev/null 2>&1; then
		xsel --clipboard --input < "$@"
	else
		echo "No clipboard utility found. Install xclip or xsel on Linux."
		return 1
	fi
}

# count total lines of code on current directory
function codecount() {
  if command -v cloc >/dev/null 2>&1; then
    cloc "$@" --exclude-dir=node_modules,bower_components,vendor
  else
    echo "cloc not found. Install it with:"
    if [[ "$IS_MACOS" == "true" ]]; then
      echo "  brew install cloc"
    else
      echo "  sudo apt install cloc  # Ubuntu/Debian"
      echo "  sudo yum install cloc  # RHEL/CentOS"
    fi
    return 1
  fi
}

# kill specified port (cross-platform)
function kill.port() {
  if ! command -v lsof >/dev/null 2>&1; then
    echo "lsof not found. Install it with:"
    if [[ "$IS_MACOS" == "true" ]]; then
      echo "  brew install lsof"
    else
      echo "  sudo apt install lsof  # Ubuntu/Debian"
    fi
    return 1
  fi

  local port=$1
  local pid=$(lsof -i TCP:$port | grep LISTEN | awk '{print $2}')

  if [[ -n "$pid" ]]; then
    kill -9 $pid
    echo "Port $port (PID: $pid) found and killed."
  else
    echo "No process found listening on port $port."
  fi
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


# creates a targz file, an argument can also be passed
function targz() {
	local tmpFile="${@%/}.tar";
	# Platform-aware exclusions
	local excludes="--exclude=.DS_Store --exclude=Thumbs.db --exclude=.git"
	tar -cvf "${tmpFile}" $excludes "${@}" || return 1;

	# Cross-platform file size detection
	if [[ "$IS_MACOS" == "true" ]]; then
		size=$(stat -f"%z" "${tmpFile}" 2>/dev/null)
	else
		size=$(stat -c"%s" "${tmpFile}" 2>/dev/null)
	fi

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
	if ! command -v bc >/dev/null 2>&1; then
		echo "bc not found. Install it with:"
		if [[ "$IS_MACOS" == "true" ]]; then
			echo "  brew install bc"
		else
			echo "  sudo apt install bc  # Ubuntu/Debian"
			echo "  sudo yum install bc  # RHEL/CentOS"
		fi
		return 1
	fi

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

function weather() { 
	curl -s "wttr.in/$1?m1"
}