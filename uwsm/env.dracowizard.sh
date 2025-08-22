# @!os:linux
# @!user:dracowizard
# @!install:644:$HOME/.config/uwsm/env

export GDK_BACKEND="wayland,x11"
export QT_QPA_PLATFORM="wayland;xcb"
# apparently, SDL's wayland support isn't reliable
# export SDL_VIDEODRIVER="wayland"
export CLUTTER_BACKEND="wayland"
export XDG_SESSION_TYPE="wayland"
export ELECTRON_OZONE_PLATFORM_HINT="wayland"
