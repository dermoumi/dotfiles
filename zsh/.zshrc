#!/bin/zsh

# Profiling
# zmodload zsh/zprof

# Automatically start tmux if AUTO_TMUX is set
if ((AUTO_TMUX)) && [[ -o interactive && ! "$TMUX" ]]; then
    tmux start-server

    if tmux has-session &>/dev/null; then
        exec tmux attach
    else
        exec tmux new -s main
    fi
fi

# homebrew
if [[ -d /opt/homebrew/bin ]]; then
    path=(/opt/homebrew/bin $path)
fi

# Check for missing required tools in the env, and install them
env-check

# Load zinit the plugin manager
if [[ ! -d "$ZINIT_HOME" ]]; then
    ZINIT_HOME="$(dirname "$ZINIT_HOME")" \
    NO_EMOJI=1 \
    NO_INPUT=1 \
    NO_TUTORIAL=1 \
    NO_ANNEXES=1 \
    NO_EDIT=1 \
    sh -c "$(curl -fsSL https://git.io/zinit-install)"
fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# linuxbrew
if [[ -d ~/.linuxbrew ]]; then
    eval "$(~/.linuxbrew/bin/brew shellenv)"
fi
if [[ -d /home/linuxbrew/.linuxbrew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# go
if [[ -d ~/.local/go/bin && ! "$GOPATH" ]]; then
    export GOPATH=$HOME/.local/go
    path=($GOPATH/bin $path)
fi

# pyenv
if [[ -d ~/.pyenv && ! ("$PYENV_ROOT" && -d "$PYENV_ROOT") ]]; then
    export PYENV_ROOT=~/.pyenv
    path=($PYENV_ROOT/bin $path)
fi
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init --path)"
fi

# poetry
if [[ -d ~/.poetry && ! ("$POETRY_ROOT" && -d "$POETRY_ROOT") ]]; then
    export POETRY_ROOT=~/.poetry
    path=($POETRY_ROOT/bin $path)
fi

# cargo
if [[ -d ~/.cargo && ! "$CARGO_HOME" ]]; then
    export CARGO_HOME=$HOME/.cargo
    path=($CARGO_HOME/bin $path)

    if [[ -e "$CARGO_HOME/env" ]]; then
        source "$CARGO_HOME/env"
    fi
fi

# volta
if [[ -d ~/.volta ]]; then
    export VOLTA_HOME=$HOME/.volta
    export PNPM_HOME=$(npm bin -g 2>/dev/null)
    path=($VOLTA_HOME/bin $PNPM_HOME $path)
elif [[ -d ~/.local/share/pnpm ]]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    path=($PNPM_HOME $path)
elif [[ -d ~/Library/pnpm ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
    path=($PNPM_HOME $path)
fi

# android sdk
if [[ -d ~/Library/Android/Sdk ]]; then
    export ANDROID_HOME="$HOME/Library/Android/sdk"
elif [[ -d ~/.android/sdk ]]; then
    export ANDROID_HOME="$HOME/.android/sdk"
elif [[ -d /opt/android-sdk ]]; then
    export ANDROID_HOME="/opt/android-sdk"
fi

if [[ "$ANDROID_HOME" ]]; then
    export ANDROID_SDK_ROOT=$ANDROID_HOME
    path=($ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/emulator $path)
fi

# SDK man
if [[ -d ~/.sdkman ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"

    if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
    fi
fi

# Force 256-color mode when inside containers
if grep -sq "docker\|lxc" /proc/1/cgroup; then
  export TERM=xterm-256color
fi

# zsh options
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.cache/zsh_history

setopt hist_ignore_all_dups hist_find_no_dups append_history share_history \
  incappendhistory auto_cd extended_glob no_match notify magic_equal_subst

# keybindings
source "$ZDOTDIR/keybindings"

if [[ -o interactive ]]; then
    # some alias for when in interactive mode
    if command -v exa &>/dev/null; then
        alias ls=exa
        alias lt='ll --tree'
    fi

    if command -v bat &>/dev/null; then
        alias cat=bat
    fi
fi

# custom functions and completions
fpath=(
    "$ZDOTDIR/functions"
    "$ZDOTDIR/completions"
    $fpath
)

source "$ZINIT_HOME/zinit.zsh"

# use modern completion system
autoload -Uz compinit
# Only run compinit when the .zcompdump is older than 24h
# needs extended_glob to be enabled
for dump in "$ZDOTDIR"/.zcompdump(N.mh+24); do
  compinit -i
done
compinit -C

zstyle ':completion:*' use-compctl false
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' format $'%{\e[36m%}…%d%{\e[0m%}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b)"
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
    zstyle ':completion:*:default' list-colors ''
fi
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' verbose true

# Completions for the kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ssht is a function that automatically spawns tmux on remote machines
compdef ssht=ssh

# Import powerlevel10k
[[ ! -f "$ZDOTDIR/p10k.zsh" ]] || source "$ZDOTDIR/p10k.zsh"

# zoxide
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# less
export LESS=" \
    --quit-if-one-screen \
    --ignore-case \
    --status-column \
    --LONG-PROMPT \
    --RAW-CONTROL-CHARS \
    --HILITE-UNREAD \
    --tabs=4 \
    --no-init \
    --window=-4 \
"

# less mouse support in versions that support it
# if ! less --mouse | grep "There is no" &>/dev/null; then
#     LESS+=" --mouse --wheel-lines=4"
# fi

# A couple of keybindings and color config for less
# Requires a fairly recent version of less
export LESSKEYIN="$HOME/.dotfiles/.lesskey"

# bat
export BAT_STYLE="snip"

# pyenv
if command -v pyenv &>/dev/null; then
    eval "$(pyenv virtualenv-init -)"
fi

# Fish-like abbreviations, aliases that auto-expand when pressing space
init_abbr() {
    ABBR_USER_ABBREVIATIONS_FILE="$ZDOTDIR/abbreviations"
    ABBR_AUTOLOAD=0
    ABBR_PRECMD_LOGS=0
    ABBR_DEFAULT_BINDINGS=0
    bindkey " " _abbr_widget_expand_and_space # space to expand abbr
    bindkey "^ " magic-space # ctrl+space to insert space without expanding abbr
    bindkey -M isearch " " magic-space # normal space is normal in incremental search
    bindkey -M isearch "^ " _abbr_widget_expand_and_space # ctrl+space expands abbr in isearch

    # Allows abbreviation to be expanded on enter if they're the only command to execute
    _expand_abbr_and_accept() {
        emulate -LR zsh

        # make sure the rbuffer doesn't start with a space
        if [[ ! "$RBUFFER" || "$RBUFFER" =~ ^[[:space:]].+ ]]; then
            _abbr_widget_expand_and_accept
        else
            zle accept-line
        fi
    }
    zle -N _expand_abbr_and_accept
    bindkey "^M" _expand_abbr_and_accept
}
zinit ice depth=1 atinit=init_abbr
zinit light "olets/zsh-abbr"

# Fish like substring search
init_substring_search() {
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=underline
    HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=fg=8,underline
    HISTORY_SUBSTRING_SEARCH_FUZZY=1
    bindkey '^[[A' history-substring-search-up # up
    bindkey '^[OA' history-substring-search-up
    bindkey '^[[B' history-substring-search-down # down
    bindkey '^[OB' history-substring-search-down
}
zinit ice depth=1 atinit=init_substring_search
zinit light "zsh-users/zsh-history-substring-search"

# Some useful completions
zinit ice depth=1
zinit light "zsh-users/zsh-completions"

# Fast syntax highlighting
zinit ice depth=1
zinit light "zdharma-continuum/fast-syntax-highlighting"

# Powerlevel10k theme
zinit ice depth=1
zinit light "romkatv/powerlevel10k"

# FZF
init_fzf() {
    export FZF_DEFAULT_COMMAND="fd --type f --type l --color=never --no-ignore-vcs --hidden"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd --type d --color=never --no-ignore-vcs --hidden"

    # configure the preview window
    reconfigure_fzf_preview() {
        local fzf_default_ops_base="
            --ansi
            --cycle
            --reverse
            --info=inline
            --height=30%
            --border=rounded
            --preview='preview {}'
            --pointer=·
            --marker=→
            --color=fg:246,fg+:4,bg+:0,gutter:16,pointer:14,info:2,header:11,hl:7,hl+:7
            --bind='ctrl-space:toggle-down'
            --bind='ctrl-/:toggle-preview'
            --bind='ctrl-o:execute-silent(code {} &)'
            --bind='ctrl-p:execute-silent(code {} &)+abort'
            --bind='ctrl-k:preview-up+preview-up+preview-up+preview-up+preview-up'
            --bind='ctrl-j:preview-down+preview-down+preview-down+preview-down+preview-down'
            --bind='ctrl-r:toggle-all'
            --bind='ctrl-s:toggle-sort'
            --bind='ctrl-w:toggle-preview-wrap'
            --bind='home:first'
            --bind='end:last'
        "
        local fzf_ctrl_t_ops_base="--no-height --no-border"
        local fzf_alt_c_ops_base="--no-height --no-border"

        # sets fzf preview position and status (no/hidden) depending on terminal size
        local hide_threshold_columns=74
        local hide_threshold_lines=36
        local lines_factor=2.3 # assume that a cell is n times a tall as it wide

        local preview_window="default"
        local nohidden=",nohidden"

        if ((COLUMNS > LINES * lines_factor)); then   # screen is wider than it is tall
            preview_window="right,50%,border-left"

            # force hide the preview window if the screen is not wide enough
            if ((COLUMNS < hide_threshold_columns)); then
                nohidden=",hidden"
            fi
        else # screen is taller than it is wide
            preview_window="bottom,50%,border-top"

            # force hide the preview window if the screen is not tall enough
            if ((LINES < hide_threshold_lines)); then
                nohidden=",hidden"
            fi
        fi

        export FZF_DEFAULT_OPTS="$fzf_default_ops_base --preview-window=${preview_window},hidden"
        export FZF_CTRL_T_OPTS="$fzf_ctrl_t_ops_base --preview-window=${preview_window}${nohidden}"
        export FZF_ALT_C_OPTS="$fzf_alt_c_ops_base --preview-window=${preview_window}${nohidden}"
    }

    # reconfigure preview options whenever the terminal resizes
    trap reconfigure_fzf_preview SIGWINCH
    # set initial fzf preview window options
    reconfigure_fzf_preview

    zinit run junegunn/fzf source shell/completion.zsh 2>/dev/null
    zinit run junegunn/fzf source shell/key-bindings.zsh
}
zinit ice depth=1 atinit=init_fzf
zinit light "junegunn/fzf"

# Forgit
zinit ice depth=1
zinit light "wfxr/forgit"
