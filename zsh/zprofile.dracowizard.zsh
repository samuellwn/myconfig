# @!os:unix
# @!user:dracowizard
# @!install:644:$HOME/.zprofile
# @!install:644:$HOME/.zshrc
# @!install:644:$HOME/.bash_profile
# @!install:644:$HOME/.bashrc
# @!install:644:$HOME/.profile

if [[ -z $ZSH_VERSION ]]; then
	if [[ -z $BASH_VERSION ]]; then
		printf "%s\n" "This script is only supported in bash 3.2.57+ "\
			"or zsh 5.9+." >&2
		exit 1
	else
		_my_zprofile_shell=bash
	fi
else
	_my_zprofile_shell=zsh
fi
if [[ $(uname) != Darwin ]]; then
	if [[ $(uname) != Linux ]]; then
		printf "%s\n" "This script is only supported on macOS 15.6+ or Linux." >&2
		exit 1
	else
		_my_zprofile_os=Linux
	fi
else
	_my_zprofile_os=Darwin
	if [[ $(uname -m) != x86_64 ]]; then
		if [[ $(uname -m) != arm64 ]]; then
			printf "This script is only supported on macOS with 64-bit ARM "\
				"or 64-bit x86, not %s." $(uname -m) >&2
			exit 1
		else
			_my_zprofile_cpu=aarch64
		fi
	else
		_my_zprofile_cpu=amd64
	fi
fi



# macOS system path defaults
if [[ -z $__loaded__darwin_path_helper ]]; then
	__loaded__darwin_path_helper=yes
	if [[ -x /usr/libexec/path_helper ]]; then
		eval $(/usr/libexec/path_helper -s)
	fi
fi

# Boot Homebrew
if [[ $_my_zprofile_os == Darwin ]]; then
	if [[ $_my_zprofile_cpu == aarch64 ]]; then _my_zprofile_brewpath=/opt/homebrew
	elif [[ $_my_zprofile_cpu == amd64 ]]; then _my_zprofile_brewpath=/usr/local; fi; fi
if [[ -d $_my_zprofile_brewpath ]]; then
	if [[ -z $__loaded__homebrew_shellenv ]]; then
		__loaded__homebrew_shellenv=yes
		eval "$($_my_zprofile_brewpath/bin/brew shellenv)"
	fi

	if [[ -z $__loaded__homebrew_postgresql ]]; then
		__loaded__homebrew_postgresql=yes
		if [[ -d $_my_zprofile_brewpath/opt/postgresql@17 ]]; then
			export PATH=$_my_zprofile_brewpath/opt/postgresql@17/bin:$PATH
			export LDFLAGS="-L$_my_zprofile_brewpath/opt/postgresql@17/lib $LDFLAGS"
			export CPPFLAGS="-I$_my_zprofile_brewpath/opt/postgresql@17/include $CPPFLAGS"
		fi
	fi
fi

# zsh-specific completion stuff
if [[ $_my_zprofile_shell == zsh ]]; then
	if [[ -z $__loaded__zsh_completion ]];then
		__loaded__zsh_completion=yes
		fpath+=~/.zfunc; autoload -Uz compinit; compinit -u
	fi

	zstyle ':completion:*' menu select
	zstyle ':completion:*' rehash true

	# Speed up completions
	zstyle ':completion:*' accept-exact '*(N)'
	zstyle ':completion:*' use-cache on
	zstyle ':completion:*' cache-path ~/.zsh/cache
fi

reset_env_variable() {
	if [[ $_my_zprofile_shell == bash ]]; then
		if [[ -z "${!1}" ]]; then
			printf -v "${1}" "%s" "${!2}"
			export "${1}"
		else
			printf -v "${2}" "%s" "${!1}"
			export "${2}"
		fi
	else
		if [[ -z "${(P)1}" ]]; then
			printf -v "${1}" "%s" "${(P)2}"
			export "${1}"
		else
			printf -v "${2}" "%s" "${(P)1}"
			export "${2}"
		fi
	fi
}


