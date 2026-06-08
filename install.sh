#! /bin/zsh

# v1.1

case $(uname -o) in
	GNU/Linux) OS=linux; OS_FAMILY=unix;;
	Darwin) OS=darwin; OS_FAMILY=unix;;
esac

file=$(mktemp /tmp/myconfig.XXXXXXX)
trap "rm $file" EXIT

this_user=$USER
# Aliases for usernames
if [[ $this_user == "sam" ]]; then this_user=dracowizard; fi

# Handle hostnames that have the domain part specified
this_host=$(printf "%s\n" $HOST | cut -d. -f1)

dirmodes=()

last_installed=""
find . -path ./.git -prune -o -type f \! -name install.sh -print | while read src; do
	zshexpn=no
	pipe_cmd=
	if_os=
	if_user=
	if_host=
	grep -E '@!\w+:' $src | sed -E 's/^.*@!//' | while IFS=: read -Ar cmd; do
		case $cmd[1] in
			os) if_os=$cmd[2];;
			user) if_user=$cmd[2];;
			host) if_host=$cmd[2];;
			zshexpn) zshexpn=yes;;
			pipe) pipe_cmd=$cmd[2];;
		esac
		if [[ -n $if_os && $if_os != $OS && $if_os != $OS_FAMILY ]]; then
			continue
		fi
		if [[ -n $if_user && $if_user != $USER && $if_user != $this_user ]]; then
			continue
		fi
		if [[ -n $if_host && $if_host != $HOST && $if_host != $this_host ]]; then
			continue
		fi
		case $cmd[1] in
			dirmode)
				if [[ ! ${dirmodes[(i)${cmd[2]}:${(e)cmd[3]}]} -le ${#dirmodes} ]]; then
					install -d -m ${cmd[2]} ${(e)cmd[3]}
					echo "dirmode ${cmd[2]} ${(e)cmd[3]}"
					dirmodes+=(${cmd[2]}:${(e)cmd[3]})
				fi
				;;
			install)
				dst=${(e)cmd[3]}
				instsrc=$src
				if [[ $zshexpn = yes ]]; then
					contents=$(cat $src)
					contents=${(e)contents}
					printf "%s" $contents > $file
					instsrc=$file
				fi

				if [[ -n $pipe_cmd ]]; then
					eval $pipe_cmd < $instsrc > $file
					instsrc=$file
				fi

				if [[ ! -d $(dirname $dst) ]]; then
					install -d -m 755 $(dirname $dst)
				fi
				install -m ${cmd[2]} $instsrc $dst
				if [[ -n $pipe_cmd ]]; then
					echo "install $src -> $pipe_cmd -> $dst"
				else
					echo "install $src -> $dst"
				fi
				last_installed=$dst
				;;
			hardlink)
				if [[ -z $last_installed ]]; then
					echo Cannot hardlink without installing a file first.
					exit 1
				fi
				src=$last_installed
				dst=${(e)cmd[2]}
				ln $src $dst
				echo "hardlink $src -> $dst"
				;;
			postexec)
				# uncomment once i'm sure this does the right thing
				# ${=cmd[2]}
				echo "NOT IMPLEMENTED exec $cmd[2]"
				;;
		esac
	done
done


# Sometimes Hyprland doesn't reload config properly
if command -v hyprctl >/dev/null; then
	hyprctl reload &>/dev/null || true
fi
