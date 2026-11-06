#!/usr/bin/env bash
# btrfs snapshots with snapper + snap-pac, bootable from the GRUB menu, and Windows dual-boot entry.
# Requires: root filesystem on btrfs and GRUB as bootloader (see README → archinstall).
source "$(dirname "$0")/lib.sh"

if [[ "$(findmnt -no FSTYPE /)" != btrfs ]]; then
  warn "Root is not btrfs — skipping snapshots."
  exit 0
fi

# shellcheck disable=SC2046
pac $(pkglist boot.txt)

if ! sudo snapper list-configs 2>/dev/null | grep -q '^root '; then
  info "Creating snapper config for /"
  # archinstall usually creates an @.snapshots subvolume mounted at /.snapshots.
  # snapper create-config refuses if the path exists, so unmount it temporarily.
  mounted_snapshots=0
  if findmnt -n /.snapshots &>/dev/null; then
    sudo umount /.snapshots
    mounted_snapshots=1
  fi
  [[ -d /.snapshots ]] && sudo rmdir /.snapshots
  sudo snapper -c root create-config /
  if ((mounted_snapshots)); then
    # Use the dedicated @.snapshots subvolume (survives rollbacks) instead of snapper's nested one.
    sudo btrfs subvolume delete /.snapshots
    sudo mkdir /.snapshots
    sudo mount -a
  fi
  sudo chmod 750 /.snapshots
fi

info "Snapshot retention (keeps disk usage sane)"
sudo snapper -c root set-config \
  TIMELINE_CREATE=yes TIMELINE_LIMIT_HOURLY=5 TIMELINE_LIMIT_DAILY=7 \
  TIMELINE_LIMIT_WEEKLY=2 TIMELINE_LIMIT_MONTHLY=1 TIMELINE_LIMIT_YEARLY=0 \
  NUMBER_LIMIT=20 "ALLOW_USERS=$USER" SYNC_ACL=yes

enable_now snapper-timeline.timer snapper-cleanup.timer

if [[ -f /etc/default/grub ]]; then
  info "GRUB: snapshots submenu + Windows detection"
  enable_now grub-btrfsd.service
  if grep -q '^#\?GRUB_DISABLE_OS_PROBER' /etc/default/grub; then
    sudo sed -i 's/^#\?GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
  else
    echo 'GRUB_DISABLE_OS_PROBER=false' | sudo tee -a /etc/default/grub >/dev/null
  fi
  sudo grub-mkconfig -o /boot/grub/grub.cfg
else
  warn "GRUB not found — snapshots will be created but won't appear in the boot menu."
fi

sudo snapper -c root create -d "arch-dev-setup: baseline" || true
ok "Snapshots ready. List with: snapper -c root list"
