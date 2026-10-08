# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║ 1. PATH & ENVIRONMENT VARIABLES                                            ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
export PATH="${HOME}/Scripts:${HOME}/.local/bin:${PATH}"
export EDITOR='nvim'
export VISUAL='nvim'
export MANPAGER='nvim +Man!'
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

# Speed up compinit by skipping timestamp checks if the cache is recently updated.
# We check if the dump file exists and is not empty.
if [[ -s "${ZSH_COMPDUMP:-$HOME/.zcompdump-${SHORT_HOST:-${HOST%%.*}}-${ZSH_VERSION}}" ]]; then
  alias compinit="compinit -C"
fi

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
    if [ -d '/google/' ]; then
        alias cider="/opt/google/chrome/google-chrome \"--profile-directory=Profile 1\" --app-id=apkjikbjlghbonboeaehkeoadefnfjmb"
        alias cloudtop='ssh ${USER}@${USER}.c.googlers.com -Y -C'
        alias gemini='/google/bin/releases/gemini-cli/tools/gemini'
        alias plxutil='/google/bin/releases/plx/plxutil/live/plxutil'
        alias pubsub='/google/bin/releases/goops/pubsub/pubsub'
        alias mdformat='/google/bin/releases/corpeng-engdoc/tools/mdformat'
        alias prodspec='/google/bin/releases/rollouts/prodspec/prodspec'
    fi

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

# ╭─ Sneak (like vim-sneak / VSCodeVim's vim.sneak)
# [AI-generated by the Jetski coding agent, 2026-10-08. The jump logic was
#  tested with scripted inputs outside ZLE; live keypresses weren't tested.]
#
# Usage, in vi normal mode (press Esc first):
#   s{c1}{c2}  jump forward to the next occurrence of the two chars c1c2
#   S{c1}{c2}  jump backward to the previous occurrence
#   e.g. on `git commit -m foo --amend`, `s-m` lands on the -m.
# Behaviour:
#   - Literal match (* [ ? etc. are not globs), case-sensitive.
#   - Spans lines in multi-line buffers. No match = cursor doesn't move.
#   - Esc while typing the chars cancels.
# Not handled: ; / , repeat, counts (3sab), operators (dz..), visual mode.
# Replaces vi's built-in s (substitute char); use cl instead.
# Bound via zvm_after_lazy_keybindings_commands further below.

