#!/bin/zsh

# import local env if any
if [[ -f ~/.env.local ]]; then
    source ~/.env.local
fi

# change the default zsh root
: ${ZDOTDIR:=~/.dotfiles/zsh}

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
    export CPATH="$LOCAL_INCLUDE_PATH:$CPATH"
    export C_INCLUDE_PATH="$LOCAL_INCLUDE_PATH:$C_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH="$LOCAL_INCLUDE_PATH:$CPLUS_INCLUDE_PATH"
fi

# libraries path
if [ ! "$LOCAL_LIB_PATH" ] && [ -d ~/.local/lib ]; then
    export LOCAL_LIB_PATH=$HOME/.local/lib
    export LIBRARY_PATH="$LOCAL_LIB_PATH:$LIBRARY_PATH"
    export LD_LIBRARY_PATH="$LOCAL_LIB_PATH:$LD_LIBRARY_PATH"
fi

# default editor
if [[ ! "$EDITOR" ]]; then
    if command -v nvim &>/dev/null; then
        export EDITOR=nvim
    elif command -v vim &>/dev/null; then
        export EDITOR=vim
    elif command -v nano &>/dev/null; then
        export EDITOR=nano
    fi
fi

# make sure paths don't contain duplicates
typeset -gU cdpath fpath mailpath path
