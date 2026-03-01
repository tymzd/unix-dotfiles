#!/bin/bash

TEMP_FILE="/tmp/current_redness_temp"
DEFAULT_TEMP=6500
STEP=500
MIN_TEMP=1000
MAX_TEMP=6500

# Get current temperature or set default
if [ -f "$TEMP_FILE" ]; then
    CURRENT_TEMP=$(cat "$TEMP_FILE")
    # Basic validation
    if ! [[ "$CURRENT_TEMP" =~ ^[0-9]+$ ]]; then
        CURRENT_TEMP=$DEFAULT_TEMP
    fi
else
    CURRENT_TEMP=$DEFAULT_TEMP
fi

case "$1" in
    increase)
        NEW_TEMP=$((CURRENT_TEMP - STEP))
        [ "$NEW_TEMP" -lt "$MIN_TEMP" ] && NEW_TEMP=$MIN_TEMP
        
        pkill -9 -f hyprsunset 2>/dev/null
        hyprsunset -t "$NEW_TEMP" &
        echo "$NEW_TEMP" > "$TEMP_FILE"
        ;;
    decrease)
        NEW_TEMP=$((CURRENT_TEMP + STEP))
        [ "$NEW_TEMP" -gt "$MAX_TEMP" ] && NEW_TEMP=$MAX_TEMP
        
        pkill -9 -f hyprsunset 2>/dev/null
        if [ "$NEW_TEMP" -lt "$MAX_TEMP" ]; then
            hyprsunset -t "$NEW_TEMP" &
        fi
        echo "$NEW_TEMP" > "$TEMP_FILE"
        ;;
    reset)
        pkill -9 -f hyprsunset 2>/dev/null
        echo "$DEFAULT_TEMP" > "$TEMP_FILE"
        ;;
    *)
        echo "Usage: $0 {increase|decrease|reset}"
        exit 1
        ;;
esac
