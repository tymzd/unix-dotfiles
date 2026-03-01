#!/bin/sh
# --- Corp Desktop (Google) ---
xrandr --output DisplayPort-0 --off 
       --output DisplayPort-1 --mode 2560x1440 --pos 0x0 --rotate left 
       --output DisplayPort-2 --mode 3440x1440 --pos 1440x560 --rotate normal 
       --output DisplayPort-3 --mode 2560x1440 --pos 4880x0 --rotate right

# Wallpaper
feh --bg-fill ~/Pictures/Wallpapers/main.png
