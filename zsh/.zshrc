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

env-check

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.dotfiles/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Force 256-color mode when inside containers
if grep -sq 'docker\|lxc' /proc/1/cgroup; then
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

# additional zsh autocompletion
if [[ -d "$ZDOTDIR/zsh-completions/src" ]]; then
    fpath=("$ZDOTDIR/zsh-completions/src" $fpath)
fi

# custom functions and completions
fpath=(
    "$ZDOTDIR/functions"
    "$ZDOTDIR/completions"
    $fpath
)

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

# Import powerlevel10k
source "$ZDOTDIR/p10k/powerlevel10k.zsh-theme"
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
if ! less --mouse |& grep "There is no" &>/dev/null; then
    LESS+=" --mouse --wheel-lines=4"
fi

# A couple of keybindings and color config for less
# Requires a fairly recent version of less
export LESSKEYIN="$HOME/.dotfiles/.lesskey"

# bat
export BAT_STYLE="changes,snip"

# pyenv
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

# fzf
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

source "$FZF_HOME/shell/completion.zsh" 2>/dev/null
source "$FZF_HOME/shell/key-bindings.zsh"

# reconfigure preview options whenever the terminal resizes
trap reconfigure_fzf_preview SIGWINCH
# set initial fzf preview window options
reconfigure_fzf_preview

# fish-like abbreviations
ABBR_USER_ABBREVIATIONS_FILE="$ZDOTDIR/abbreviations"
ABBR_AUTOLOAD=0
ABBR_PRECMD_LOGS=0
ABBR_DEFAULT_BINDINGS=0
source "$ZDOTDIR/zsh-abbr/zsh-abbr.zsh"
bindkey " " _abbr_widget_expand_and_space # space to expand abbr
bindkey "^ " magic-space # ctrl+space to insert normal space
bindkey -M isearch " " magic-space # normal space is normal in incremental search
bindkey -M isearch "^ " _abbr_widget_expand_and_space # ctrl+space expands abbr in isearch

_expand_abbr_and_accept() {
    emulate -LR zsh

    # make sure the rbuffer doesn't start with a space
    if [[ ! "$RBUFFER" || "$RBUFFER" =~ ^[[:space:]].+ ]]; then
        _abbr_widget_expand_and_accept
    else
        builtin command -v _zsh_autosuggest_clear &>/dev/null && _zsh_autosuggest_clear
        zle accept-line
    fi
}
zle -N _expand_abbr_and_accept
bindkey "^M" _expand_abbr_and_accept

# fish-like syntax highlighting
# must stay at the bottom
source "$ZDOTDIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# fish-like history navigation
# must come AFTER syntax highlighting
source "$ZDOTDIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=underline
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND=fg=8,underline
HISTORY_SUBSTRING_SEARCH_FUZZY=1
bindkey '^[[A' history-substring-search-up # up
bindkey '^[OA' history-substring-search-up
bindkey '^[[B' history-substring-search-down # down
bindkey '^[OB' history-substring-search-down
