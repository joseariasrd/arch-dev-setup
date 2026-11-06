# Managed by arch-dev-setup (dotfiles/bash). Sourced from ~/.bashrc.

export EDITOR=code
export VISUAL=code
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.grok/bin:$PATH"

# Tools
command -v mise     >/dev/null && eval "$(mise activate bash)"
command -v starship >/dev/null && eval "$(starship init bash)"
command -v zoxide   >/dev/null && eval "$(zoxide init bash)"
[[ -f /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
[[ -f /usr/share/fzf/completion.bash   ]] && source /usr/share/fzf/completion.bash

# History
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Aliases
alias ls='eza --group-directories-first'
alias ll='eza -l --git --group-directories-first'
alias la='eza -la --git --group-directories-first'
alias cat='bat --paging=never'
alias lg='lazygit'
alias dc='docker compose'

# System helpers
alias update='paru -Syu'                         # snap-pac snapshots before/after automatically
alias snaps='snapper -c root list'
alias cleanup='paru -Sc && sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null'
alias dots='cd ~/dotfiles'
alias ai='cd ~/dotfiles && claude'               # system assistant (reads ~/dotfiles/CLAUDE.md)
