#! /bin/zsh

case $(uname -o) in
	GNU/Linux) OS=linux; OS2=unix;;
	Darwin) OS=darwin; OS2=unix;;
esac

find . -path ./.git -prune -o -type f \! -name install.sh -print | while read i; do
	grep '@install:' "$i" | sed 's/^[^@]*@install://' | while IFS=: read dst mode if_os if_user; do
		if [[ $if_os != $OS && $if_os != $OS2 && $if_os != "*" ]]; then
			continue
		fi

		if [[ $if_user != $USER && $if_user != "*" ]]; then
			continue
		fi

		# run expansion on dst
		dst=${(e)dst}

		install -d -m 755 $(dirname $dst)
		install -m ${mode:-644} $i $dst
	done
done
