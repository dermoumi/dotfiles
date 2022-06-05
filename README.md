## Install

Linux instructions

```bash
# Upgrade and install packages
sudo apt update -yq && sudo apt upgrade -yq
sudo apt install -yq zsh unzip git curl tmux

# Download repo
git clone --recurse-submodules https://github.com/dermoumi/dotfiles.git ~/.dotfiles

# Setup zsh and link dotfiles
ZDOTDIR=~/.dotfiles/zsh zsh -ic 'dotfiles link'

# Set default shell to zsh
chsh -s $(which zsh)
```

## Next steps

### Install build essentials

```bash
sudo apt install build-essential
```

### Install homebrew on linux

```bash
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash"
```

### Install neovim

```bash
brew install neovim
```

### Install pyenv and python

```bash
curl https://pyenv.run | bash
pyenv install 3.10.4
pyenv global 3.10.4
```

### Install neovim remote

```bash
pip install neovim-remote
```

### Install sdkman

```bash
curl -s "https://get.sdkman.io" | bash
```
