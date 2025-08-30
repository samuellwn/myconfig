!#/bin/zsh
# @!os:linux
# @!user:dracowizard
# @!install:755:$HOME/.config/hypr/launcher.sh

D=$(wofi --show drun --define=drun-print_desktop_file=true)
case "$D" in
	*'.desktop '*) D="${D%.desktop *}.desktop:${D#*.desktop }";;
esac

exec uwsm app -- "$D" $@
