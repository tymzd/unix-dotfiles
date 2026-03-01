# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 1. PATH & ENVIRONMENT VARIABLES                                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
export PATH="${HOME}/Scripts:${HOME}/.local/bin:${PATH}"
export EDITOR='vim'
export MANPAGER='vim -M +MANPAGER -'
export LESS="-R"

# Language Specifics
export GOPATH="${HOME}/go"
export GOBIN="${GOPATH}/bin"
export GEM_HOME="${HOME}/gems"
export PATH="${GOBIN}:${GOPATH}:${GEM_HOME}/bin:${PATH}"

# pnpm
export PNPM_HOME="${HOME}/.local/share/pnpm"
[[ -d "$PNPM_HOME" ]] && export PATH="$PNPM_HOME:$PATH"

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 2. OH MY ZSH CONFIGURATION                                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
# ╭─ Instant Prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ╭─ OMZ Setup
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_UPDATE="true"
ZSH_DISABLE_COMPFIX="true"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(
	git
	fast-syntax-highlighting
	zsh-autosuggestions
	zsh-vi-mode
)

# Speed up compinit by skipping timestamp checks if the cache is less than 24h old.
for dump in ~/.zcompdump*(N.m-1); do
	alias compinit="compinit -C"
	break
done

[[ -f "${ZSH}/oh-my-zsh.sh" ]] && source "${ZSH}/oh-my-zsh.sh"
unalias compinit 2>/dev/null

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 3. SHELL TOOLS (FZF, Zoxide, Atuin)                                        ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
# ╭─ FZF
[[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
[[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
if command -v fzf >/dev/null; then
    source <(fzf --zsh)
fi

# ╭─ Zoxide (Cached for Speed)
if command -v zoxide >/dev/null; then
    if [[ -f ~/.cache/zoxide.zsh ]]; then
        source ~/.cache/zoxide.zsh
    else
        zoxide init zsh > ~/.cache/zoxide.zsh
        source ~/.cache/zoxide.zsh
    fi
    alias cd='z'
fi

# ╭─ Atuin
if command -v atuin >/dev/null; then
    eval "$(atuin init zsh --disable-up-arrow)"
    bindkey '^h' _atuin_search_widget
fi

# ╭─ Theme Config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 4. GOOGLE INTERNAL & CORP CONFIG                                           ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
if [[ "$USER" == "timzh" ]]; then
    # Path Updates
    # Note: Laptop has /usr/local/google but not /google
    export PATH="/usr/local/go/bin:${HOME}/bin:${HOME}/bin/protoc/bin:${PATH}"

    # Google SDK / Gcloud
    [[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]] && . "${HOME}/google-cloud-sdk/path.zsh.inc"
    [[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]] && . "${HOME}/google-cloud-sdk/completion.zsh.inc"

    # Completions
    [[ -e /etc/bash_completion.d/hgd ]] && source /etc/bash_completion.d/hgd
    [[ -f /etc/bash_completion.d/g4d ]] && source /etc/bash_completion.d/g4d

    # Google Specific Aliases
    alias cider="/opt/google/chrome/google-chrome \"--profile-directory=Profile 1\" --app-id=apkjikbjlghbonboeaehkeoadefnfjmb"
    alias cloudtop='ssh ${USER}@${USER}.c.googlers.com -Y -C'
    alias gemini='/google/bin/releases/gemini-cli/tools/gemini'
    alias plxutil='/google/bin/releases/plx/plxutil/live/plxutil'
    alias pubsub='/google/bin/releases/goops/pubsub/pubsub'
    alias mdformat='/google/bin/releases/corpeng-engdoc/tools/mdformat'
    alias prodspec='/google/bin/releases/rollouts/prodspec/prodspec'

    # Project Specific
    alias ss='code ~/sos'
    alias deploy='code ~/deploy'
    alias sites='code ~/sites'
fi


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 5. UTILITY FUNCTIONS (Base64, Hex, Hashes)                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
_get_input() {
  if [ -t 0 ]; then
    [ -z "$1" ] && return 1
    echo -n "$1"
  else
    cat -
  fi
}

from64()  { _get_input "$@" | base64 --decode }
to64()    { _get_input "$@" | base64 }
tohex()   { _get_input "$@" | xxd -p -c 0 }
fromhex() { _get_input "$@" | xxd -r -p }

sha256base64() { [[ -f "$1" ]] && openssl dgst -sha256 -binary "$1" | base64 || printf '%s' "$1" | openssl dgst -sha256 -binary | base64 }
sha1base64()   { [[ -f "$1" ]] && openssl dgst -sha1 -binary "$1" | base64   || printf '%s' "$1" | openssl dgst -sha1 -binary | base64 }
sha512base64() { [[ -f "$1" ]] && openssl dgst -sha512 -binary "$1" | base64 || printf '%s' "$1" | openssl dgst -sha512 -binary | base64 }

# Deps.dev specific
function apply_prod {
  for cluster in $(sos cluster list | grep 'Home' | awk '{print $2}'); do
    echo "Applying $cluster..."; sos spanner -cluster=$cluster apply ~/sos/config/spanner/sos-prod.ddl
  done
}

# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 6. SHELL SETTINGS & VIM MODE                                               ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
bindkey -v
bindkey '^R' history-incremental-search-backward

# ╭─ Cursor Shaping Logic
function zle-keymap-select () {
    case $KEYMAP in
        vicmd)      echo -ne '\e[1 q';; # Block
        viins|main) echo -ne '\e[5 q';; # Beam
    esac
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"
}
zle -N zle-line-init

preexec() { echo -ne '\e[5 q' ;}
echo -ne '\e[5 q'


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 7. ALIASES                                                                 ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
# ╭─ Environment Detection
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    alias screenshot='grim -g "$(slurp)" - | wl-copy'
    alias copy='wl-copy'
    alias paste='wl-paste'
    alias saveimg='wl-paste > '
    alias hyprconf='$EDITOR ~/.config/hypr/hyprland.conf'
    alias waybarconf='$EDITOR ~/.config/waybar/config'
else
    alias screenshot='import png:- | xclip -selection clipboard -t image/png'
    alias copy='xclip -selection clipboard'
    alias saveimg='xclip -selection clipboard -target image/png -out'
    alias i3conf='$EDITOR ~/.config/i3/config'
    alias i3r='i3-msg restart'
    alias picomconf='$EDITOR ~/.config/picom/picom.conf'
    alias polybarconf='$EDITOR ~/.config/polybar/config.ini'
    
    if command -v setxkbmap >/dev/null; then
        setxkbmap -option caps:swapescape
    fi
fi

# ╭─ General
alias ls='ls -a --color=auto'
alias notify="notify-send"
alias less='less -N'
alias zshconf='$EDITOR ~/.zshrc'
alias vimconf='$EDITOR ~/.vimrc'
alias fix="eval $(ssh-agent -s)"

# ╭─ System Management
alias syncdotfiles='stow --target=$HOME --adopt --dir ~/unix-dotfiles home-config && ~/.config/i3/detect_env.sh'

# ╭─ Git
alias s="git status"
alias c="git commit -m "
alias a="git commit --amend"
alias p="git pull"
alias u="git push"
alias b="git branch"


# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 8. FINAL HOOKS                                                             ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
# ╭─ NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

# ╭─ Machine Local Overrides
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