# reset all the list env variables
reset_env_variable __system__path PATH
reset_env_variable __system__pythonpath PYTHONPATH
reset_env_variable __system__ld_library_path LD_LIBRARY_PATH
reset_env_variable __system__ldflags LDFLAGS
reset_env_variable __system__cppflags CPPFLAGS # unify with CXXFLAGS?
reset_env_variable __system__manpath MANPATH

unset reset_env_variable

# Various options
if which nvim >/dev/null; then
	alias vi='nvim '
	alias vim='nvim '
	alias vimdiff='nvim -d '
	export EDITOR=$(which nvim)
else
	export EDITOR=$(which vi)
fi
set -o vi
umask 022				# Force normal umask
alias ls='ls --color=auto '
export VISUAL=$EDITOR
if which w3m >/dev/null; then export BROWSER=/usr/bin/w3m; fi
#export TZ=US/Eastern	# Force timezone
#export LANG=en_US.UTF-8	# Force language
#export LANGUAGE=en_US:en
#export LC_ALL=en_US.UTF-8
#export LC_CTYPE=en_US.UTF-8
#export LC_COLLATE=en_US.UTF-8

export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:$HOME/.ghcup/bin:$HOME/.cabal/bin:$ASDF_DATA_DIR/shims:$PATH"

if [[ -z $__loaded__nvm ]]; then
	__loaded__nvm=yes
	# TODO: add other paths for this
	if [[ -e /usr/share/nvm/init-nvm.sh ]]; then
			export NVM_DIR="$HOME/.local/share/nvm"
			source /usr/share/nvm/init-nvm.sh
	fi
fi

export EDITOR=nvim
export VISUAL=nvim
export GPG_TTY=$(tty)
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi

# Local path
if [[ -d $HOME/.local ]]; then
	export PREFIX=$HOME/.local
	if [[ -d $PREFIX/src ]]; then export PYTHONPATH=$PREFIX/src:$PYTHONPATH; fi
	if [[ -d $PREFIX/share/man ]]; then
		export MANDIR=$PREFIX/share/man
		export MANPATH=$PREFIX/share/man:/usr/local/share/man:/usr/share/man
	fi
	if [[ -d $PREFIX/bin ]]; then export PATH=$PREFIX/bin:$PATH; fi
	if [[ -d $PREFIX/lib ]]; then
		export LD_LIBRARY_PATH=$PREFIX/lib:$PATH
		export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
	fi
	if [[ -d $PREFIX/include ]]; then
		export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
	fi
fi
if
	which less >/dev/null; then
	export PAGER=$(which less)
	export LESS_TERMCAP_mb=$'\E[01;32m'
	export LESS_TERMCAP_md=$'\E[01;32m'
	export LESS_TERMCAP_me=$'\E[0m'
	export LESS_TERMCAP_se=$'\E[0m'
	export LESS_TERMCAP_so=$'\E[01;47;34m'
	export LESS_TERMCAP_ue=$'\E[0m'
	export LESS_TERMCAP_us=$'\E[01;36m'
	export LESS=-R
fi

# GnuPG
export GPG_TTY=$(tty)

