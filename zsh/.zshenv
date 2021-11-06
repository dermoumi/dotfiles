#!/bin/zsh

#
# General env vars
#

# import local env if any
[[ -f ~/.env.local ]] && source ~/.env.local

# Change the default zsh root
: ${ZDOTDIR:=~/.dotfiles/zsh}

# Setup function autoload
autoload -Uz "$ZDOTDIR/functions/"*

# default language to avoid unicode issues
[[ "$LC_ALL" ]] || export LC_ALL="en_US.UTF-8"
[[ "$LANG" ]] || export LANG=$LC_ALL

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

# brew
if [[ -d /opt/homebrew/bin ]]; then
    path=(/opt/homebrew/bin $path)
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

# fnm
if command -v fnm &>/dev/null; then
    eval "$(fnm env)"
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
fi

# fzf
if ! [[ "$FZF_HOME" && -d "$FZF_HOME" ]]; then
    export FZF_HOME="$ZDOTDIR/fzf"
    path=("$FZF_HOME/bin" $path)
fi

# local scripts directory
if [[ -d ~/.dotfiles/scripts/ ]]; then
    export SCRIPTS_DIR=$HOME/.dotfiles/scripts/
    path=($SCRIPTS_DIR $path)
fi

# local bin directory
if [[ -d ~/.local/bin && ! "$LOCAL_BIN_DIR" ]]; then
    export LOCAL_BIN_DIR=$HOME/.local/bin
    path=($LOCAL_BIN_DIR $path)
fi

# includes path
if [[ -d ~/.local/include ]]; then
    export CPATH="$HOME/.local/include:$CPATH"
    export C_INCLUDE_PATH="$HOME/.local/include:$C_INCLUDE_PATH"
    export CPLUS_INCLUDE_PATH="$HOME/.local/include:$CPLUS_INCLUDE_PATH"
fi

# libraries path
if [[ -d ~/.local/lib ]]; then
    export LIBRARY_PATH="$HOME/.local/lib:$LIBRARY_PATH"
    export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
fi

#
# Tool config
#

# remove pipenv notice that it's running inside an existing virtualenv
export PIPENV_VERBOSITY=-1

# disable marking untracked files on git as dirty.
# makes git status much faster on large repositories
export DISABLE_UNTRACKED_FILES_DIRTY="true"

# activate right virtual env when python binary is ran through zsh
if [[ -n "$VIRTUAL_ENV" && -e "$VIRTUAL_ENV/bin/activate" ]]; then
    source "$VIRTUAL_ENV/bin/activate"
fi

# dotfiles utility
export DOTFILES_REPO_PATH=~/.dotfiles

# Setup sshagent
sshagent-init --auto

#
# Aliases
#

# small utility to test colors
alias colortest="curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/ | bash"

# ls aliases
if [[ "$OSTYPE" =~ darwin.+ ]]; then
    alias ls="ls -G"
    alias ll="ls -lh"
    alias la="ls -a"
    alias lla="ll -a"
else
    alias ls="ls --color=auto"
    alias ll="ls -lh"
    alias la="ls --almost-all"
    alias lla="ll --almost-all"
fi

# color aliases
alias diff="diff --color=auto"
alias grep="grep --color=auto"
alias ip="ip --color=auto"
alias dmesg="dmesg --color=auto"

# make sure paths don't contain duplicates
typeset -gU cdpath fpath mailpath path
