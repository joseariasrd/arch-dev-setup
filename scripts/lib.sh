#!/usr/bin/env bash
# Shared helpers. Sourced by install.sh and every step.

set -Eeuo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

c_reset=$'\e[0m'; c_blue=$'\e[34m'; c_green=$'\e[32m'; c_yellow=$'\e[33m'; c_red=$'\e[31m'; c_bold=$'\e[1m'

info() { printf '%s==>%s %s\n' "$c_blue" "$c_reset" "$*"; }
ok()   { printf '%s ✓ %s %s\n' "$c_green" "$c_reset" "$*"; }
warn() { printf '%s !  %s %s\n' "$c_yellow" "$c_reset" "$*" >&2; }
die()  { printf '%s ✗  %s %s\n' "$c_red" "$c_reset" "$*" >&2; exit 1; }
step() { printf '\n%s%s━━━ %s ━━━%s\n' "$c_bold" "$c_blue" "$*" "$c_reset"; }

# Read a package list file: one package per line, '#' comments allowed.
pkglist() { grep -vE '^\s*(#|$)' "$REPO_DIR/packages/$1" | sed 's/\s*#.*//' | xargs; }

# Install official-repo packages that are not installed yet.
pac() {
  local missing=()
  for p in "$@"; do pacman -Qq "$p" &>/dev/null || missing+=("$p"); done
  if ((${#missing[@]})); then
    info "pacman: ${missing[*]}"
    local flags=(--needed)
    [[ "${ASK:-0}" == 1 ]] || flags+=(--noconfirm)
    sudo pacman -S "${flags[@]}" "${missing[@]}"
  else
    ok "already installed: $*"
  fi
}

# Install AUR packages via paru (reviews PKGBUILDs unless PARU_SKIPREVIEW=1).
aur() {
  command -v paru &>/dev/null || die "paru not installed; run step 00-base first."
  local missing=()
  for p in "$@"; do pacman -Qq "$p" &>/dev/null || missing+=("$p"); done
  if ((${#missing[@]})); then
    info "AUR: ${missing[*]}"
    local flags=(--needed)
    [[ "${PARU_SKIPREVIEW:-0}" == 1 ]] && flags+=(--skipreview --noconfirm)
    paru -S "${flags[@]}" "${missing[@]}"
  else
    ok "already installed: $*"
  fi
}

enable_now() { sudo systemctl enable --now "$@"; }

# Append a line to a file (as root) only if it is not there already.
ensure_line() {
  local line="$1" file="$2"
  sudo touch "$file"
  sudo grep -qxF "$line" "$file" || echo "$line" | sudo tee -a "$file" >/dev/null
}

has_cmd() { command -v "$1" &>/dev/null; }
