#!/usr/bin/env bash
# Headless Antigravity CLI runner: one prompt in, transcript + exit code out.
#
# Verified behaviour it relies on (antigravity-cli CHANGELOG 1.2.6/1.2.7):
#   * `-p` / `--prompt` runs non-interactively and exits.
#   * `--print-timeout` bounds the run (default became "unlimited" in 1.2.6).
#   * On agent/model API failure the CLI prints `AGY_ERROR: {...}` on stderr
#     and exits with code 3.
#   * Headless runs can authenticate with GEMINI_API_KEY instead of a keyring
#     session.
set -euo pipefail

TIMEOUT="${AGY_PRINT_TIMEOUT:-10m}"
LOG_DIR="${AGY_LOG_DIR:-.agy-logs}"
PROMPT=""

usage() {
  cat <<'EOF'
Usage: scripts/agy-run.sh [--timeout 10m] "<prompt>"
       cat spec.md | scripts/agy-run.sh --timeout 30m

Env:
  AGY_ALLOW_DANGEROUS=1  add --dangerously-skip-permissions (unattended runs;
                         the agent then approves its own tool calls)
  AGY_PRINT_TIMEOUT      default 10m
  AGY_LOG_DIR            default .agy-logs
  GEMINI_API_KEY         API-key auth instead of an interactive keyring session

Exit codes: 0 ok | 2 usage/setup problem | 3 agy agent-or-model failure
            (other codes are passed through from agy)
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --timeout) TIMEOUT="${2:?--timeout needs a value}"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    --) shift; PROMPT="$*"; break ;;
    -*) printf '[agy-run][ERROR] unknown option: %s\n' "$1" >&2; exit 2 ;;
    *) PROMPT="$*"; break ;;
  esac
done

[ -n "$PROMPT" ] || { [ -t 0 ] && { usage >&2; exit 2; }; PROMPT="$(cat)"; }
[ -n "${PROMPT//[[:space:]]/}" ] || { printf '[agy-run][ERROR] empty prompt.\n' >&2; exit 2; }

if ! command -v agy >/dev/null 2>&1; then
  printf '[agy-run][ERROR] `agy` not on PATH. Run scripts/setup-antigravity-cli.sh first.\n' >&2
  exit 2
fi

args=(-p "$PROMPT" --print-timeout "$TIMEOUT")
if [ "${AGY_ALLOW_DANGEROUS:-0}" = "1" ]; then
  # Needed today for fully unattended runs: headless mode does not consult
  # permissions.allow (upstream issue #548), so it otherwise blocks on approval.
  args+=(--dangerously-skip-permissions)
  printf '[agy-run][WARN] --dangerously-skip-permissions is ON: the agent approves its own tool calls.\n' >&2
fi

mkdir -p "$LOG_DIR"
stamp="$(date +%Y%m%d-%H%M%S)-$$"  # PID keeps same-second runs from overwriting each other
out="$LOG_DIR/$stamp.out.txt"
err="$LOG_DIR/$stamp.err.txt"

# stdout streams live and is captured; stderr goes to a file so it can be
# inspected deterministically once the run ends (no process-substitution race).
set +e
agy "${args[@]}" 2>"$err" | tee "$out"
status=${PIPESTATUS[0]}
set -e
[ -s "$err" ] && cat "$err" >&2

if [ "$status" -eq 3 ] || grep -q '^AGY_ERROR:' "$err" 2>/dev/null; then
  printf '[agy-run][ERROR] agy reported a failure. Structured error:\n' >&2
  grep '^AGY_ERROR:' "$err" >&2 || true
  printf '[agy-run] logs: %s , %s\n' "$out" "$err" >&2
  exit 3
fi

printf '[agy-run] exit=%s stdout=%s stderr=%s\n' "$status" "$out" "$err" >&2
exit "$status"
