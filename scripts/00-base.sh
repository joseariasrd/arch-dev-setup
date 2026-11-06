#!/usr/bin/env bash
# Base system: pacman tuning, mirrors, core tools, paru (AUR helper).
source "$(dirname "$0")/lib.sh"

info "Tuning /etc/pacman.conf (Color, ParallelDownloads, VerbosePkgLists)"
sudo sed -i \
  -e 's/^#Color/Color/' \
  -e 's/^#VerbosePkgLists/VerbosePkgLists/' \
  -e 's/^#\?ParallelDownloads.*/ParallelDownloads = 10/' \
  /etc/pacman.conf

info "Full system upgrade"
sudo pacman -Syu --noconfirm

# shellcheck disable=SC2046
pac $(pkglist base.txt)

info "Fastest HTTPS mirrors (reflector, weekly timer)"
sudo tee /etc/xdg/reflector/reflector.conf >/dev/null <<'EOF'
--save /etc/pacman.d/mirrorlist
--protocol https
--country US,Canada
--latest 20
--sort rate
EOF
enable_now reflector.timer
sudo systemctl start reflector.service || warn "reflector failed; keeping current mirrorlist"

enable_now paccache.timer   # keep only the last 3 versions of each package in cache

if ! has_cmd paru; then
  info "Building paru from the AUR"
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
  (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi
ok "paru $(paru --version | head -1)"
