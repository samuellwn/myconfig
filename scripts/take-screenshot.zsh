#!/usr/bin/env zsh
# @!os:unix
# @!user:dracowizard
# @!install:755:$HOME/.local/bin/take-screenshot.zsh

set -euo pipefail

filename="$HOME/Pictures/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"

hyprpicker_pid=

if command -v hyprpicker &>/dev/null; then
	hyprpicker -r -z &
	sleep 0.2
	hyprpicker_pid=$!
	TRAPEXIT() {
		kill $hyprpicker_pid
	}
fi

if command -v gpu-screen-recorder &>/dev/null; then
	gpu-screen-recorder -w region -region $(slurp -do -f "%wx%h+%x+%y") \
		-cursor no -v no -o $filename
else
	grim -g $(slurp -do) $filename
fi

wl-copy --type image/png <$filename
