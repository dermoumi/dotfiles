#!/bin/zsh

# enable Powerlevel10k instant prompt.
# should stay as close to the top of ~/.dotfiles/zsh/.zshrc as possible
#
# initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# profiling
# zmodload zsh/zprof

# zsh options
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.cache/zsh_history

setopt hist_ignore_all_dups hist_find_no_dups append_history share_history \
  incappendhistory auto_cd extended_glob no_match notify magic_equal_subst

# setup function autoload
autoload -Uz "$ZDOTDIR/functions/"*

# setup sshagent
sshagent-init --auto

# disable marking untracked files on git as dirty.
# makes git status much faster on large repositories
export DISABLE_UNTRACKED_FILES_DIRTY="true"

# homebrew
if [[ -d /opt/homebrew/sbin ]]; then
    path=(/opt/homebrew/sbin $path)
fi
if [[ -d /opt/homebrew/bin ]]; then
    path=(/opt/homebrew/bin $path)
fi

# go
if [[ -d ~/.local/go/bin && ! "$GOPATH" ]]; then
    export GOPATH=$HOME/.local/go
    path=($GOPATH/bin $path)
fi

# android sdk
if [[ ! "$ANDROID_HOME" ]]; then
    if [[ -d ~/Library/Android/Sdk ]]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
    elif [[ -d ~/.android/sdk ]]; then
        export ANDROID_HOME="$HOME/.android/sdk"
    elif [[ -d /opt/android-sdk ]]; then
        export ANDROID_HOME="/opt/android-sdk"
    fi
fi

if [[ "$ANDROID_HOME" ]]; then
    export ANDROID_SDK_ROOT=$ANDROID_HOME
    path=($ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools $ANDROID_HOME/emulator $path)
fi

if [[ -d "/opt/homebrew/share/android-ndk" ]]; then
  export ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
  export NDK_HOME=$ANDROID_NDK
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
    path=($VOLTA_HOME/bin $path)

    export PNPM_HOME="$(dirname "$(dirname "$(which npm)")")/bin"
    path=($PNPM_HOME $path)
elif [[ -d ~/.local/share/pnpm ]]; then
    export PNPM_HOME="$HOME/.local/share/pnpm"
    path=($PNPM_HOME $path)
elif [[ -d ~/Library/pnpm ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
    path=($PNPM_HOME $path)
fi

# pyenv
if [[ -d ~/.pyenv && ! ("$PYENV_ROOT" && -d "$PYENV_ROOT") ]]; then
    export PYENV_ROOT=~/.pyenv
    path=($PYENV_ROOT/bin $path)
fi

# poetry
if [[ -d ~/.poetry && ! ("$POETRY_ROOT" && -d "$POETRY_ROOT") ]]; then
    export POETRY_ROOT=~/.poetry
    path=($POETRY_ROOT/bin $path)
fi

# powerlevel10k
if [[ -f "$ZDOTDIR/p10k.zsh" ]]; then
    source "$ZDOTDIR/p10k.zsh"
fi

# load configuration for interactive mode
if [[ -o interactive ]]; then
    source "$ZDOTDIR/interactive"
fi
