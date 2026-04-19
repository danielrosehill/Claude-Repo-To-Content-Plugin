---
name: repo-scan
description: Scan a local Git repository and emit a manifest of its text sources (README, docs/, planning/, report/), embeddable images (diagrams/, graphics/, images/, banner.*), and repo metadata (name, slug, git remote, HEAD commit, derived title and summary). Shared helper invoked by the other repo-to-docs skills before they generate anything. Use when the user asks to "scan this repo for docs", "inventory the repo content", or as a first step before building a PDF, blog post, or white paper from a repository.
---

# repo-scan

Shared helper. Walks a repository on disk and writes a manifest that downstream `repo-to-*` skills consume.

## Inputs

- `path` (optional): path to the repo. Defaults to the current working directory.
- `force` (optional): regenerate even if manifest already exists.

## Output

Writes JSON to `/tmp/repo-to-docs/<slug>/manifest.json`:

```json
{
  "path": "/abs/path/to/repo",
  "slug": "my-repo",
  "name": "My Repo",
  "title": "My Repo",
  "summary": "First paragraph of README, trimmed to ~280 chars.",
  "remote_url": "https://github.com/user/my-repo",
  "head_commit": "abc1234",
  "text_sources": [
    {"path": "README.md", "order": 0, "role": "intro"},
    {"path": "docs/architecture.md", "order": 1, "role": "docs"},
    {"path": "planning/roadmap.md", "order": 2, "role": "planning"},
    {"path": "report/findings.md", "order": 3, "role": "report"}
  ],
  "images": [
    {"path": "diagrams/flow.png", "kind": "diagram"},
    {"path": "banner.png", "kind": "banner"}
  ]
}
```

## Procedure

1. Resolve the repo root. If `path` not given, use cwd. Confirm it's a git repo (warn otherwise — continue anyway).
2. Compute slug = `basename(path)` lowercased, spaces-to-dashes.
3. Gather text sources in reading order:
   - `README.md` first (role: intro)
   - then `docs/**/*.md`, `docs/**/*.txt` sorted alphabetically (role: docs)
   - then `planning/**/*.md` (role: planning)
   - then `report/**/*.md` and `reports/**/*.md` (role: report)
   - skip `CHANGELOG.md`, `LICENSE`, `CONTRIBUTING.md`, `.github/**`, `node_modules/**`, `.venv/**`
4. Gather images: `diagrams/**`, `graphics/**`, `images/**`, plus any top-level `banner.*` (png/jpg/jpeg/webp). Classify banner vs diagram by path.
5. Derive `title` from README first H1 (`# Title`). Fall back to repo basename titlecased.
6. Derive `summary` from first non-heading paragraph of README, trimmed to ~280 chars.
7. Read git metadata: `git -C <path> config --get remote.origin.url` and `git -C <path> rev-parse --short HEAD`.
8. Ensure `/tmp/repo-to-docs/<slug>/` exists; write `manifest.json`.
9. Report the manifest path and a brief summary (title, counts of sources and images).

## Notes

- All downstream skills call this first. If the manifest already exists and `force` is false, just print the existing summary and return.
- Keep this helper fast: no LLM work, no network calls.
