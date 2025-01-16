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

app_install_list=()
app_update_list=()

force=0
update_apps=0

installed=0
failed=0

# Parse arguments
while :; do
    case $1 in
        -f|--force)
            force=1
            shift
            ;;
        -u|--update)
            update_apps=1
            shift
            ;;
        *)
            break
    esac
done

# Utility to link source to target
mk_link() {
    local source=$1
    local target_dir=$2

    local target=$target_dir$(basename $source)
    if [ -e "$target" ] && ! ((force)); then
        echo "$target already exists. Use --force to overwrite"
        return
    fi

    echo "Linking $source to $target"
    ln -Ffs "$PWD/$source" "$target_dir"
}

# Checks if the given app is installed
check_app_installed() {
    local app=$1
    command -v $app &>/dev/null
}

# Link files
echo "Linking files..."
mk_link zsh/.zshenv ~/
mk_link .gitconfig ~/
mk_link .fdignore ~/
mk_link .tmux.conf ~/
mk_link wezterm ~/.config/
mk_link nvim ~/.config/

# MacOS specific links
if ((is_macos)); then
    mk_link karabiner ~/.config/
fi

# Check for apps
echo "Checking for required apps..."
for app in "${app_check_list[@]}"; do
    if ! check_app_installed $app; then
        app_install_list+=($app)
    elif ((update_apps)); then
        app_update_list+=($app)
    fi
done
echo "Apps to install: ${app_install_list[@]}"
echo "Apps to update: ${app_update_list[@]}"

__latest_url() {
    local repo filename_pattern
    repo=$1
    filename_pattern=$2

    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" | grep -oE "https://.+/$filename_pattern" | head -n1
}

__try_curl() {
    command -v curl > /dev/null || return 1

    local file=$1
    shift

    if [[ "$file" =~ tar.gz$ ]]; then
        curl -fsSL "$file" | tar -xzf - "$@"
    else
        local tempdir
        tempdir=$(mktemp -d)
        local temp="$tempdir/target.zip"
        if [[ "$tempdir" ]]; then
            curl -fsSLo "$temp" "$file" && unzip -o "$temp" >/dev/null
            rm -rf "$tempdir"
        fi
    fi
}

__try_wget() {
    command -v wget > /dev/null || return 1

    local file=$1
    shift

    if [[ "$file" =~ tar.gz$ ]]; then
        wget -O - "$file" | tar -xzf - "$@"
    else
        local tempdir
        tempdir=$(mktemp -d)
        local temp="$tempdir/target.zip"
        if [[ "$tempdir" ]]; then
            wget -O "$temp" "$file" && unzip -o "$temp" >/dev/null
            rm -rf "$tempdir"
        fi
    fi
}

__download() {
    local retval=0

    echo "-> Downloading from: $1"

    set -o pipefail
    __try_curl "$@" || __try_wget "$@" || retval=$?
    set +o pipefail

    return "$retval"
}

# Install apps
install_fzf() {
    echo "Installing fzf..."

    if command -v brew &>/dev/null; then
        brew install fzf
    else
        # Try to download binary executable
        archi=$(uname -sm)
        case "$archi" in
            Linux\ aarch64*) file_pattern="fzf-[^-]+-linux_arm64\.tar\.gz"   ;;
            Linux\ *64)      file_pattern="fzf-[^-]+-linux_amd64\.tar\.gz"   ;;
            CYGWIN*\ *64)    file_pattern="fzf-[^-]+-windows_amd64\.zip"     ;;
            MINGW*\ *64)     file_pattern="fzf-[^-]+-windows_amd64\.zip"     ;;
            MSYS*\ *64)      file_pattern="fzf-[^-]+-windows_amd64\.zip"     ;;
            Windows*\ *64)   file_pattern="fzf-[^-]+-windows_amd64\.zip"     ;;
            *)               file_pattern= binary_error=1 ;;
        esac

        __download "$(__latest_url "junegunn/fzf" "$file_pattern")"

        if [ -f fzf ]; then
            chmod +x fzf
            installed=1
        else
            echo "Failed to download fzf" >&2
            failed=1
        fi
    fi
}

install_fd() {
    echo "Installing fd..."

    if command -v brew &>/dev/null; then
        brew install fd
    else
        # Try to download binary executable
        archi=$(uname -sm)
        case "$archi" in
            Linux\ aarch64*) file_pattern="fd-[^-]+-arm-unknown-linux-musleabihf\.tar\.gz"   ;;
            Linux\ *64)      file_pattern="fd-[^-]+-x86_64-unknown-linux-musl\.tar\.gz"   ;;
            CYGWIN*\ *64)    file_pattern="fd-[^-]+-i686-pc-windows-gnu\.zip"     ;;
            MINGW*\ *64)     file_pattern="fd-[^-]+-i686-pc-windows-gnu\.zip"     ;;
            MSYS*\ *64)      file_pattern="fd-[^-]+-i686-pc-windows-gnu\.zip"     ;;
            Windows*\ *64)   file_pattern="fd-[^-]+-i686-pc-windows-gnu\.zip"     ;;
            *)               file_pattern= binary_error=1 ;;
        esac

        __download "$(__latest_url "sharkdp/fd" "$file_pattern")" \
            --wildcards '*/fd' --strip-components=1

        if [ -f fd ]; then
            chmod +x fd
            installed=1
        else
            echo "Failed to download fd" >&2
            failed=1
        fi
    fi
}

