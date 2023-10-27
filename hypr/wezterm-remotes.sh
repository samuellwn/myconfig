#! /bin/zsh

declare -A wezterms forwards

# these arrays link gui name choices to commands
wezterms[hoard]="wezterm connect hoard"
forwards[hoard]="ssh hoard -N -R /Users/dracowizard/.gnupg/S.gpg-agent:/run/user/1000/gnupg/S.gpg-agent.extra -R /Users/dracowizard/.gnupg/S.gpg-agent.ssh:/run/user/1000/gnupg/S.gpg-agent.ssh"
wezterms[joshair]="wezterm connect joshair"
forwards[joshair]="ssh joshair -N -R /Users/dracowizard/.gnupg/S.gpg-agent:/run/user/1000/gnupg/S.gpg-agent.extra -R /Users/dracowizard/.gnupg/S.gpg-agent.ssh:/run/user/1000/gnupg/S.gpg-agent.ssh"
wezterms[imac]="wezterm connect imac"
forwards[imac]="ssh imac -N -R /Users/dracowizard/.gnupg/S.gpg-agent:/run/user/1000/gnupg/S.gpg-agent.extra -R /Users/dracowizard/.gnupg/S.gpg-agent.ssh:/run/user/1000/gnupg/S.gpg-agent.ssh"

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

	${=forwards[$host]} &
	echo $! > $pidfile
	disown $!
fi

# launch the wezterm
exec ${=wezterm[$host]}
