---
name: game-dev
description: "Build playable browser games (Babylon.js) end-to-end using the godogen production pipeline, adapted to Claude Code. Use when the user wants to make, generate, rebuild, or substantially extend a web/browser game from a natural-language brief. Runs godogen's staged workflow (visual target, risk decomposition, scaffold, architecture, asset generation, implementation, visual verification) on a local Vite + Babylon project, verifies with headless Chromium screenshots, and generates art through an image-generation MCP instead of godogen's paid Gemini/Grok/Tripo3D CLIs."
license: Complete terms in LICENSE.txt
---

# Game Dev

Build complete, playable Babylon.js browser games from a natural-language brief,
following the **godogen** production pipeline, running natively in Claude Code.

godogen's original design — a local Vite + TypeScript project, a long-lived dev
server, and Chromium screenshot capture — maps directly onto what Claude Code
already has (Bash, a filesystem, and a pre-installed Chromium). So this skill
keeps godogen's pipeline nearly intact and adapts only what genuinely differs:

1. **Art** → an image-generation MCP (Higgsfield `generate_image` / `remove_background` / `generate_3d`), replacing godogen's paid Gemini / Grok / Tripo3D CLIs. The art step is **mandatory, never skipped**.
2. **Verification** → headless Chromium driven from Bash, using the pre-installed browser rather than downloading one.
3. **Delivery** → a built, committed, runnable project. There is no managed publish step; deployment is the user's call.

Layering principle to keep in mind throughout: **the page = picture frame, Babylon = canvas, godogen game code = the painting.**

## Resources in this skill

- `references/claude-code-adaptations.md` — **read this first.** Exact rules for the local host project, the image-generation art step, screenshot verification, and delivery. Overrides godogen stage files where they conflict.
- `references/godogen-stages/*.md` — godogen's stage instructions (`visual-target`, `decomposer`, `architecture`, `scaffold`, `asset-planner`, `asset-gen`, `rembg`, `task-execution`, `quirks`, `scene-generation`, `capture`, plus `godogen-skill-overview.md`), reproduced substantially verbatim with inline `CLAUDE CODE OVERRIDE` notes where this environment differs. Read each stage file only when you reach that stage.
- `templates/GameCanvas.tsx` — optional. The Babylon-in-React integration component (single full-screen canvas, lifecycle-safe). Use it **only** when the game must live inside an existing React app; the default host is godogen's plain Vite shell, which needs no React.

## Pipeline (godogen, adapted)

Follow these stages in order. On resume, if `PLAN.md` already exists in the project, read `PLAN.md`/`STRUCTURE.md`/`MEMORY.md`/`ASSETS.md` and skip to task execution.

1. **Scaffold the host.** Read `references/godogen-stages/scaffold.md` and build godogen's Vite + TypeScript shell (`index.html` with `canvas#game-canvas`, `src/main.ts`, `src/app/BabylonApp.ts`, `src/game/scene.ts`). `npm install`, `npm i @babylonjs/core` (add `@babylonjs/loaders` only for GLB). Start `npm run dev` as a **background** Bash command and keep it alive for the whole session. See `references/claude-code-adaptations.md` §1.
2. **Visual target.** Read `references/godogen-stages/visual-target.md`. Generate a reference image that defines art direction and save it under `assets/`. Record it in `ASSETS.md`. (Art step is mandatory — see §2 of adaptations.)
3. **Decompose + risks.** Read `references/godogen-stages/decomposer.md`. Write `PLAN.md` with risk slices and verification criteria. Isolate high-risk features first (procedural generation/animation, sprite animation, vehicle physics, custom shaders, runtime geometry, dynamic navigation, complex cameras, pointer-lock, GLB import pipelines); everything else is main build.
4. **Architecture.** Read `references/godogen-stages/architecture.md`. Keep gameplay as plain TS classes under `src/game/` (GameWorld, Player, managers, etc.), framework-agnostic. Write `STRUCTURE.md`.
5. **Assets.** Read `references/godogen-stages/asset-planner.md` + `asset-gen.md` for *what* to plan, but generate via the image MCP (adaptations §2). Save PNGs into `public/assets/` and reference them by root-relative URL (`new Texture("/assets/x.png", scene)`). Default to procedural meshes + generated textures; use `generate_3d` for GLB only when a real mesh is essential. Maintain `ASSETS.md`.
6. **Implement.** Read `references/godogen-stages/task-execution.md`, `quirks.md`, and `scene-generation.md`. Build risk slices first, then the main build. Inner loop: edit `src/game/**` → Vite HMR → screenshot → check.
7. **Verify (trust the picture).** Screenshot the running dev server with headless Chromium (adaptations §3). Add a `?demo` deterministic AutoPilot so screenshots show real gameplay. Run `npm run check` and `npm run build`. If a requirement is not visible in a screenshot, it is unfinished. When code and picture disagree, trust the picture.
8. **Deliver.** Confirm `npm run build` is clean, commit the project (source + `public/assets/`, not `node_modules/` or `dist/`), and hand off with the run instructions. See adaptations §4 for deployment options — do not deploy anywhere without the user asking.

## Non-negotiable rules

- **Art is mandatory and uses the image-generation MCP.** Never silently skip art or ship only flat placeholder colors. Procedural geometry is fine, but art direction must come from a generated reference and generated textures/assets. If no image MCP is connected, say so and ask the user how to proceed instead of quietly shipping untextured primitives.
- **Verify with a real screenshot of the running game.** Not by reading the code, not by asserting it works.
- **Keep godogen context files** (`PLAN.md`, `STRUCTURE.md`, `MEMORY.md`, `ASSETS.md`) in the project root for fidelity and resumability.
- **Preserve godogen philosophy:** risk slices first, read stage files on demand, and verify visually.
- **Never deploy or publish without an explicit request.** Building and committing is the default deliverable.

## Quirks worth front-loading

- Run the dev server as a background Bash command. Never block a foreground call on it, and never `sleep` to wait for it — poll the port instead.
- Babylon needs a non-zero-size canvas. Give the canvas an explicit full-viewport size in CSS; a zero-height canvas renders a blank screenshot and looks like a logic bug.
- Import Babylon from deep module paths (`@babylonjs/core/Engines/engine`) to keep the bundle small, plus side-effect imports for the features actually used.
- Headless Chromium here usually runs a **software renderer** (SwiftShader/llvmpipe). That is fine for verification — expect slow frames, not wrong pixels. Do not chase a "GPU misconfiguration" that this environment cannot have.
- Assets belong in `public/assets/` so Vite serves them as-is. Importing large binaries through the module graph bloats the bundle.
- If using `templates/GameCanvas.tsx` inside React: React StrictMode mounts effects twice in dev, so guard Babylon engine init with a ref flag or you get two engines on one canvas.
