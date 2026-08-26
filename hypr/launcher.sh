!#/bin/zsh
# @!os:linux
# @!user:dracowizard
# @!install:755:$HOME/.config/hypr/launcher.sh

if command -v uwsm >/dev/null && uwsm check is-active; then
	D=$(wofi --show drun --define=drun-print_desktop_file=true)
	case "$D" in
		*'.desktop '*) D="${D%.desktop *}.desktop:${D#*.desktop }";;
	esac

	exec uwsm app -- "$D" $@
else
	exec hyprctl eval "hl.exec_cmd('$(wofi --show drun --define=drun-print_command=true)')"
fi