if [[ $_my_zprofile_shell == bash ]]; then

	# Make bash check its window size after a process completes
	shopt -s checkwinsize

	# Set a nice prompt
	_my_zprofile_black='\[\e[0;30m\]'
	_my_zprofile_red='\[\e[0;31m\]'
	_my_zprofile_green='\[\e[0;32m\]'
	_my_zprofile_yellow='\[\e[0;33m\]'
	_my_zprofile_blue='\[\e[0;34m\]'
	_my_zprofile_magenta='\[\e[0;35m\]'
	_my_zprofile_cyan='\[\e[0;36m\]'
	_my_zprofile_white='\[\e[0;37m\]'
	_my_zprofile_bblack='\[\e[0;1;30m\]'
	_my_zprofile_bred='\[\e[0;1;31m\]'
	_my_zprofile_bgreen='\[\e[0;1;32m\]'
	_my_zprofile_byellow='\[\e[0;1;33m\]'
	_my_zprofile_bblue='\[\e[0;1;34m\]'
	_my_zprofile_bmagenta='\[\e[0;1;35m\]'
	_my_zprofile_bcyan='\[\e[0;1;36m\]'
	_my_zprofile_bwhite='\[\e[0;1;37m\]'
	_my_zprofile_normal='\[\e[0m\]'
	_my_zprofile_byellow_for_sed='\\\[\\\e[0;1;33m\\\]'
	if [[ -r /usr/share/powerline/bindings/bash/powerline.sh ]]; then
		if [[ -z $__loaded__powerline ]]; then
			__loaded__powerline=yes
			powerline-daemon -q
			POWERLINE_BASH_CONTINUATION=1
			POWERLINE_BASH_SELECT=1
			source /usr/share/powerline/bindings/bash/powerline.sh
		fi
	else
		export PS1="${_my_zprofile_bgreen}\\u${_my_zprofile_green}@${_my_zprofile_bgreen}\\h:${_my_zprofile_bcyan}\\w${_my_zprofile_bwhite}\\\$${_my_zprofile_normal} "
	fi

	if [[ -z $__loaded__bash_eternal_history ]]; then
		__loaded__bash_eternal_history=yes
		export HISTSIZE=-1
		export HISTFILESIZE=-1
		shopt -s histappend
		PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
		export HISTFILE=~/.bash_eternal_history
		export HISTCONTROL=ignoredups:ignorespace
	fi

elif [[ $_my_zprofile_shell == zsh ]]; then

	setopt PROMPT_SUBST

	_my_zprofile_prompt_symbol() {
		if [[ $1 -eq 0 ]]; then
			if [[ $EUID -eq 0 ]]; then
				echo "%F{white}%B#%b"
			else
				echo "%F{white}%B%%%b"
			fi
		elif [[ $1 -eq 1 ]]; then
			echo "%F{red}%B×%b"
		else
			echo "%F{red}<%B$1%b>"
		fi
	}

	if [[ -r /usr/share/powerline/bindings/zsh/powerline.zsh ]]; then
		if [[ -z $__loaded__powerline ]]; then
			__loaded__powerline=yes
			powerline-daemon -q
			source /usr/share/powerline/bindings/zsh/powerline.zsh
		fi
	else
		export VIRTUAL_ENV_DISABLE_PROMPT=true
		export PS1='%F{blue}%n%F{green}@%F{cyan}%m%F{magenta}:%F{yellow}%U%~%u%F{blue}${VIRTUAL_ENV_PROMPT:+($VIRTUAL_ENV_PROMPT)}$(_my_zprofile_prompt_symbol $?)%f '
	fi

	setopt BANG_HIST                 # Treat the '!' character specially during expansion.
	setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
	setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
	setopt SHARE_HISTORY             # Share history between all sessions.
	setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
	setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
	#setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
	setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
	setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
	setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
	setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
	setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
	setopt HIST_BEEP                 # Beep when accessing nonexistent history.
	setopt HIST_IGNORE_SPACE		 # Ignore entries that start with a space
	export HISTFILE=$HOME/.zsh_eternal_history
	export HISTSIZE=10000000
	export SAVEHIST=$HISTSIZE

	unsetopt correct
	setopt extended_glob
	unsetopt no_case_glob
	setopt numericglobsort
	setopt nobeep


	# Use history substring search
	# TODO: add homebrew path for this
	if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
		if [[ -z $__loaded__zsh_history_substring_search ]]; then
			__loaded__zsh_history_substring_search=yes
			source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
		fi

		# bind UP and DOWN arrow keys to history substring search
		zmodload zsh/terminfo
		bindkey "$terminfo[kcuu1]" history-substring-search-up
		bindkey "$terminfo[kcud1]" history-substring-search-down
		bindkey '^[[A' history-substring-search-up
		bindkey '^[[B' history-substring-search-down
	fi

	# This needs to be the last thing initialized.
	# TODO: add homebrew path for this
	if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
		if [[ -z $__loaded__zsh_syntax_highlighting ]]; then
			__loaded__zsh_syntax_highlighting=yes
			source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
		fi
	fi
else
	if [ $(id -u) != 0 ]; then
		export PS1="$USER"@"$HOST""$ "
	else
		export PS1="$USER"@"$HOST""# "
	fi
fi
