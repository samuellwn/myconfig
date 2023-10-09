#! /bin/zsh

case $(uname -o) in
	GNU/Linux) OS=linux; OS2=unix;;
	Darwin) OS=darwin; OS2=unix;;
esac

file=$(mktemp /tmp/myconfig.XXXXXXX)
trap "rm $file" EXIT

find . -path ./.git -prune -o -type f \! -name install.sh -print | while read i; do
	grep '@install[,:]' "$i" | sed -E 's/^[^@]*@//' | while IFS=: read flagstr dst mode if_os if_user; do
		expand=no
		eval "$(echo "$flagstr" | tr , '\n' | sed 's/^.*$/&=yes/' | tr '\n' ';')"

		if [[ $if_os != $OS && $if_os != $OS2 && $if_os != "*" ]]; then
			continue
		fi

		if [[ $if_user != $USER && $if_user != "*" ]]; then
			continue
		fi

		# run expansion on dst
		dst=${(e)dst}

		# maybe run expansion on file contents
		contents="$(cat $i)"
		if [[ $expand = yes ]]; then
			contents=${(e)contents}
		fi

		printf "%s" "$contents" > $file

		install -d -m 755 $(dirname $dst)
		install -m ${mode:-644} $file $dst

		echo "$i -> $dst"
	done
	grep '@postexec:' "$i" | while IFS=: read read if_os if_user cmd; do
		if [[ $if_os != $OS && $if_os != $OS2 && $if_os != "*" ]]; then
			continue
		fi

		if [[ $if_user != $USER && $if_user != "*" ]]; then
			continue
		fi

		${=cmd}

		echo "exec $cmd"
	done

done
