#!/bin/bash

# Abort on error
set -euo pipefail
# Allow empty glob matches
shopt -s nullglob

# General variables
is_macos=0
if [ "$(uname)" == "Darwin" ]; then
    is_macos=1
fi

app_check_list=(fzf fd zoxide rg bat)
if ((is_macos)); then
    app_check_list+=("brew")
fi

bin_path="$HOME/.local/bin"
man_path="$HOME/.local/man"
mkdir -p "$bin_path" "$man_path"
export PATH="$bin_path:$PATH"

link=0
force=0
clone=0
install_desktop_apps=0
install_utilities=0
no_python=0
no_node=0
chsh=0

# Parse arguments
while :; do
    case ${1-} in
        --cli)
            link=1
            clone=1
            install_utilities=1
            shift
            ;;
        --desktop)
            link=1
            clone=1
            install_utilities=1
            install_desktop_apps=1
            shift
            ;;
        -l|--link)
            link=1
            shift
            ;;
        -f|--force)
            force=1
            shift
            ;;
        -c|--clone)
            clone=1
            shift
            ;;
        -d|--desktop)
            install_desktop_apps=1
            shift
            ;;
        -u|--utilities)
            install_utilities=1
            shift
            ;;
        -a|--all)
            install_desktop_apps=1
            install_utilities=1
            shift
            ;;
        --no-python)
            no_python=1
            shift
            ;;
        --no-node)
            no_node=1
            shift
            ;;
        --chsh)
            chsh=1
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
    if ! ((link)); then
        return
    fi

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
        __mk_link yabai ~/.config/
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
    brew install fzf fd zoxide ripgrep bat neovim tmux \
        pyenv-virtualenv eza gnupg xz switchaudio-osx

    # Setup volta
    if ! ((no_node)); then
        brew install volta

        export VOLTA_HOME=$HOME/.volta
        export PATH="$VOLTA_HOME/bin:$PATH"

        volta install node pnpm
    fi

    # Setup pyenv
    if ! ((no_python)); then
        brew install pyenv

        export PYENV_ROOT=$HOME/.pyenv
        export PATH="$PYENV_ROOT/bin:$PATH"

        eval "$(pyenv init --path)"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"

        pyenv install -s 3
        pyenv global 3
        pip install -U pip
    fi

    # Setup nvim python provider
    if __check_app_installed pip; then
        pip install -U neovim-remote
    fi

    if __check_app_installed pyenv-virtualenv; then
        pyenv virtualenv nvim
        pyenv activate nvim
        pip install -U pip neovim
        pyenv deactivate
    fi
}

repo_releases_cache=""
repo_releases_key=""
__grep_repo_releases() {
    local repo=${1-}
    local pattern=${2-}

    if [ "$repo_releases_key" != "$repo" ]; then
        repo_releases_cache=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest")
        repo_releases_key=$repo
    fi

    echo "$repo_releases_cache" | grep -oP "$pattern" | head -n1
}

__get_latest_url() {
    local repo=${1-}
    local pattern=${2-}

    __grep_repo_releases "$repo" "https://.+/$pattern"
}

__download_extract() {
    local url=${1-}

    if [[ "$url" =~ \.tar\.gz$ ]]; then
        curl -fsSL $url | tar -xz
    elif [[ "$url" =~ \.zip$ ]]; then
        curl -fsSL $url -o "__tmp.zip"
        unzip -o __tmp.zip
        rm __tmp.zip
    elif [[ "$url" =~ \.appimage$ ]]; then
        curl -OfsSL $url
    else
        echo "Unsupported archive format" >&2
    fi
}

__install_gh_release() {
    local name=$1
    local repo=$2
    local current_version_pattern=$3
    local latest_version_pattern=$4
    local linux_aarch64_pattern=$5
    local linux_amd64_pattern=$6
    local bin=${7-$name}
    local extracted_bin=${8-$bin}

    echo "Installing $name..."

    if __check_app_installed $bin; then
        local current=$($bin --version | grep -oP "$current_version_pattern" | head -n1)
        local latest=$(__grep_repo_releases "$repo" "$latest_version_pattern")

        if [ "$current" == "$latest" ]; then
            echo "$name is already up to date"
            return
        fi

        echo "Updating $name from '$current' to '$latest'"
    fi

    (
        local tmp_dir=$(mktemp -d)
        pushd $tmp_dir &>/dev/null

        local pattern
        local arch=$(uname -sm)
        case "$arch" in
            Linux\ aarch64*) pattern=$linux_aarch64_pattern;;
            Linux\ *64) pattern=$linux_amd64_pattern;;
            *)
                echo "Unsupported architecture: $arch" >&2
                return 1
        esac

        local url=$(__get_latest_url "$repo" "$pattern")
        echo "Downloading $name from $url"
        __download_extract "$url"

        # Hop into the extracted directory if any
        local subdir=$(find . -maxdepth 1 -type d ! -name ".*" | head -n1)
        if [ "$subdir" ]; then
            cd "$subdir"
        fi

        # Select the .appimage if any
        if ! [ -f $extracted_bin ]; then
            extracted_bin=$(find . -maxdepth 1 -type f -iname "*.AppImage" | head -n1)
        fi

        if [ "$extracted_bin" ] && [ -f $extracted_bin ]; then
            chmod +x $extracted_bin
            mv $extracted_bin "$bin_path/$bin"
        else
            echo "Failed to download $name" >&2
            return 1
        fi

        popd &>/dev/null
        rm -rf $tmp_dir
    )
}

