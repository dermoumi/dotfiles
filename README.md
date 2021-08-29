## Install

Linux instructions

```bash
# Upgrade and install packages
sudo apt update -yq && sudo apt upgrade -yq
sudo apt install -yq zsh unzip git curl tmux

# Download repo
git clone --recurse-submodules https://github.com/dermoumi/dotfiles.git ~/.dotfiles/zsh

# Setup zsh and link dotfiles
ZDOTDIR=~/.dotfiles/zsh zsh -ic 'dotfiles link'

# Set default shell to zsh
chsh -s $(which zsh)
```
