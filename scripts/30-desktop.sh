#!/usr/bin/env bash
# Hyprland desktop (via uwsm), greetd login screen, audio, Bluetooth.
source "$(dirname "$0")/lib.sh"

# shellcheck disable=SC2046
pac $(pkglist desktop.txt)

info "Login screen: greetd + tuigreet → Hyprland via uwsm"
sudo tee /etc/greetd/config.toml >/dev/null <<'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --asterisks --cmd 'uwsm start hyprland.desktop'"
user = "greeter"
EOF

# Disable any other display manager that might be enabled.
for dm in gdm sddm lightdm ly; do
  systemctl is-enabled "$dm" &>/dev/null && sudo systemctl disable "$dm"
done
sudo systemctl enable greetd.service

enable_now bluetooth.service
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2>/dev/null || true

ok "Desktop installed. Hyprland starts from the login screen after reboot."
