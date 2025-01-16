# Check whether or not to force linking files
if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
    force=true
else
    force=false
fi

# Utility to link source to target
link() {
    source=$1
    target_dir=$2

    target=$target_dir$(basename $source)
    if [ -e "$target" ] && [ "$force" = false ]; then
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
