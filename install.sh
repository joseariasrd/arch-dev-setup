#!/usr/bin/env bash
# arch-dev-setup — post-install bootstrap for an Arch + Hyprland full-stack dev workstation.
# Run as your normal user (NOT root) after the first boot into a fresh archinstall system.
#
#   ./install.sh                 # run every step in order
#   ./install.sh --only 40-dev   # run a single step
#   ./install.sh --list          # list steps
#
# Every step is idempotent: re-running it is safe.

set -Eeuo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_DIR
# shellcheck source=scripts/lib.sh
source "$REPO_DIR/scripts/lib.sh"

usage() {
  sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
}

steps=()
while IFS= read -r f; do steps+=("$f"); done < <(find "$REPO_DIR/scripts" -maxdepth 1 -name '[0-9][0-9]-*.sh' | sort)

only=""
case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  --list) for s in "${steps[@]}"; do basename "$s" .sh; done; exit 0 ;;
  --only) only="${2:?--only needs a step name, see --list}" ;;
  "") ;;
  *) usage; exit 1 ;;
esac

[[ $EUID -eq 0 ]] && die "Run as your normal user, not root. The script uses sudo when needed."
[[ -f /etc/arch-release ]] || die "This is not Arch Linux."

LOG="$HOME/arch-dev-setup-$(date +%Y%m%d-%H%M%S).log"
exec > >(tee -a "$LOG") 2>&1
info "Log: $LOG"

# Keep sudo alive for the whole run.
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

ran=0
for s in "${steps[@]}"; do
  name="$(basename "$s" .sh)"
  if [[ -n "$only" && "$name" != "$only"* ]]; then continue; fi
  step "$name"
  bash "$s"
  ran=$((ran + 1))
done

[[ $ran -eq 0 ]] && die "No step matched '$only'. See ./install.sh --list"

ok "Done ($ran step(s)). Reboot to start Hyprland: sudo reboot"
