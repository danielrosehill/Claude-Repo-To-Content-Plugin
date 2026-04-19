---
name: repo-to-docs-index
description: Publish an already-generated PDF (or other file) into a configured docs-index repository — copies it into a YY/MM/DD/<slug>/ folder, writes meta.json, runs the repo's build-index.sh if present, then commits and pushes. Use when the user says "publish this PDF to my docs index", "push this document to the public docs repo", "add this to my docs-index", or after running repo-to-pdf/white-paper and wanting to publish it.
---

# repo-to-docs-index

Publishes a generated file into a target docs-index repository following a `YY/MM/DD/<slug>/` convention.

## Inputs

- `file` (required): absolute path to the file to publish (usually a PDF).
- `target` (optional): name of the index repo in config (see `index_repos[].name`). Defaults to the entry with `"default": true`.
- `title` (optional): override — defaults to filename stem titlecased or manifest title.
- `summary` (optional): override — defaults to manifest summary.
- `tags` (optional): list of tags. Defaults to `[]`.
- `extra_files` (optional): additional files to include in the entry folder.

## Target repo contract

Each configured `index_repos[]` entry must point at a directory that is:

- A git repository (push-capable, i.e. a remote configured).
- Layout: entries at `YY/MM/DD/<slug>/` with at minimum a `meta.json`.
- Has `build-index.sh` at root that rebuilds any derived indices/README from the `meta.json` files. Optional but recommended.

Daniel's `danielrosehill/Public-Docs` is the canonical example.

## Procedure

1. Load config from `~/.config/repo-to-docs/config.json`.
2. Resolve target repo entry. Fail with a clear error if no default and no `target` specified.
3. Verify target path exists and is a git repo. If not, abort with actionable message.
4. Compute today's date parts (YY, MM, DD) and destination folder:
   `<target.path>/<YY>/<MM>/<DD>/<slug>/`
   where `slug` is derived from the filename stem (sanitized).
5. Create the folder. Copy `file` and any `extra_files` into it.
6. Write `meta.json`:
   ```json
   {
     "title": "...",
     "summary": "...",
     "date": "YYYY-MM-DD",
     "tags": ["..."],
     "source_url": "<remote_url from manifest, or null>",
     "files": ["filename.pdf"]
   }
   ```
7. If `<target>/build-index.sh` exists, run it (`bash ./build-index.sh` from the target repo root). If it doesn't exist, warn but continue.
8. Git stage, commit, push:
   ```bash
   git -C <target> add -A
   git -C <target> commit -m "Add: <title> (<YYYY-MM-DD>)"
   git -C <target> push
   ```
9. Report:
   - Target repo name + path
   - Entry folder (relative to repo root)
   - Commit hash
   - Whether `build-index.sh` ran
