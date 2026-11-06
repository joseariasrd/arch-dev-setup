#!/usr/bin/env bash
# Developer stack: CLI tools, mise (language versions), Docker.
source "$(dirname "$0")/lib.sh"

# shellcheck disable=SC2046
pac $(pkglist dev.txt)

info "Docker: enable service and allow running without sudo"
enable_now docker.service
if ! id -nG "$USER" | grep -qw docker; then
  sudo usermod -aG docker "$USER"
  warn "Added $USER to the 'docker' group — takes effect after logout/reboot."
fi

info "mise: global Node LTS and Python (needed by the npm-based AI CLIs)"
mise use -g node@lts python@3.12
mise exec -- node --version
mise exec -- python --version

if [[ -z "$(git config --global user.name || true)" ]]; then
  warn "Set your git identity:  git config --global user.name 'Your Name' && git config --global user.email you@example.com"
fi
git config --global init.defaultBranch main
git config --global pull.rebase true

ok "Dev stack ready."
