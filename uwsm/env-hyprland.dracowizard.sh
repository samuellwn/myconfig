# @!os:linux
# @!user:dracowizard
# @!install:644:$HOME/.config/uwsm/env-hyprland

export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

export QT_WAYLAND_DISABLE_WINDOWDECORATIONS=1

# Why is AWT the only toolkit that needs this?
export _JAVA_AWT_WM_NONREPARENTING=1

__this_host__=$(printf "%s\n" "$HOST" | cut -d. -f1)

if [[ $__this_host__ == "dragonfury" ]]; then
	# X11 DPI scaling
	#export QT_AUTO_SCREEN_SCALE_FACTOR=1
	#export QT_ENABLE_HIGHDPI_SCALING=1
	export QT_SCALE_FACTOR=1.4
	export GDK_SCALE=2
	export DPF_SCALE_FACTOR=1.4 # DPF-based synths
	export JUCE_SCALE_FACTOR=1.4 # JUCE-based synths
elif [[ $__this_host__ == "dragonfire" ]]; then
	export AQ_DRM_DEVICES="/dev/dri/igpu"

	export QT_SCALE_FACTOR=1.5
	export GDK_SCALE=2
	export DPF_SCALE_FACTOR=1.5 # DPF-based synths
	export JUCE_SCALE_FACTOR=1.5 # JUCE-based synths
else
	export QT_SCALE_FACTOR=1.5
	export GDK_SCALE=2
	export DPF_SCALE_FACTOR=1.5 # DPF-based synths
	export JUCE_SCALE_FACTOR=1.5 # JUCE-based synths
fi
