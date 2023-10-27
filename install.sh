#! /bin/zsh

case $(uname -o) in
	GNU/Linux) OS=linux; OS2=unix;;
	Darwin) OS=darwin; OS2=unix;;
esac

file=$(mktemp /tmp/myconfig.XXXXXXX)
trap "rm $file" EXIT

find . -path ./.git -prune -o -type f \! -name install.sh -print | while read src; do
	zshexpn=no
	if_os=
	if_user=
	if_host=
	grep -E '@!\w+:' $src | sed -E 's/^.*@!//' | while IFS=: read -Ar cmd; do
		case $cmd[1] in
			os) if_os=$cmd[2];;
			user) if_user=$cmd[2];;
			host) if_host=$cmd[2];;
			zshexpn) zshexpn=yes;;
		esac
		if [[ -n $if_os && $if_os != $OS && $if_os != $OS2 ]]; then
			continue
		fi
		if [[ -n $if_user && $if_user != $USER ]]; then
			continue
		fi
		if [[ -n $if_host && $if_host != $(hostname) ]]; then
			continue
		fi
		case $cmd[1] in
			install)
				dst=${(e)cmd[3]}
				instsrc=$src
				if [[ $zshexpn = yes ]]; then
					contents=$(cat $src)
					contents=${(e)contents}
					printf "%s" $contents > $file
					instsrc=$file
				fi

				install -d -m 755 $(dirname $dst)
				install -m ${cmd[2]} $instsrc $dst
				echo "$src -> $dst"
				;;
			postexec)
				# uncomment once i'm sure this does the right thing
				# ${=cmd[2]}
				echo "NOT IMPLEMENTED exec $cmd[2]"
				;;
		esac
	done
done

