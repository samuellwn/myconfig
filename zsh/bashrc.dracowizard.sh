# @!os:unix
# @!user:dracowizard
# @!install:644:$HOME/.profile
# @!install:644:$HOME/.bashrc

if [[ -z __loaded_bash_profile ]]; then
	__loaded_bash_profile=yes
	. $HOME/.zshenv
	if [[ $- == *i* ]]; then
		. $HOME/.zshrc
	fi
fi
