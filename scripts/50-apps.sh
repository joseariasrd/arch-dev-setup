#!/usr/bin/env bash
# GUI apps from the AUR: VS Code and Google Chrome.
source "$(dirname "$0")/lib.sh"

# shellcheck disable=SC2046
aur $(pkglist aur.txt)

# Native Wayland for Chromium-based apps and VS Code.
mkdir -p "$HOME/.config"
for f in chrome-flags.conf code-flags.conf; do
  cat > "$HOME/.config/$f" <<'EOF'
--ozone-platform-hint=auto
--enable-features=WaylandWindowDecorations
EOF
done

ok "VS Code and Chrome installed (Wayland native)."
