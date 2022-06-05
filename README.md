## Install

Linux instructions

```bash
# Upgrade and install packages
sudo apt update -yq && sudo apt upgrade -yq
sudo apt install -yq zsh unzip git curl tmux

# Download repo (assuming ssh keys are already setup)
git clone --recurse-submodules git@github.com:dermoumi/dotfiles.git ~/.dotfiles

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

### Install neovim

```bash
install_nvim
```

### Install pyenv and python

```bash
# Install Python build dependencies (https://github.com/pyenv/pyenv/wiki)
# For ubuntu this would be:
sudo apt-get install make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

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
# For android sdk 30 development

curl -s "https://get.sdkman.io" | bash
sdk install java 8.0.332-zulu
sdk install gradle

export ANDROID_SDK_ROOT=$HOME/.android/sdk
mkdir -p "$ANDROID_SDK_ROOT"
sudo apt-get install sdkmanager # Ubuntu 22.04+
sudo sdkmanager --sdk_root=~/.android/sdk --install 'platforms;android-30' 'build-tools;30.0.3' platform-tools tools
```

### Install rustup

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