# Reads two keypresses into $REPLY; fails if either is Esc.
_sneak_read_pair() {
    local c1 c2
    read -k 1 c1 && [[ $c1 != $'\e' ]] || return 1
    read -k 1 c2 && [[ $c2 != $'\e' ]] || return 1
    REPLY="$c1$c2"
}
# Note: CURSOR is 0-based, but zsh string subscripts ($BUFFER[i]) are 1-based,
# so the character under the cursor is ${BUFFER[CURSOR+1]}.
sneak-forward() {
    _sneak_read_pair || return
    local pat=$REPLY
    local rest=${BUFFER[CURSOR+2,-1]}       # everything after the cursor char
    [[ $rest == *"$pat"* ]] || return
    local before=${rest%%"$pat"*}           # text up to the first match
    (( CURSOR += 1 + ${#before} ))
}
sneak-backward() {
    _sneak_read_pair || return
    local pat=$REPLY
    local upto=${BUFFER[1,CURSOR+1]}        # up to and including cursor char
    [[ $upto == *"$pat"* ]] || return
    local prefix=${upto%"$pat"*}            # text before the last match
    (( ${#prefix} < CURSOR )) || return     # match must start before cursor
    CURSOR=${#prefix}
}
zle -N sneak-forward
zle -N sneak-backward

# ╭─ camelCase motion (like VSCodeVim's vim.camelCaseMotion)
# [AI-generated by the Jetski coding agent, 2026-10-08. The motion logic was
#  tested with scripted inputs outside ZLE; live keypresses weren't tested.]
#
# Usage, in vi normal or visual mode:
#   <space>w  next start of a word part
#   <space>b  previous start of a word part
#   <space>e  next end of a word part
# Word parts: "getHTTPServer_url foo" -> get|HTTP|Server|url|foo
#   - New part on lower/digit -> Upper (fooBar), and before the last capital
#     of an acronym followed by lowercase (HTTPServer -> HTTP|Server).
#   - Spaces, tabs, newlines and _ separate parts (and are skipped).
#   - Runs of other punctuation (- / . = etc.) are parts of their own, like
#     Vim's w. Digits stick to the preceding letters (v2, utf8).
# Zsh has no <leader>, so space is simply the first key of a two-key binding.
# Plain space still moves right, after waiting KEYTIMEOUT (~0.4s) for a
# second key. Not handled: counts (3<space>w), operators (d<space>w).
# Bound via zvm_after_lazy_keybindings_commands below.

# Classifies one character into $REPLY:
#   u(pper) l(ower) d(igit) s(eparator: whitespace or _) p(unctuation)
_camel_class() {
    case $1 in
        [[:upper:]]) REPLY=u ;; [[:lower:]]) REPLY=l ;; [[:digit:]]) REPLY=d ;;
        ''|[[:space:]]|_) REPLY=s ;; *) REPLY=p ;;
    esac
}
# Fills the caller's camel_starts / camel_ends arrays with the 0-based CURSOR
# positions of every word-part start / end in $BUFFER (recomputed per call;
# command lines are short, so this is cheap enough).
_camel_parts() {
    local -i i n=${#BUFFER}
    local -a cls; local -A start
    for (( i = 1; i <= n; i++ )); do _camel_class "${BUFFER[i]}"; cls[i]=$REPLY; done
    camel_starts=() camel_ends=()
    for (( i = 1; i <= n; i++ )); do
        local c=$cls[i] p=${cls[i-1]:-s} x=${cls[i+1]:-s}
        [[ $c == s ]] && continue
        if [[ $p == s ]] || [[ $c == p && $p != p ]] || [[ $c != p && $p == p ]] ||
           [[ $c == u && $p == [ld] ]] || [[ $c == u && $p == u && $x == l ]]; then
            start[$i]=1; camel_starts+=( $(( i - 1 )) )
        fi
    done
    for (( i = 1; i <= n; i++ )); do
        [[ $cls[i] == s ]] && continue
        [[ ${cls[i+1]:-s} == s || -n ${start[$((i+1))]} ]] && camel_ends+=( $(( i - 1 )) )
    done
}
camel-forward-word() {
    local -a camel_starts camel_ends; _camel_parts; local -i p
    for p in $camel_starts; do (( p > CURSOR )) && { CURSOR=$p; return }; done
    CURSOR=${#BUFFER}
}
camel-backward-word() {
    local -a camel_starts camel_ends; _camel_parts; local -i p
    for p in ${(Oa)camel_starts}; do (( p < CURSOR )) && { CURSOR=$p; return }; done
    CURSOR=0
}
camel-forward-end() {
    local -a camel_starts camel_ends; _camel_parts; local -i p
    for p in $camel_ends; do (( p > CURSOR )) && { CURSOR=$p; return }; done
}
zle -N camel-forward-word
zle -N camel-backward-word
zle -N camel-forward-end

# Key bindings for the Sneak and camelCase widgets above (AI-generated).
# zsh-vi-mode sets up its keymaps lazily (ZVM_LAZY_KEYBINDINGS, default on)
# and would overwrite plain bindkey calls made here, so the bindings are
# queued to run right after it finishes. "visual" is zsh-vi-mode's keymap.
zvm_after_lazy_keybindings_commands+=(
    'bindkey -M vicmd s sneak-forward'
    'bindkey -M vicmd S sneak-backward'
    # Two-key sequences must use zvm_bindkey: zsh-vi-mode's default "NEX"
    # readkey engine sets KEYTIMEOUT=1 (10ms), so with plain bindkey zsh
    # gives up on " w" before you can type the w, and space just moves right.
    'zvm_bindkey vicmd " w" camel-forward-word'
    'zvm_bindkey vicmd " b" camel-backward-word'
    'zvm_bindkey vicmd " e" camel-forward-end'
    'zvm_bindkey visual " w" camel-forward-word'
    'zvm_bindkey visual " b" camel-backward-word'
    'zvm_bindkey visual " e" camel-forward-end'
)


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
    
    if [[ -n "$DISPLAY" ]] && command -v setxkbmap >/dev/null; then
        setxkbmap -option caps:swapescape
    fi
fi

# ╭─ General
alias ls='ls --color=auto'
alias notify="notify-send"
alias less='less -N'
alias vim='nvim'
alias vi='nvim'
alias zshconf='$EDITOR ~/.zshrc'
alias vimconf='$EDITOR ~/.config/nvim/init.lua'
alias nvimconf='$EDITOR ~/.config/nvim/init.lua'
alias fix="eval $(ssh-agent -s)"

# ╭─ System Management
alias syncdotfiles='stow --target=$HOME --adopt --dir ~/unix-dotfiles home-config && ~/Scripts/detect_env.sh'

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
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# ╭─ Machine Local Overrides
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local


# Added by Antigravity CLI installer
export PATH="/home/tym/.local/bin:$PATH"
