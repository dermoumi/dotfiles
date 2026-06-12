#!/bin/zsh

# import local env if any
if [[ -f ~/.env.local ]]; then
    source ~/.env.local
fi

# change the default zsh root
: ${ZDOTDIR:=~/.dotfiles/zsh}

# SSH agent
if [ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
elif [ -S "$HOME/.bitwarden-ssh-agent.sock" ]; then
    export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
elif [ -S "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket" ]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"
fi

# homebrew
if [[ -d /opt/homebrew/bin ]]; then
    export HOMEBREW_NO_ENV_HINTS=1
    path=(/opt/homebrew/bin $path)
fi
if [[ -d /opt/homebrew/sbin ]]; then
    path=(/opt/homebrew/sbin $path)
fi

# local scripts directory
if [ ! "$SCRIPTS_DIR" ] && [ -d ~/.dotfiles/scripts/ ]; then
    export SCRIPTS_DIR=$HOME/.dotfiles/scripts/
    path=($SCRIPTS_DIR $path)
fi

# local bin directory
if  [ ! "$LOCAL_BIN_DIR" ] && [ -d ~/.local/bin ]; then
    export LOCAL_BIN_DIR=$HOME/.local/bin
    path=($LOCAL_BIN_DIR $path)
fi

# includes path
if [ ! "$LOCAL_INCLUDE_PATH" ] && [ -d ~/.local/include ]; then
    export LOCAL_INCLUDE_PATH=$HOME/.local/include
    export CPATH="$LOCAL_INCLUDE_PATH${CPATH:+:$CPATH}"
    export C_INCLUDE_PATH="$LOCAL_INCLUDE_PATH${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
    export CPLUS_INCLUDE_PATH="$LOCAL_INCLUDE_PATH${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
fi

# libraries path
if [ ! "$LOCAL_LIB_PATH" ] && [ -d ~/.local/lib ]; then
    export LOCAL_LIB_PATH=$HOME/.local/lib
    export LIBRARY_PATH="$LOCAL_LIB_PATH${LIBRARY_PATH:+:$LIBRARY_PATH}"
    export LD_LIBRARY_PATH="$LOCAL_LIB_PATH${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

# make sure paths don't contain duplicates
typeset -gU cdpath fpath mailpath path
