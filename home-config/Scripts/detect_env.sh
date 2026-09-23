#!/bin/bash
HOME_CONFIG="$HOME/unix-dotfiles/home-config"
I3_REPO="$HOME_CONFIG/.config/i3"
LAYOUT_REPO="$HOME_CONFIG/.screenlayout"

if [ "$USER" = "timzh" ]; then
    if [ -d "/google" ]; then
        echo "Detected Corp Desktop..."
        ln -sf "config.corp" "$I3_REPO/config.local"
        ln -sf "layout.corp.sh" "$LAYOUT_REPO/main.sh"
        ln -sf "$HOME_CONFIG/gitconfig.corp" "$HOME/.gitconfig.local"
    else
        echo "Detected Corp Laptop..."
        ln -sf "config.laptop" "$I3_REPO/config.local"
        ln -sf "layout.laptop.sh" "$LAYOUT_REPO/main.sh"
        ln -sf "$HOME_CONFIG/gitconfig.laptop" "$HOME/.gitconfig.local"
    fi
else
    echo "Detected Personal Setup..."
    ln -sf "config.personal" "$I3_REPO/config.local"
    ln -sf "layout.personal.sh" "$LAYOUT_REPO/main.sh"
    ln -sf "$HOME_CONFIG/gitconfig.personal" "$HOME/.gitconfig.local"
fi

# Ensure all screenlayout scripts are executable.
chmod +x "$LAYOUT_REPO"/*.sh

# Point vim/vi/editor in ~/.local/bin to Neovim if installed.
if [ -x "/usr/bin/nvim" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/nvim "$HOME/.local/bin/vim"
    ln -sf /usr/bin/nvim "$HOME/.local/bin/vi"
    ln -sf /usr/bin/nvim "$HOME/.local/bin/editor"
fi
