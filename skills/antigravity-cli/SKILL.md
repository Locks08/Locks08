---
name: antigravity-cli
description: "Install, verify, and drive Google's official Antigravity CLI (the `agy` terminal agent) from Claude Code or Codex. Use when the user wants to set up agy, asks whether the Antigravity CLI is available, wants to delegate implementation work to agy headlessly (`agy -p`), wire it into CI, or debug agy auth, PATH, permissions, or `AGY_ERROR` failures. Covers the official install commands, the sandbox/egress limitation that blocks installation inside Claude Code on the web, and the repository's setup and headless-runner wrappers."
---

# Antigravity CLI (`agy`)

Google's official terminal agent. Same agent engine as the Antigravity 2.0 GUI, TUI surface,
settings sync bidirectionally between them.

Full guide, verified facts, and the unverified/secondary items: `docs/antigravity-cli/SETUP.md`.
Read it before answering detail questions — do not invent flags.

## Decide first: can this machine install it?

`agy` is downloaded from `antigravity.google`. Sandboxes with an egress allowlist
(Claude Code on the web included) block that host with HTTP 403 / `CONNECT tunnel failed`.

```bash
curl -fsSI --max-time 20 https://antigravity.google/cli/install.sh >/dev/null && echo reachable || echo blocked
```

- **blocked** → do not attempt the install. Tell the user to install on their own machine,
  and offer the two remote paths: `agy --remote-control` (drive a local session from elsewhere)
  or a headless `GEMINI_API_KEY` run on a host that already has the binary.
- **reachable** → `./scripts/setup-antigravity-cli.sh --yes`

## Install and verify

```bash
./scripts/setup-antigravity-cli.sh          # prompts before curl|bash
./scripts/setup-antigravity-cli.sh --yes    # CI
./scripts/setup-antigravity-cli.sh --force  # upgrade
agy --version
```

The script is idempotent: it exits early when `agy` already resolves, checks reachability
before piping anything to `bash`, appends `AGY_BIN_DIR` (default `~/.config/Antigravity/bin`)
to `~/.bashrc` / `~/.zshrc` only when the entry is missing, and verifies the binary at the end.

Authentication is interactive and cannot be automated from here: run `agy`, then `/login`.
Over SSH the CLI prints an authorization URL instead of opening a browser. `/logout` clears it.

## Delegate work to agy

```bash
./scripts/agy-run.sh --timeout 30m "<prompt>"
cat spec.md | ./scripts/agy-run.sh --timeout 30m
AGY_ALLOW_DANGEROUS=1 ./scripts/agy-run.sh "<prompt>"   # unattended; agent self-approves
```

Write the prompt as a **spec**, not a wish: goal, files in scope, constraints, done-condition,
how to verify. Claude keeps design and review; `agy` does the mechanical implementation.
`skills/antigravity-cli/templates/AGENTS.md` is the workspace context file to fill in.

Exit codes from the wrapper: `0` ok, `2` usage/setup problem, `3` agy agent-or-model failure,
otherwise agy's own code. Logs land in `.agy-logs/`.

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| `403` / `CONNECT tunnel failed` on install | egress allowlist | install on a normal network; see above |
| `agy: command not found` after install | PATH not reloaded | `source ~/.bashrc`, or add `~/.config/Antigravity/bin` |
| Headless run hangs at ~0% CPU | headless mode does not read `permissions.allow` (upstream #548) | `AGY_ALLOW_DANGEROUS=1`, in a disposable workspace only |
| `AGY_ERROR: {...}` + exit 3 | agent/model API failure; JSON carries status, code, retryability, error ID | read `.agy-logs/*.err.txt`; retry if `retryable` |
| Auth error mentioning scopes | stale OAuth token | `/logout` then `/login` |
| Headless run needs no browser | use API-key auth | export `GEMINI_API_KEY` before the run |

## Guardrails

- Never run the installer without the reachability check; a blocked download would pipe an
  error body into `bash`.
- Never enable `--dangerously-skip-permissions` on a repository with uncommitted work the user
  cares about, or outside a disposable container/worktree. State when it is on.
- Do not claim a flag exists unless it is in `docs/antigravity-cli/SETUP.md` §2 (verified) or you
  confirmed it with `agy --help` in this session. §3 items are secondary sources.
- Usage of agy sends interaction data to Google by default. Flag this before pointing it at a
  private or client repository.
