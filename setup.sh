#!/bin/sh

# General variables
is_macos=0
if [ "$(uname)" == "Darwin" ]; then
    is_macos=1
fi

app_check_list=(fzf fd zoxide rg bat)
if ((is_macos)); then
    app_check_list+=("brew")
fi

force=0
clone=0
install_desktop_apps=0
install_utilities=0

# Parse arguments
while :; do
    case $1 in
        -f|--force)
            force=1
            shift
            ;;
        -c|--clone)
            clone=1
            shift
            ;;
        --desktop)
            install_desktop_apps=1
            shift
            ;;
        --utilities)
            install_utilities=1
            shift
            ;;
        -a|--all)
            install_desktop_apps=1
            install_utilities=1
            shift
            ;;
        *)
            break
    esac
done

# Clone the repo
__clone_repo() {
    if ! ((clone)); then
        return
    fi

    echo "Cloning the repo..."
    repo_https_url="https://github.com/dermoumi/dotfiles.git"
    repo_ssh_url="git@github.com:dermoumi/dotfiles.git"
    dotfiles_dir="$HOME/.dotfiles"

    git clone "$repo_https_url" "$dotfiles_dir"
    cd "$dotfiles_dir"
    git remote set-url origin "$repo_ssh_url"
}

# Utility to link source to target
__mk_link() {
    local source=$1
    local target_dir=$2

    local target=$target_dir$(basename $source)
    if [ -e "$target" ] && ! ((force)); then
        echo "$target already exists. Use --force to overwrite"
        return
    fi

    # Make sure the target directory exists
    mkdir -p "$target_dir"

    echo "Linking $source to $target"
    ln -Ffs "$PWD/$source" "$target_dir"
}

__make_links() {
    echo "Linking files..."
    __mk_link zsh/.zshenv ~/
    __mk_link .gitconfig ~/
    __mk_link .fdignore ~/
    __mk_link .tmux.conf ~/
    __mk_link wezterm ~/.config/
    __mk_link nvim ~/.config/

    # MacOS specific links
    if ((is_macos)); then
        __mk_link karabiner ~/.config/
    fi
}

# Checks if the given app is installed
__check_app_installed() {
    local app=$1
    command -v $app &>/dev/null
}

__ensure_homebrew_installed() {
    if __check_app_installed brew; then
        return
    fi

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add the newly created bin directory to path
    if [ -d /opt/homebrew/bin ]; then
        export PATH="/opt/homebrew/bin:$PATH"
    fi
}

# Install utilities
__install_utilities_macos() {
    __ensure_homebrew_installed

    # Install apps
    brew install fzf fd zoxide ripgrep bat neovim tmux volta pyenv \
        pyenv-virtualenv eza gnupg xz switchaudio-osx

    # Setup volta
    export VOLTA_HOME=$HOME/.volta
    export PATH="$VOLTA_HOME/bin:$PATH"

    volta install node pnpm

    # Setup pyenv
    export PYENV_ROOT=$HOME/.pyenv
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"

    pyenv install -s 3
    pyenv global 3
    pip install -U pip neovim-remote
    pyenv virtualenv nvim
    pyenv activate nvim
    pip install -U pip neovim
    pyenv deactivate
}

__install_utilities() {
    if ! ((install_utilities)); then
        return
    fi

    echo "Installing utilities..."
    if ((is_macos)); then
        __install_utilities_macos
    else
        echo "Unsupported OS. Skipping..."
    fi
}

__install_desktop_apps_macos() {
    __ensure_homebrew_installed

    brew install --cask android-platform-tools battery chatgpt discord docker \
        firefox google-chrome iina jordanbaird-ice karabiner-elements \
        keepingyouawake keka launchbar nightfall rectangle spotify topnotch \
        transmission visual-studio-code wezterm windscribe \
        font-jetbrains-mono-nerd-font monitorcontrol prismlauncher

    # Run windscribe installer if it's not installed
    if ! [ -d /Users/$(whoami)/Library/Application\ Support/Windscribe/ ]; then
        open /opt/homebrew/Caskroom/windscribe/*/WindscribeInstaller.app
    fi
}

__install_desktop_apps() {
    if ! ((install_desktop_apps)); then
        return
    fi

    echo "Installing desktop apps..."
    if ((is_macos)); then
        __install_desktop_apps_macos
    else
        echo "Unsupported OS. Skipping..."
    fi
}

__restart_zsh() {
    echo "Restarting zsh..."
    if [ "$ZSH_EXECUTION_STRING" ]; then
        ((failed)) || exec zsh -c "$ZSH_EXECUTION_STRING"
    else
        exec zsh
    fi
}

__clone_repo
__make_links
__install_utilities
__install_desktop_apps
__restart_zsh
