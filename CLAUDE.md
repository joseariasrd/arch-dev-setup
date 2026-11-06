# System context for AI agents (Claude Code, Codex, Gemini, OpenCode, Grok)

You are acting as the system administrator assistant for this workstation.
This repository (`~/dotfiles`) is the single source of truth for its configuration.

## The machine
- **OS:** Arch Linux (rolling). Kernel `linux`. Bootloader GRUB. Root on **btrfs** with snapper.
- **CPU/RAM:** AMD Ryzen 5 5600X, 48 GB.
- **GPU:** NVIDIA RTX 5050 (Blackwell) → driver `nvidia-open-dkms` only. Never install `nvidia` or `nvidia-dkms` (closed modules do not support this GPU).
- **Desktop:** Hyprland started through **uwsm** from greetd/tuigreet. Bar: waybar. Launcher: fuzzel. Notifications: mako. Terminal: kitty.
- **Dual boot:** Windows lives on a separate disk. Never touch it, its partitions, or the EFI entries for it.
- **Locale:** en_US.UTF-8, keyboard `us`, timezone America/Santo_Domingo.

## Where configuration lives
| What | Edit this file in the repo | Linked to |
|---|---|---|
| Hyprland | `dotfiles/hypr/.config/hypr/hyprland.conf` | `~/.config/hypr/` |
| Per-machine Hyprland (monitors) | `~/.config/hypr/local.conf` (untracked) | — |
| Session env vars (NVIDIA, Wayland) | `dotfiles/uwsm/.config/uwsm/env` | `~/.config/uwsm/env` |
| Waybar | `dotfiles/waybar/.config/waybar/` | `~/.config/waybar/` |
| Shell | `dotfiles/bash/.bashrc.d/dev.sh` | `~/.bashrc.d/dev.sh` |
| Packages | `packages/*.txt` | installed by `scripts/NN-*.sh` |

Dotfiles are linked with GNU stow. After adding a new file under `dotfiles/<pkg>/`, run `./scripts/70-dotfiles.sh`.

## Rules
1. **Edit files in this repo, not in `~/.config` directly.** The files in `~/.config` are symlinks into here.
2. **Keep the repo reproducible.** When you install a package the user wants to keep, add it to the matching `packages/*.txt` file. When you change system files under `/etc`, encode the change in the matching `scripts/NN-*.sh` step so a reinstall reproduces it.
3. **Packages:** official repos with `sudo pacman -S --needed <pkg>`; AUR with `paru -S <pkg>`. Prefer official repos over AUR, and AUR `-bin` over building from source. Never use `--noconfirm` interactively, never partial upgrades (`pacman -Sy <pkg>` is forbidden; use `-Syu`).
4. **Before risky changes** (bootloader, initramfs, kernel, NVIDIA, fstab, systemd units) create a snapshot first: `sudo snapper -c root create -d "before: <what>"`. pacman transactions are snapshotted automatically by snap-pac.
5. **Language runtimes** (Node, Python, Go, …) are managed by `mise`, not pacman. Global npm tools: `mise exec -- npm i -g <pkg>`.
6. **Docker** is the system Docker Engine; the user is in the `docker` group.
7. Never run `rm -rf` on paths outside the repo or `/tmp` without asking. Never edit `/etc/fstab`, partitions or GRUB without explaining the change and asking first.
8. After changing Hyprland config, reload with `hyprctl reload` and check `hyprctl configerrors`.
9. Commit finished changes to git with a clear message (`git add -A && git commit -m "..."`). Do not push unless asked.

## Useful commands
- Update everything: `paru -Syu`
- Snapshots: `snapper -c root list` · rollback: boot the snapshot from the GRUB "Arch Linux snapshots" submenu, then `sudo snapper rollback`
- Logs: `journalctl -b -p warning`, `journalctl --user -b -u waybar`
- GPU: `nvidia-smi`
- Re-run one setup step: `./install.sh --only 30-desktop`
