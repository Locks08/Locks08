#!/bin/bash
set -euo pipefail

# Install the OpenAI Codex CLI so it is available in remote (web) sessions.
# Only runs in Claude Code on the web; local machines manage their own tooling.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Idempotent: skip the install if codex is already on PATH.
if command -v codex >/dev/null 2>&1; then
  echo "codex already installed: $(codex --version 2>/dev/null || echo present)"
  exit 0
fi

npm install -g @openai/codex

echo "codex installed: $(codex --version 2>/dev/null || echo unknown)"
