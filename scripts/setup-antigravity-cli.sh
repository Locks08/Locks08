#!/usr/bin/env bash
# Google Antigravity CLI (agy) installer / verifier.
# Source of truth: https://github.com/google-antigravity/antigravity-cli (README)
#   macOS/Linux : curl -fsSL https://antigravity.google/cli/install.sh | bash
# This wrapper adds: preflight checks, idempotency, PATH repair, verification.
set -euo pipefail

INSTALL_URL="https://antigravity.google/cli/install.sh"
AGY_BIN_DIR="${AGY_BIN_DIR:-$HOME/.config/Antigravity/bin}"
ASSUME_YES=0
FORCE=0

log()  { printf '[setup-agy] %s\n' "$*"; }
warn() { printf '[setup-agy][WARN] %s\n' "$*" >&2; }
die()  { printf '[setup-agy][ERROR] %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: scripts/setup-antigravity-cli.sh [--yes] [--force] [--help]

  --yes    Do not prompt before running the official installer (for CI).
  --force  Re-run the installer even if `agy` is already available (upgrade).

Env:
  AGY_BIN_DIR  Expected install dir (default: ~/.config/Antigravity/bin)
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --yes|-y) ASSUME_YES=1 ;;
    --force)  FORCE=1 ;;
    --help|-h) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

# 1. Platform check -----------------------------------------------------------
case "$(uname -s)" in
  Linux|Darwin) : ;;
  MINGW*|MSYS*|CYGWIN*)
    die "Windows detected. Use PowerShell instead:  irm https://antigravity.google/cli/install.ps1 | iex" ;;
  *) die "unsupported platform: $(uname -s)" ;;
esac
command -v curl >/dev/null 2>&1 || die "curl is required but not installed."

# 2. Already installed? -------------------------------------------------------
resolve_agy() {
  if command -v agy >/dev/null 2>&1; then command -v agy; return 0; fi
  if [ -x "$AGY_BIN_DIR/agy" ]; then printf '%s\n' "$AGY_BIN_DIR/agy"; return 0; fi
  return 1
}

if AGY_PATH="$(resolve_agy)" && [ "$FORCE" -eq 0 ]; then
  log "already installed: $AGY_PATH"
  "$AGY_PATH" --version 2>/dev/null || warn "'agy --version' failed; run with --force to reinstall."
  log "re-run with --force to upgrade."
  exit 0
fi

# 3. Network preflight --------------------------------------------------------
# The installer downloads from antigravity.google; sandboxed/corporate networks
# often block it, and `curl | bash` would then execute an empty/error body.
log "checking reachability of $INSTALL_URL ..."
if ! curl -fsSI --max-time 20 "$INSTALL_URL" >/dev/null 2>&1; then
  cat >&2 <<EOF
[setup-agy][ERROR] Cannot reach antigravity.google.

  This host's network policy blocks the download (HTTP 403 / CONNECT tunnel failed
  is typical inside sandboxes and CI runners with an egress allowlist).

  Fixes:
    1. Run this script on a machine with normal outbound HTTPS, or
    2. Allowlist antigravity.google in the egress proxy, then re-run, or
    3. Install on your workstation and drive the remote host with
       'agy --remote-control' / a headless GEMINI_API_KEY session.
EOF
  exit 2
fi

# 4. Install ------------------------------------------------------------------
if [ "$ASSUME_YES" -ne 1 ]; then
  printf '[setup-agy] Run the official installer (curl -fsSL %s | bash)? [y/N] ' "$INSTALL_URL"
  read -r reply
  case "$reply" in y|Y|yes|YES) : ;; *) die "aborted by user." ;; esac
fi

log "downloading installer ..."
tmp="$(mktemp -t agy-install.XXXXXX.sh)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL --max-time 120 "$INSTALL_URL" -o "$tmp"
[ -s "$tmp" ] || die "installer download was empty."
log "running installer ..."
bash "$tmp"

# 5. PATH repair (idempotent) -------------------------------------------------
if ! command -v agy >/dev/null 2>&1 && [ -x "$AGY_BIN_DIR/agy" ]; then
  export PATH="$AGY_BIN_DIR:$PATH"
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    if ! grep -qF "$AGY_BIN_DIR" "$rc"; then
      printf '\n# Antigravity CLI\nexport PATH="%s:$PATH"\n' "$AGY_BIN_DIR" >> "$rc"
      log "added $AGY_BIN_DIR to PATH in $rc"
    fi
  done
fi

# 6. Verify -------------------------------------------------------------------
AGY_PATH="$(resolve_agy)" || die "install finished but 'agy' was not found. Check the installer output above."
log "installed: $AGY_PATH"
"$AGY_PATH" --version || warn "'agy --version' returned non-zero."

cat <<'EOF'

Next steps
  1. Sign in (interactive, once per machine):
       agy          # then /login  — opens a browser; over SSH it prints a URL
  2. Sanity check headless mode:
       scripts/agy-run.sh "Summarize this repository in 3 bullets"
  3. Project context: keep instructions for the agent in ./AGENTS.md
EOF
