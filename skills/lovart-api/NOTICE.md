# Attribution Notice

This skill (`lovart-api`) is a vendored copy of the **lovart-skill** project by Lovart (lovartai).

- Upstream project: https://github.com/lovartai/lovart-skill
- Upstream path: `skills/lovart-skill/`
- Upstream commit: `3ea0f8e76f9e7b96b6f87969f0ea4f7a1d4cfd30` (2026-09-10)
- Upstream author / copyright holder: Lovart (lovartai)
- Declared license: MIT (declared in the `license:` field of the upstream `SKILL.md` frontmatter)

## What was reused and what was changed

- `SKILL.md` and `scripts/agent_skill.py` are reproduced verbatim from the upstream repository. No modifications.
- `NOTICE.md` (this file) is the only addition.
- The directory was renamed from `lovart-skill` to `lovart-api` to match the skill's own `name: lovart-api` frontmatter field, so that agents that resolve skills by directory name find it under the name it declares.

## License compliance note

The upstream repository declares MIT in the `SKILL.md` frontmatter but, as of commit `3ea0f8e`,
contains **no `LICENSE` file and no copyright notice text**. No MIT license text has been
fabricated here. Before redistributing this skill outside a personal repository, request the
full license text and copyright line from the upstream author, or confirm the license from an
authoritative source and add a `LICENSE.txt` alongside this notice.

"Lovart" is referenced for attribution and interoperability purposes only; this skill is not
affiliated with or endorsed by the upstream author.

## Prerequisites

The skill calls the Lovart platform API and requires credentials in the environment:

```bash
export LOVART_ACCESS_KEY="ak_xxx"
export LOVART_SECRET_KEY="sk_xxx"
```

Obtain the AK/SK from the Lovart platform (avatar menu -> AK/SK management).
`python3` must be on PATH; the script uses only the Python standard library.
