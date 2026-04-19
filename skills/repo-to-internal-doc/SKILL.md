---
name: repo-to-internal-doc
description: Generate a private or internal-use PDF from a repository — same Typst engine as repo-to-pdf, but with no repo URL in the footer, no license line, and an optional CONFIDENTIAL header. Default output to ~/Documents/internal-docs/. Use when the user says "make an internal PDF from this repo", "generate a confidential doc from this repository", "private PDF for internal use", or wants a repo-based document they are not publishing publicly.
---

# repo-to-internal-doc

Same engine as `repo-to-pdf`, but with privacy-preserving defaults for internal distribution.

## Inputs

- `path` (optional): repo path; defaults to cwd.
- `title`, `subtitle` (optional): overrides.
- `output` (optional): default `~/Documents/internal-docs/<slug>-<YYYY-MM-DD>.pdf`.
- `confidential` (optional flag): add "CONFIDENTIAL" bold in header-left.
- `header-left` (optional): custom header text (e.g. "INTERNAL — Do Not Distribute").
- `banner` / `no-banner` (optional): as per `repo-to-pdf`.

## Procedure

1. Invoke `repo-scan` if manifest missing.
2. Load config from `~/.config/repo-to-docs/config.json`.
3. Resolve output path — if directory doesn't exist, create it (`mkdir -p`).
4. Assemble Typst document exactly like `repo-to-pdf`, but with these overrides on `doc-base`:
   - `repo-url: none`
   - `show-repo-url: false`
   - `show-license: false`
   - `header-left: "CONFIDENTIAL"` (if `confidential` flag) or the user-provided `header-left`
   - `header-bold: true` when confidential
5. Compile via Typst.
6. Report output path. Do NOT log or report the repo URL.

## Privacy notes

- Do not write the repo URL, git remote, or other external pointers into the PDF.
- The banner, if used, still renders. If the user needs no banner at all for privacy, pass `--no-banner`.
- This skill never publishes to any index repo or cloud target — output is a local file only.
