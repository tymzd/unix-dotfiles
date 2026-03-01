#!/bin/sh
# --- Corp Laptop ---
xrandr --output eDP-1 --primary --mode 3840x2400 --pos 0x0 --rotate normal 
       --output HDMI-1 --mode 3840x2160 --pos 7680x0 --rotate normal 
       --output DP-3 --mode 3840x2160 --pos 3840x0 --rotate normal 
       --output DP-1 --off 
       --output DP-2 --off 
       --output DP-4 --off

# Wallpaper
feh --bg-fill ~/Pictures/Wallpapers/debian.png
