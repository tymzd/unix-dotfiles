#!/bin/sh
# Assumes that all packages in pkglist.txt have been installed.

# ---------------------------------------------------------------------------- #
#                                Setting up ZSH                                #
# ---------------------------------------------------------------------------- #

# Change default shell to Zsh.
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    echo "Changing shell to Zsh..."
    chsh -s /usr/bin/zsh
fi

# Install oh-my-zsh if not already present.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install powerlevel10k theme.
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Installing powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# Zsh extensions.
PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
fi

if [ ! -d "$PLUGINS_DIR/fast-syntax-highlighting" ]; then
    echo "Installing fast-syntax-highlighting..."
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$PLUGINS_DIR/fast-syntax-highlighting"
fi
