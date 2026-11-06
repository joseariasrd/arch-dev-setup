#!/usr/bin/env bash
# Cloud AI coding agents: Claude Code, Codex, Gemini CLI, OpenCode, Grok Build.
# Each installer is independent; one failing does not stop the others.
source "$(dirname "$0")/lib.sh"
set +e
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.grok/bin:$PATH"

failed=()
try() {
  local name="$1"; shift
  info "$name"
  if "$@"; then ok "$name"; else warn "$name failed — install it manually later"; failed+=("$name"); fi
}

npm_g() { mise exec -- npm install -g "$@"; }

# Official native installer (auto-updates itself).
has_cmd claude   || try "Claude Code" bash -c 'curl -fsSL https://claude.ai/install.sh | bash'
has_cmd codex    || try "OpenAI Codex CLI" npm_g @openai/codex
has_cmd gemini   || try "Google Gemini CLI" npm_g @google/gemini-cli
has_cmd opencode || try "OpenCode" bash -c 'curl -fsSL https://opencode.ai/install | bash'
# xAI Grok Build — verify the URL at https://x.ai/cli before relying on it.
has_cmd grok     || try "xAI Grok Build" bash -c 'curl -fsSL https://x.ai/cli/install.sh | bash'

mise reshim 2>/dev/null

echo
info "Sign in to each tool once (opens the browser):"
echo "   claude      → /login"
echo "   codex       → sign in with ChatGPT"
echo "   gemini      → sign in with Google"
echo "   opencode    → opencode auth login"
echo "   grok        → grok login  (or export XAI_API_KEY)"

if ((${#failed[@]})); then
  warn "Failed: ${failed[*]}"
  exit 1
fi
ok "AI CLIs installed."
