#!/usr/bin/env bash

# Get active window info
win_info=$(hyprctl activewindow -j)

# Check if jq successfully parsed the JSON
if [[ -z "$win_info" ]]; then
    exit 1
fi

# Get the size of the group array
group_size=$(echo "$win_info" | jq '.grouped | length')

# If not in a group, just move focus
if [[ "$group_size" -le 1 ]]; then
    hyprctl dispatch "hl.dsp.focus({ direction = \"$1\" })"
    exit 0
fi

# If in a group, handle navigation
address=$(echo "$win_info" | jq -r '.address')
position=$(echo "$win_info" | jq -r --arg addr "$address" '.grouped | index($addr)')
last_index=$((group_size - 1))

case "$1" in
    l) # Left
        if [[ "$position" -eq 0 ]]; then
            hyprctl dispatch 'hl.dsp.focus({ direction = "l" })'
        else
            hyprctl dispatch 'hl.dsp.group.prev()'
        fi
        ;;
    r) # Right
        if [[ "$position" -eq "$last_index" ]]; then
            hyprctl dispatch 'hl.dsp.focus({ direction = "r" })'
        else
            hyprctl dispatch 'hl.dsp.group.next()'
        fi
        ;;
    u) # Up
        hyprctl dispatch 'hl.dsp.focus({ direction = "u" })'
        ;;
    d) # Down
        hyprctl dispatch 'hl.dsp.focus({ direction = "d" })'
        ;;
esac
