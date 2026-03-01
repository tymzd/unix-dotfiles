#!/bin/sh
# --- Personal Setup ---
# DP-2 (Lenovo) on the left, DP-1 (Dell) on the right.
xrandr --output DP-2 --mode 3840x2160 --pos 0x0 --rotate normal 
       --output DP-1 --mode 3840x2160 --pos 3840x0 --rotate normal 
       --output HDMI-0 --off 
       --output DP-0 --off 
       --output DP-3 --off 
       --output DP-4 --off 
       --output DP-5 --off

# Nvidia Tearing Fix
nvidia-settings --assign CurrentMetaMode="DP-2: nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }, DP-1: nvidia-auto-select +3840+0 { ForceFullCompositionPipeline = On }"

# Wallpaper
feh --bg-fill /home/tym/Pictures/Wallpapers/cityscape/tokyo-night.jpg
