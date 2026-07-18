#!/usr/bin/env bash
set -euo pipefail

dotfiles_dir="$HOME/.dotfiles"
uv_bin="$HOME/.local/bin/uv"
ansible_venv="$HOME/.local/share/venvs/ansible-venv"

if [ ! -d "$dotfiles_dir" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/dermoumi/dotfiles.git "$dotfiles_dir"
    git -C "$dotfiles_dir" remote set-url origin git@github.com:dermoumi/dotfiles.git
fi
cd "$dotfiles_dir"

if [ ! -x "$uv_bin" ]; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | INSTALLER_NO_MODIFY_PATH=1 sh
fi

if [ ! -x "$ansible_venv/bin/ansible-playbook" ]; then
    echo "Creating ansible venv..."
    "$uv_bin" venv "$ansible_venv"
    "$uv_bin" pip install --python "$ansible_venv/bin/python" ansible
fi

# Expose the venv for this run; zsh picks it up in future shells via .zshenv.
export PATH="$ansible_venv/bin:$PATH"

cd ansible
ansible-galaxy collection install -r requirements.yml

# Optional first positional is the variant; a leading '-' means an ansible flag.
variant=""
if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
    variant="$1"
    shift
fi

# Inline inventory keyed by hostname so host_vars/<hostname>.yml still loads.
# Prompt for a sudo password only when we're not already root.
become_args=()
[ "$(id -u)" -ne 0 ] && become_args+=(--ask-become-pass)

ansible-playbook \
    -i "$(hostname -s)," -c local \
    ${become_args[@]+"${become_args[@]}"} \
    ${variant:+--extra-vars variant=$variant} \
    site.yml "$@"

exec zsh
