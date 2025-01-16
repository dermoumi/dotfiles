#!/bin/sh

force=0

while :; do
    case $1 in
        -f|--force)
            force=1
            shift
            ;;
        *)
            break
    esac
done

# Utility to link source to target
link() {
    source=$1
    target_dir=$2

    target=$target_dir$(basename $source)
    if [ -e "$target" ] && ! ((force)); then
        echo "$target already exists. Use --force to overwrite"
        return
    fi

    echo "Linking $source to $target"
    ln -Ffs "$PWD/$source" "$target_dir"
}

# Link files
link zsh/.zshenv ~/
link .gitconfig ~/
link .fdignore ~/
link .tmux.conf ~/
link wezterm ~/.config/
link nvim ~/.config/

# MacOS specific links
if [ "$(uname)" == "Darwin" ]; then
    link karabiner ~/.config/
fi
