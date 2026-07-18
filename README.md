## Install

Pipe `setup.sh` into bash with a variant (`workstation`, `server`, or
`devcontainer`). It clones the repo to `~/.dotfiles`, bootstraps Ansible, and
applies that variant's roles.

macOS:

```bash
git --version  # prompts to install the Command Line Tools (needed to clone)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dermoumi/dotfiles/HEAD/setup.sh)" -- workstation
```

WSL2 (Ubuntu/Debian):

```bash
sudo apt update && sudo apt install -y git curl
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dermoumi/dotfiles/HEAD/setup.sh)" -- workstation
```
