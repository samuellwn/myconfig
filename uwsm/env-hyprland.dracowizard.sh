# @!os:linux
# @!user:dracowizard
# @!install:644:$HOME/.config/uwsm/env-hyprland

export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland

export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_DISABLE_WINDOWDECORATIONS=1

# Why is AWT the only toolkit that needs this?
export _JAVA_AWT_WM_NONREPARENTING=1

if [[ $(hostname) == dragonfire ]]; then
	export AQ_DRM_DEVICES="/dev/dri/igpu:/dev/dri/dgpu"
fi