install_zoxide() {
    echo "Installing zoxide..."

    if command -v brew &>/dev/null; then
        brew install zoxide
    else
        # Try to download binary executable
        archi=$(uname -sm)
        case "$archi" in
            Linux\ aarch64*) file_pattern="zoxide(-.+)?-aarch64-unknown-linux-musl\.tar\.gz"   ;;
            Linux\ *64)      file_pattern="zoxide(-.+)?-x86_64-unknown-linux-musl\.tar\.gz"   ;;
            CYGWIN*\ *64)    file_pattern="zoxide(-.+)?-x86_64-pc-windows-msvc\.zip"     ;;
            MINGW*\ *64)     file_pattern="zoxide(-.+)?-x86_64-pc-windows-msvc\.zip"     ;;
            MSYS*\ *64)      file_pattern="zoxide(-.+)?-x86_64-pc-windows-msvc\.zip"     ;;
            Windows*\ *64)   file_pattern="zoxide(-.+)?-x86_64-pc-windows-msvc\.zip"     ;;
            *)               file_pattern= binary_error=1 ;;
        esac

        __download "$(__latest_url "ajeetdsouza/zoxide" "$file_pattern")" --wildcards zoxide

        if [ -f zoxide ]; then
            chmod +x zoxide
            installed=1
        else
            echo "Failed to download zoxide" >&2
            failed=1
        fi
    fi
}

install_bat() {
    echo "Installing bat..."

    if command -v brew &>/dev/null; then
        brew install bat
    else
        # Try to download binary executable
        archi=$(uname -sm)
        case "$archi" in
            Linux\ aarch64*) file_pattern="bat-[^-]+-aarch64-unknown-linux-gnu\.tar\.gz"   ;;
            Linux\ *64)      file_pattern="bat-[^-]+-x86_64-unknown-linux-musl\.tar\.gz"   ;;
            CYGWIN*\ *64)    file_pattern="bat-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            MINGW*\ *64)     file_pattern="bat-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            MSYS*\ *64)      file_pattern="bat-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            Windows*\ *64)   file_pattern="bat-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            *)               file_pattern= binary_error=1 ;;
        esac

        __download "$(__latest_url "sharkdp/bat" "$file_pattern")" \
            --wildcards '*/bat' --strip-components=1

        if [ -f bat ]; then
            chmod +x bat
            installed=1
        else
            echo "Failed to download bat" >&2
            failed=1
        fi
    fi
}

install_rg() {
    echo "Installing ripgrep..."

    if command -v brew &>/dev/null; then
        brew install ripgrep
    else
        # Try to download binary executable
        archi=$(uname -sm)
        case "$archi" in
            Linux\ aarch64*) file_pattern="ripgrep-[^-]+-aarch64-unknown-linux-gnu\.tar\.gz"   ;;
            Linux\ *64)      file_pattern="ripgrep-[^-]+-x86_64-unknown-linux-musl\.tar\.gz"   ;;
            CYGWIN*\ *64)    file_pattern="ripgrep-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            MINGW*\ *64)     file_pattern="ripgrep-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            MSYS*\ *64)      file_pattern="ripgrep-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            Windows*\ *64)   file_pattern="ripgrep-[^-]+-x86_64-pc-windows-msvc\.zip"     ;;
            *)               file_pattern= binary_error=1 ;;
        esac

        __download "$(__latest_url "BurntSushi/ripgrep" "$file_pattern")" \
            --wildcards '*/rg' --strip-components=1

        if [ -f rg ]; then
            chmod +x rg
            installed=1
        else
            echo "Failed to download ripgrep" >&2
            failed=1
        fi
    fi
}

install_brew() {
    echo "Installing homebrew..."

    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash

    # Add the newly created bin directory to path
    if [[ -d /opt/homebrew/bin ]]; then
        path=(/opt/homebrew/bin $path)
    fi
}

# Update apps
update_fzf() {
    echo "Upgrading fzf..."
    if command -v brew >/dev/null; then
        brew upgrade fzf
    else
        install_fzf
    fi
}

update_fd() {
    echo "Upgrading fd..."
    if command -v brew >/dev/null; then
        brew upgrade fd
    else
        install_fd
    fi
}

update_zoxide() {
    echo "Upgrading zoxide..."
    if command -v brew >/dev/null; then
        brew upgrade zoxide
    else
        install_zoxide
    fi
}

update_bat() {
    echo "Upgrading bat..."
    if command -v brew >/dev/null; then
        brew upgrade bat
    else
        install_bat
    fi
}

update_rg() {
    echo "Upgrading ripgrep..."
    if command -v brew >/dev/null; then
        brew upgrade ripgrep
    else
        install_rg
    fi
}

update_brew() {
    brew update
}

bin_path="$HOME/.local/bin"
mkdir -p "$bin_path"

pushd "$bin_path" &>/dev/null

# Install apps
for app in "${app_install_list[@]}"; do
    case $app in
        fzf) install_fzf;;
        fd) install_fd;;
        zoxide) install_zoxide;;
        bat) install_bat;;
        rg) install_rg;;
        brew) install_brew;;
    esac
done

# Update apps
for app in "${app_update_list[@]}"; do
    case $app in
        fzf) update_fzf;;
        fd) update_fd;;
        zoxide) update_zoxide;;
        bat) update_bat;;
        rg) update_rg;;
        brew) update_brew;;
    esac
done

popd &>/dev/null

if ((installed)); then
    echo "Restarting zsh..."
    if [[ "$ZSH_EXECUTION_STRING" ]]; then
        ((failed)) || exec zsh -c "$ZSH_EXECUTION_STRING"
    else
        exec zsh
    fi
fi
