#!/usr/bin/env bash
set -euo pipefail

dotfiles_dir="$HOME/.dotfiles"
uv_bin="$HOME/.local/bin/uv"
ansible_venv="$HOME/.local/share/venvs/ansible-venv"

# git clones the repo below and curl fetches uv — both run before ansible can
# install anything, so a bare Linux box needs them bootstrapped here.
if [ "$(uname)" = "Linux" ]; then
    missing=()
    for cmd in git curl; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Installing ${missing[*]}..."
        sudo_cmd=()
        [ "$(id -u)" -ne 0 ] && sudo_cmd=(sudo)

        if command -v pacman >/dev/null 2>&1; then
            ${sudo_cmd[@]+"${sudo_cmd[@]}"} pacman -Sy --needed --noconfirm "${missing[@]}"
        elif command -v apt-get >/dev/null 2>&1; then
            ${sudo_cmd[@]+"${sudo_cmd[@]}"} apt-get update
            ${sudo_cmd[@]+"${sudo_cmd[@]}"} apt-get install -y "${missing[@]}"
        else
            echo "No supported package manager found (pacman, apt-get)." >&2
            echo "Install ${missing[*]} manually, then re-run." >&2
            exit 1
        fi
    fi
fi

if [ ! -d "$dotfiles_dir" ]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/dermoumi/dotfiles.git "$dotfiles_dir"
    git -C "$dotfiles_dir" remote set-url origin git@forge.home.dermoumi.com:sdrm/dotfiles
fi
cd "$dotfiles_dir"

if [ ! -x "$uv_bin" ]; then
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | INSTALLER_NO_MODIFY_PATH=1 sh
fi

if [ ! -d "$ansible_venv" ]; then
    echo "Creating ansible venv..."
    # Pin a modern python; macOS's system 3.9 caps ansible-core at 2.15.
    "$uv_bin" venv --python 3.14 "$ansible_venv"
fi
# Upgrade every run so ansible-core stays current with the galaxy collections.
"$uv_bin" pip install --python "$ansible_venv/bin/python" --upgrade ansible

# Homebrew (macOS): its installer needs an interactive sudo TTY, so it lives
# here in the bootstrap rather than an ansible task.
if [ "$(uname)" = "Darwin" ] && [ ! -x /opt/homebrew/bin/brew ]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Expose the venv for this run; zsh picks it up in future shells via .zshenv.
export PATH="$ansible_venv/bin:$PATH"

# Run ansible from the repo root (ansible.cfg via env) so we don't leave the
# final `exec zsh` sitting in the ansible/ subdirectory.
export ANSIBLE_CONFIG="ansible/ansible.cfg"
ansible-galaxy collection install --upgrade -r ansible/requirements.yml

# First bare word is the variant; --hostname NAME renames the host and targets
# its host_vars; anything else passes through to ansible-playbook.
variant=""
target_hostname=""
passthru=()
while [ $# -gt 0 ]; do
    case "$1" in
        --hostname)
            target_hostname="${2:-}"
            [ -n "$target_hostname" ] || { echo "--hostname requires a value" >&2; exit 1; }
            shift 2 ;;
        --hostname=*) target_hostname="${1#*=}"; shift ;;
        -*) passthru+=("$1"); shift ;;
        *) [ -n "$variant" ] && passthru+=("$1") || variant="$1"; shift ;;
    esac
done

# Inline inventory keyed by the target (or current) hostname so
# host_vars/<hostname>.yml loads. Prompt for sudo only when not already root.
host="${target_hostname:-$(hostname -s)}"

become_args=()
[ "$(id -u)" -ne 0 ] && become_args+=(--ask-become-pass)

extra_vars=()
[ -n "$variant" ] && extra_vars+=(--extra-vars "variant=$variant")
[ -n "$target_hostname" ] && extra_vars+=(--extra-vars "target_hostname=$target_hostname")

ansible-playbook \
    -i "$host," -c local \
    ${become_args[@]+"${become_args[@]}"} \
    ${extra_vars[@]+"${extra_vars[@]}"} \
    ${passthru[@]+"${passthru[@]}"} \
    ansible/site.yml

exec zsh