__install_utilities_aptget() {
    sudo apt-get update

    libfuse2_name=$(apt-cache search libfuse2 | awk '{print $1}')
    if [[ -z "$libfuse2_name" ]]; then
        echo "Failed to find libfuse2 package" >&2
        return 1
    fi

    sudo apt-get install -y zsh git curl unzip tmux build-essential \
        gnupg "$libfuse2_name" \
        libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

    local fail=()

    # volta
    if ! ((no_node)); then
        (
            export VOLTA_HOME=$HOME/.volta
            export PATH="$VOLTA_HOME/bin:$PATH"

            if ! __check_app_installed volta; then
                bash -c "$(curl https://get.volta.sh)" || fail=1
            fi

            volta install node pnpm
        ) || fail+=(volta)
    fi

    # pyenv
    if ! ((no_python)); then
        (
            export PYENV_ROOT=$HOME/.pyenv
            export PATH="$PYENV_ROOT/bin:$PATH"

            if ! __check_app_installed pyenv; then
                curl -fsSL https://pyenv.run | bash || fail=1
            fi

            if ! [ -d $PYENV_ROOT/plugins/pyenv-virtualenv ]; then
                git clone https://github.com/pyenv/pyenv-virtualenv.git \
                    $PYENV_ROOT/plugins/pyenv-virtualenv
            fi

            eval "$(pyenv init -)"
            eval "$(pyenv virtualenv-init -)"

            pyenv install -s 3
            pyenv global 3
            pip install -U pip
        ) || fail+=(pyenv)
    fi

    # fzf
    __install_gh_release fzf \
        junegunn/fzf \
        "^[^\s]+" \
        '(?<="name": ")(.+)(?=\",$)' \
        "fzf-[^-]+-linux_arm64\.tar\.gz" \
        "fzf-[^-]+-linux_amd64\.tar\.gz" || fail+=(fzf)

    # fd
    __install_gh_release fd \
        sharkdp/fd \
        "[^\s]+$" \
        '(?<="name": "v)(.+)(?=\",$)' \
        "fd-[^-]+-arm-unknown-linux-musleabihf\.tar\.gz" \
        "fd-[^-]+-x86_64-unknown-linux-musl\.tar\.gz" || fail+=(fd)

    # zoxide
    __install_gh_release zoxide \
        ajeetdsouza/zoxide \
        "[^\s]+$" \
        '(?<="name": ")(.+)(?=\",$)' \
        "zoxide(-.+)?-aarch64-unknown-linux-musl\.tar\.gz" \
        "zoxide(-.+)?-x86_64-unknown-linux-musl\.tar\.gz" || fail+=(zoxide)

    # ripgrep
    __install_gh_release ripgrep \
        BurntSushi/ripgrep \
        "(?<=ripgrep\s)[^\s]+" \
        '(?<="name": ")(.+)(?=\",$)' \
        "ripgrep-[^-]+-aarch64-unknown-linux-gnu\.tar\.gz" \
        "ripgrep-[^-]+-x86_64-unknown-linux-musl\.tar\.gz" \
        rg || fail+=(rg)

    # bat
    __install_gh_release bat \
        sharkdp/bat \
        "(?<=bat\s)[^\s]+" \
        '(?<="name": "v)(.+)(?=\",$)' \
        "bat-[^-]+-aarch64-unknown-linux-gnu\.tar\.gz" \
        "bat-[^-]+-x86_64-unknown-linux-musl\.tar\.gz" || fail+=(bat)

    # eza
    __install_gh_release eza \
        eza-community/eza \
        "^v[\d\.]+" \
        '(?<="name": "eza )(.+)(?=\",$)' \
        "eza_aarch64-unknown-linux-gnu.tar.gz" \
        "eza_x86_64-unknown-linux-musl.tar.gz" || fail+=(eza)

    # neovim
    __install_gh_release neovim \
        neovim/neovim \
        "[^\s]+$" \
        '(?<="name": "Nvim )(.+)(?=\",$)' \
        "nvim-linux-arm64.appimage" \
        "nvim-linux-x86_64.appimage" \
        nvim || fail+=(neovim)

    if __check_app_installed pip; then
        pip install -U neovim-remote || fail+=(neovim-remote)
    fi

    if __check_app_installed pyenv-virtualenv; then
        (
            pyenv virtualenv nvim
            pyenv activate nvim
            pip install -U pip neovim
            pyenv deactivate
        ) || fail+=(python_neovim)
    fi

    if [[ "${fail[@]}" ]]; then
        echo "Failed to install some utilities: ${fail[@]}" >&2
        return 1
    fi
}

__install_utilities() {
    if ! ((install_utilities)); then
        return
    fi

    echo "Installing utilities..."
    if ((is_macos)); then
        __install_utilities_macos
    elif __check_app_installed apt-get &>/dev/null; then
        __install_utilities_aptget
    else
        echo "Unsupported OS. Skipping..." >&2
    fi
}

__install_desktop_apps_macos() {
    __ensure_homebrew_installed

    brew install --cask android-platform-tools battery chatgpt discord docker \
        zen-browser google-chrome iina jordanbaird-ice karabiner-elements \
        keepingyouawake keka launchbar nightfall rectangle spotify topnotch \
        transmission visual-studio-code wezterm windscribe insync \
        font-jetbrains-mono-nerd-font monitorcontrol prismlauncher \
        cyberduck alt-tab

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
        echo "Unsupported OS. Skipping..." >&2
    fi
}

__restart_zsh() {
    if ! __check_app_installed zsh; then
        return
    fi

    if ((chsh)); then
        echo "Changing default shell to zsh..."
        chsh -s $(which zsh)
    fi

    echo "Restarting zsh..."
    if [ "${ZSH_EXECUTION_STRING-}" ]; then
        ((failed)) || exec zsh -c "$ZSH_EXECUTION_STRING"
    else
        exec zsh
    fi
}

__install_utilities
__clone_repo
__make_links
__install_desktop_apps
__restart_zsh
