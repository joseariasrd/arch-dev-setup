#!/usr/bin/env bash
# NVIDIA RTX 50 series: open kernel modules (DKMS), early KMS, Wayland-friendly options.
source "$(dirname "$0")/lib.sh"

if ! lspci | grep -qi 'vga.*nvidia\|3d.*nvidia'; then
  warn "No NVIDIA GPU detected — skipping."
  exit 0
fi

# Remove the closed/proprietary variants if archinstall pulled one in.
for p in nvidia nvidia-lts nvidia-dkms; do
  if pacman -Qq "$p" &>/dev/null; then
    info "Removing $p (replaced by nvidia-open-dkms)"
    sudo pacman -Rdd --noconfirm "$p"
  fi
done

# shellcheck disable=SC2046
pac $(pkglist nvidia.txt)

info "Kernel module options"
sudo tee /etc/modprobe.d/nvidia.conf >/dev/null <<'EOF'
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
EOF

info "Early KMS: NVIDIA modules in initramfs, drop the generic 'kms' hook"
conf=/etc/mkinitcpio.conf
if ! grep -q '^MODULES=.*nvidia_drm' "$conf"; then
  sudo sed -i -E 's/^MODULES=\((.*)\)/MODULES=(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/; s/^MODULES=\( /MODULES=(/' "$conf"
fi
sudo sed -i -E '/^HOOKS=/ s/ kms//' "$conf"
sudo mkinitcpio -P

# Suspend/resume support (works with PreserveVideoMemoryAllocations above).
for s in nvidia-suspend nvidia-resume nvidia-hibernate; do
  sudo systemctl enable "$s.service" 2>/dev/null || true
done

ok "NVIDIA configured. A reboot is required before 'nvidia-smi' works."
