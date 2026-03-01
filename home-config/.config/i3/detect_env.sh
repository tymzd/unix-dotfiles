#!/bin/bash
I3_DIR="$HOME/.config/i3"
LAYOUT_DIR="$HOME/.screenlayout"

if [ "$USER" = "timzh" ]; then
    if [ -d "/google" ]; then
        echo "Detected Corp Desktop..."
        ln -sf "$I3_DIR/config.corp" "$I3_DIR/config.local"
        ln -sf "$LAYOUT_DIR/layout.corp.sh" "$LAYOUT_DIR/main.sh"
    else
        echo "Detected Corp Laptop..."
        ln -sf "$I3_DIR/config.laptop" "$I3_DIR/config.local"
        ln -sf "$LAYOUT_DIR/layout.laptop.sh" "$LAYOUT_DIR/main.sh"
    fi
else
    echo "Detected Personal Setup..."
    ln -sf "$I3_DIR/config.personal" "$I3_DIR/config.local"
    ln -sf "$LAYOUT_DIR/layout.personal.sh" "$LAYOUT_DIR/main.sh"
fi
