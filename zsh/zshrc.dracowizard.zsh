# @!os:unix
# @!user:dracowizard
# @!install:644:$HOME/.zshrc

# GPG TTY (requires interactive shell)
export GPG_TTY=$(tty)

# Aliases
if which nvim >/dev/null; then
	alias vi='nvim '
	alias vim='nvim '
	alias vimdiff='nvim -d '
fi
set -o vi
alias ls='ls --color=auto '
if which w3m >/dev/null; then export BROWSER=/usr/bin/w3m; fi

# omp completions
if [[ -z $__loaded__omp ]] && command -v omp >/dev/null 2>&1; then
	__loaded__omp=yes
	if [[ $_my_zprofile_shell == bash ]]; then
		eval "$(omp completions bash)"
	elif [[ $_my_zprofile_shell == zsh ]]; then
		eval "$(omp completions zsh)"
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


# --- Shell-specific interactive config ---

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

	_clear_term_title() {
		print -n -- $'\e]0;zsh\a'
	}

	if [[ -z $__loaded__clear_term_title ]]; then
		__loaded__clear_term_title="yes"
		autoload -Uz add-zsh-hook
		add-zsh-hook precmd _clear_term_title
		_clear_term_title
	fi

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
