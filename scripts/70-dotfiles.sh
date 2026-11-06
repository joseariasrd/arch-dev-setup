#!/usr/bin/env bash
# Link dotfiles into $HOME with GNU stow. Existing files are backed up, never overwritten.
source "$(dirname "$0")/lib.sh"

has_cmd stow || pac stow

cd "$REPO_DIR/dotfiles"
backup="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

for pkg in */; do
  pkg="${pkg%/}"
  # Move any real file that would conflict with a link out of the way.
  while IFS= read -r -d '' f; do
    rel="${f#"$pkg"/}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      mkdir -p "$backup/$(dirname "$rel")"
      mv "$target" "$backup/$rel"
      warn "Backed up ~/$rel → $backup/$rel"
    fi
  done < <(find "$pkg" -type f -print0)
  stow --restow --no-folding --target="$HOME" "$pkg"
  ok "linked $pkg"
done

# Untracked per-machine Hyprland overrides (monitors, etc.); must exist because hyprland.conf sources it.
touch "$HOME/.config/hypr/local.conf"

# ~/.bashrc stays yours; it just sources the repo's config.
line='[[ -f ~/.bashrc.d/dev.sh ]] && source ~/.bashrc.d/dev.sh'
touch "$HOME/.bashrc"
grep -qxF "$line" "$HOME/.bashrc" || echo "$line" >> "$HOME/.bashrc"

# Make the repo reachable at ~/dotfiles (the Claude Code launcher opens it there).
if [[ "$REPO_DIR" != "$HOME/dotfiles" && ! -e "$HOME/dotfiles" ]]; then
  ln -s "$REPO_DIR" "$HOME/dotfiles"
  ok "$HOME/dotfiles → $REPO_DIR"
fi

ok "Dotfiles linked."
