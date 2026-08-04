# Claude Code Adaptations Layer

This file defines exactly how godogen's canonical pipeline runs inside Claude Code.
Read it together with `references/godogen-stages/*` (godogen's stage instructions).
Where this file conflicts with a godogen stage file, this file wins — because it
adapts godogen to this environment.

godogen was designed for a local machine with Node, a browser, and a shell.
Claude Code has all three, so most of godogen applies unchanged. Only three
things need adapting: **art generation** (godogen's paid CLIs are not available),
**screenshot capture** (use the pre-installed Chromium), and **delivery** (there
is no managed hosting step).

Layering principle: **the page = picture frame, Babylon = canvas, godogen game code = the painting.**

---

## 1. Host shell: godogen's own Vite scaffold

Use godogen's standalone Vite + TypeScript shell as described in
`references/godogen-stages/scaffold.md`. It is the right host here: it starts in
seconds, hot-reloads, and needs no framework.

1. Scaffold the file set from `scaffold.md` (`index.html`, `package.json`, `tsconfig.json`, `vite.config.ts`, `src/main.ts`, `src/app/BabylonApp.ts`, `src/app/babylon.ts`, `src/game/scene.ts`).
2. `npm install`, then `npm i @babylonjs/core` (and `@babylonjs/loaders` only if loading GLB models).
3. Start the dev server as a **background** Bash command:
   ```bash
   npm run dev -- --host 127.0.0.1 --port 5173
   ```
   Keep it running for the whole session. Poll `curl -sf http://127.0.0.1:5173 >/dev/null` to know when it is up — never `sleep` to wait for it.
4. Put all gameplay in `src/game/**` as plain TS classes — zero framework coupling. This is where godogen's modules (GameWorld, Player, ObstacleManager, etc.) live.

### Canvas contract (non-negotiable)
- Initialize the `Engine` exactly once, against `canvas#game-canvas`.
- Give the canvas a real size in CSS (`position: fixed; inset: 0; width: 100%; height: 100%; display: block`). Babylon on a zero-height canvas renders nothing, and the resulting blank screenshot looks like a gameplay bug.
- Handle `window.resize` → `engine.resize()`.
- Start `engine.runRenderLoop` after the scene resolves; stop it and `engine.dispose()` on teardown.
- Remove every event listener you added.
- `src/game/scene.ts` must export `createScene(app)` per `scaffold.md`.

### Optional: hosting inside an existing React app
Only when the user needs the game embedded in a React project, use
`templates/GameCanvas.tsx` instead of the bare shell. Then gameplay lives in
`src/game/**` of that project and the extra rule is: guard engine init with a ref
flag so React StrictMode's double-mount does not create two engines on one canvas.

### Import paths
Import Babylon from deep paths to keep bundles lean, e.g.
`import { Engine } from "@babylonjs/core/Engines/engine";`
`import { Scene } from "@babylonjs/core/scene";`
Use side-effect imports for features actually used (e.g. `@babylonjs/core/Materials/standardMaterial`).

---

## 2. Art step: image-generation MCP (MANDATORY — never skip)

godogen's `asset-planner.md` / `asset-gen.md` call paid Gemini / xAI Grok /
Tripo3D CLIs. Those are not available here. Use a connected image-generation MCP
instead — Higgsfield is the expected one:

| godogen tool | Use instead |
| :--- | :--- |
| Gemini / Grok image CLI | `generate_image` (or `generate_image_batch` for several at once) |
| `rembg` background removal | prompt for a transparent background, else `remove_background` |
| Tripo3D image→3D | `generate_3d` (image → GLB) |
| upscaling | `upscale_image` |

The art step is mandatory: every game gets real generated art direction, never a
silent "no art" fallback. **If no image-generation MCP is connected, stop and tell
the user** — do not quietly ship untextured primitives and call it done.

Workflow:
1. **visual-target stage** → generate a reference image that defines art direction (palette, mood, perspective, density). Save it under `assets/reference/` and record the prompt in `ASSETS.md`.
2. **asset-gen stage** → for each asset in the plan (sprites, textures, tiles, props, backgrounds, character art, UI art), generate an image. For transparency, prompt for a clean transparent/cutout background; fall back to `remove_background` only if generation cannot produce clean alpha.
3. **Wire assets into the game**:
   - Download the generated PNGs to `public/assets/` in the project.
   - Reference them by root-relative URL: `new Texture("/assets/tile.png", scene)`. Vite serves `public/` verbatim in dev and copies it into `dist/` on build, so the same path works in both.
   - Keep source-resolution originals out of `public/` (use `assets/` at the project root, gitignored if large) and ship only the sizes the game actually samples.
4. **3D models (GLB)**: default to **procedural meshes textured with generated images** (boxes/planes/extrusions + generated textures) — cheaper, faster, and easier to iterate. Use `generate_3d` for a real GLB only when a photoreal or organic mesh is genuinely required, and load it via `@babylonjs/loaders`.

Budget note: godogen gates asset generation behind a dollar "budget". Generation
here still costs the user credits, so keep the default asset set small and
purposeful; scale up only if the user asks.

---

## 3. Verification: headless Chromium from Bash

godogen's `capture.md` uses `scripts/capture.mjs` (Playwright) against a local
server. That approach works here as-is — the only change is **use the
pre-installed browser, never download one.**

- Chromium is at `/opt/pw-browsers/chromium`, and `PLAYWRIGHT_BROWSERS_PATH=/opt/pw-browsers` is already set. **Do not run `playwright install`.** If a pinned `@playwright/test` version cannot find it, launch with `executablePath: '/opt/pw-browsers/chromium'`.
- Set `CHROME_BIN=/opt/pw-browsers/chromium` before running `scripts/capture.mjs` so godogen's script picks it up.
- Screenshot the already-running dev server at `http://127.0.0.1:5173` rather than starting a second one.
- For autoplay verification, add a `?demo` flag that drives a deterministic AutoPilot (port godogen's demo brain) so screenshots show real gameplay without manual input.
- Read the screenshot back with the Read tool and actually look at it. This honors godogen's core law: **trust the picture, not the code; if a requirement is not visible, it is unfinished.**
- Type-check and build with `npm run check` and `npm run build`.
- The dev server's background output is the log source; grep/tail it for runtime errors rather than re-reading it whole.

### Software rendering is expected
godogen warns loudly when WebGL2 falls back to a software renderer (SwiftShader,
llvmpipe, lavapipe, softpipe, mesa offscreen) and tells you to fix the GPU path.
**That warning does not apply here.** This environment has no GPU; software
rendering is the normal case and is sufficient for verification. Expect low
framerates in capture, not wrong pixels. Do not spend time "fixing" it. If
Chromium or WebGL2 is genuinely missing, report that clearly instead of
improvising around it.

---

## 4. Delivery: build and commit (no automatic deploy)

There is no managed publish step in this environment, and deploying is
outward-facing. So:

1. Confirm `npm run check` and `npm run build` are clean.
2. Commit the project: source, `index.html`, config, and `public/assets/`. Never commit `node_modules/` or `dist/` — add a `.gitignore` if the scaffold lacks one.
3. Hand off with the exact run instructions (`npm install && npm run dev`) and the screenshots that prove it works.
4. **Deploy only when the user asks.** When they do, the built `dist/` is a static bundle that any static host takes (GitHub Pages, Netlify, Cloudflare Pages). If a game-hosting MCP is connected (e.g. Higgsfield `deploy_game` / `publish_game`), that is a valid route too — still only on request.

---

## 5. Context files (keep godogen fidelity)

Keep these in the project root so the pipeline is resumable and faithful:
- `PLAN.md` — tasks + verification criteria + risk slices.
- `STRUCTURE.md` — architecture reference.
- `MEMORY.md` — discoveries, quirks, what worked/failed.
- `ASSETS.md` — generated-asset manifest with prompts + the `public/assets/...` paths they landed at.

On resume: if `PLAN.md` exists, read PLAN/STRUCTURE/MEMORY/ASSETS and skip to task execution (same as godogen).
