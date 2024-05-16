#! /bin/zsh
#
# @!os:linux
# @!user:dracowizard
# @!install:755:$HOME/.config/hypr/wezterm-remotes.sh

declare -A wezterms forwards

# these arrays link gui name choices to commands
wezterms[hoard]="wezterm connect hoard"
forwards[hoard]="ssh hoard -nN -R /Users/dracowizard/.gnupg/S.gpg-agent:/run/user/1000/gnupg/S.gpg-agent.extra -R /Users/dracowizard/.gnupg/S.gpg-agent.ssh:/run/user/1000/gnupg/S.gpg-agent.ssh -R 10999:127.0.0.1:10999"
wezterms[joshair]="wezterm connect joshair"
forwards[joshair]="ssh joshair -nN -R /Users/dracowizard/.gnupg/S.gpg-agent:/run/user/1000/gnupg/S.gpg-agent.extra -R /Users/dracowizard/.gnupg/S.gpg-agent.ssh:/run/user/1000/gnupg/S.gpg-agent.ssh"
wezterms[imac]="wezterm connect imac"
forwards[imac]="ssh imac -nN -R /Users/dracowizard/.gnupg/S.gpg-agent:/run/user/1000/gnupg/S.gpg-agent.extra -R /Users/dracowizard/.gnupg/S.gpg-agent.ssh:/run/user/1000/gnupg/S.gpg-agent.ssh"
wezterms[roosh]="wezterm connect roosh"
wezterms[roosh]="ssh roosh -nN -R /run/user/999/gnupg/S.gpg-agent:/run/user/1000/S.gpg-agent.extra -R /run/user/999/gnupg/S.gpg-agent.ssh:/run/user/1000/S.gpg-agent.ssh"

# prompt the user to select a host
host=$(echo ${(Fk)wezterms} | wofi --show=dmenu)

# don't continue if the user selected no host
if [[ $? != 0 || -z $host ]]; then
	exit $?
fi

# setup the forwards
mkdir -p ~/.cache/ssh-forwards
pidfile=~/.cache/ssh-forwards/$host
if [[ -n ${forwards[$host]} ]]; then
	if [[ -f $pidfile ]]; then
		kill $(<$pidfile) && rm $pidfile
	fi

	# make sure the local gpg-agent is running
	gpg-connect-agent /bye

	${=forwards[$host]} &
	echo $! > $pidfile
	disown %%
fi

# launch the wezterm
exec ${=wezterms[$host]}
