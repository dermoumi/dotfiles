## Install

Macos instructions:

```bash
git --version  # Will prompt you to install development tools
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dermoumi/dotfiles/HEAD/setup.sh)" -- --init-desktop
```

WSL instructions:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/dermoumi/dotfiles/HEAD/setup.sh)" -- --init-cli
```

## System setup (Ansible)

`setup.sh` handles user-level dotfiles and tooling. Privileged, root-level host
setup (e.g. SSH) lives in `ansible/` as idempotent playbooks you run **locally**
on each machine — no SSH access needed, tasks execute directly with `sudo`.

```bash
sudo pacman -S ansible        # prereq (Arch)
cd ~/.dotfiles/ansible
./run --check                 # dry run
./run                         # apply
```

`run` limits execution to the current host (`hostname -s`), so a machine absent
from `inventory.ini` is inert. Each machine opts into roles via
`machine_roles` in `host_vars/<hostname>.yml`; per-machine parameters (e.g.
`ssh_port`) also live there. Safe to re-run. Pass `-K` if `sudo` needs a password.

The `ssh` role refuses to enable keys-only SSH unless a non-root user already has
an `authorized_keys` entry (override the protected account with
`ssh_authorized_user`). Note this guards only against *key* lockout — the role
also binds sshd to the tailnet address (`ListenAddress`), which drops public-IP
SSH. On a remote box, confirm you can reach it over the tailnet before running.
