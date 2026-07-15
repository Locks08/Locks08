# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is a **skills repository**, not an application. It packages agent skills — folders of
Markdown instructions (plus a few supporting files) that an AI agent reads on demand to perform a
task. There is no build system, test suite, linter, or runtime for this repo itself. "Working on
this codebase" means authoring and maintaining skill instructions, not compiling or running code.

The only build/test/lint commands you will see (`pnpm add`, `pnpm check`, `npm run dev`,
`node scripts/capture.mjs`, `webdev_*` tools, etc.) appear *inside* skill instructions and describe
how a game the skill generates is built — they are content, not commands for this repo. There is
nothing to build or test here; validate changes by reading the Markdown for correctness and internal
consistency.

## Layout

```
skills/
  <skill-name>/
    SKILL.md              # entrypoint: YAML frontmatter (name, description, license) + top-level instructions
    references/**.md      # detailed stage/topic docs, read on demand when the agent reaches that stage
    templates/*           # drop-in source files the skill tells the agent to copy into a target project
    LICENSE.txt, NOTICE.md # required when the skill adapts third-party material
```

Currently one skill: **`game-dev`** — builds playable Babylon.js browser games end-to-end.

## The `game-dev` skill: architecture

`game-dev` is an adaptation of the upstream **godogen** pipeline (MIT, by Alex Ermolov —
https://github.com/htdt/godogen) retargeted to the **Manus** environment. Understanding it requires
holding two layers in mind at once:

- **godogen layer** (`references/godogen-stages/*.md`): the upstream stage instructions, reproduced
  substantially verbatim. These are the source of truth for *how a good game is built* — the staged
  workflow (visual target → risk decomposition → scaffold → architecture → assets → implementation →
  visual verification), the Babylon architecture stance, and the browser/engine quirks. They still
  reference godogen's own tooling (bare Vite scaffold, `npm`, `scripts/capture.mjs`, paid
  Gemini/Grok/Tripo3D asset CLIs).
- **Manus adaptation layer** (`references/manus-adaptations.md`, `SKILL.md`, `templates/GameCanvas.tsx`):
  original Manus-authored content that changes *where the game runs and how art/deploy happen*.
  **`manus-adaptations.md` overrides the godogen stage files wherever they conflict** — this
  precedence rule is load-bearing. Several stage files carry inline `MANUS OVERRIDE` notes pointing
  to it.

The adaptation changes exactly three things from upstream godogen:
1. **Host shell** — a Manus WebDev React project (React 19 + Vite + Tailwind + shadcn/ui) instead of
   godogen's bare Vite scaffold.
2. **Art** — Manus built-in image generation (`generate` mode) instead of the paid CLIs. The art
   step is **mandatory and never skipped**.
3. **Deploy** — WebDev Publish to `*.manus.space` instead of temporary `expose`/proxy links, which
   are forbidden as the deliverable.

Mental model repeated throughout the skill: **React = picture frame, Babylon = canvas, godogen game
code = the painting.** Gameplay lives in framework-agnostic plain-TS classes under
`client/src/game/**` with zero React coupling; `GameCanvas.tsx` is the only React↔Babylon boundary
and must obey the "init once / dispose on unmount / handle resize / guard StrictMode double-mount"
contract.

### Reading order within the skill

Read `SKILL.md` first, then `references/manus-adaptations.md`, then pull individual
`references/godogen-stages/*.md` files **only when the pipeline reaches that stage** (this on-demand
reading is intentional — do not front-load them all). `references/godogen-stages/godogen-skill-overview.md`
is the upstream skill's own entrypoint, kept for fidelity.

## Conventions for editing skills here

- **Preserve the two-layer split.** Keep upstream godogen stage text faithful to the original; when
  the Manus environment differs, add or update an inline `MANUS OVERRIDE` note and put the
  authoritative rule in `manus-adaptations.md` rather than rewriting the upstream file. Don't blur
  which layer owns a given instruction.
- **Frontmatter is the contract.** A skill is discovered and dispatched via `SKILL.md`'s YAML
  `name`/`description`. Keep the `description` specific about *when* to use the skill (it drives
  automatic selection).
- **Attribution is mandatory for adapted material.** Because `game-dev` reuses godogen under MIT,
  `LICENSE.txt` (full upstream license + copyright) and `NOTICE.md` (what was reused vs. changed)
  must stay present and accurate. If you pull in more upstream content or change what was adapted,
  update `NOTICE.md` to match.
- **Keep the non-negotiable game-dev rules intact** when editing: art is always generated (never
  flat-placeholder-only); deployment is always WebDev Publish; the godogen context files
  (`PLAN.md`, `STRUCTURE.md`, `MEMORY.md`, `ASSETS.md`) are kept in the generated project root for
  resumability; risk slices are built and verified before the main build; and verification trusts the
  screenshot over the code.

## Git workflow

Active development branch for this work: `claude/claude-md-docs-i15omb`. Commit with descriptive
messages and push with `git push -u origin <branch>`. Do not open a pull request unless explicitly
asked.
