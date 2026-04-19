---
name: repo-to-pdf
description: Convert a GitHub repository's content (README, docs/, planning/, diagrams) into a polished public-facing PDF via Typst, with an optional AI-generated cover banner and configurable footer (repo URL, license, author). Use when the user says "turn this repo into a PDF", "generate a public PDF from this repository", "build a doc PDF", "make a PDF from the README and docs", or similar requests to produce a shareable PDF snapshot of a repo.
---

# repo-to-pdf

Consolidated, public-facing PDF of a repository's documentation. Single-document output suitable for sharing, archiving, or publishing.

## Inputs

- `path` (optional): repo path; defaults to cwd.
- `title` (optional): override the derived title.
- `subtitle` (optional): tagline shown under the title.
- `output` (optional): output PDF path. Default: `./<slug>.pdf`.
- `license` (optional): overrides config default.
- `banner` (optional): path to a banner image; overrides scan result. Pass `"none"` to disable.
- `no-banner` (optional flag): force-disable banner even if one exists in the repo.

## Procedure

### 1. Load manifest
If `/tmp/repo-to-docs/<slug>/manifest.json` is missing or the user passed `--force`, invoke the `repo-scan` skill first. Otherwise read the existing manifest.

### 2. Load config
Read `~/.config/repo-to-docs/config.json`. If missing, use these defaults:

```json
{
  "author_name": "",
  "author_url": "",
  "default_license": "MIT",
  "generate_banner_if_missing": false,
  "typst_footer_defaults": {
    "show_page_numbers": true,
    "show_repo_url": true,
    "show_license": true,
    "show_author": true
  }
}
```

### 3. Resolve banner
- If `banner` argument is a path, use it.
- Else if manifest has an image with `kind: banner`, use it.
- Else if `generate_banner_if_missing` is true and not disabled by flag, call the `nano-tech-diagrams` MCP `text_to_image` tool with:
  - prompt: `"Technical documentation banner for '{title}' — {summary}. Clean minimalist style, suitable for PDF cover."`
  - save to `/tmp/repo-to-docs/<slug>/banner.png`
- Else leave unset (no banner).

### 4. Assemble Typst document
Create scratch dir `/tmp/repo-to-docs/<slug>/build/`, copy in `shared/styles.typ` from the plugin.

Write `main.typ`:

```typst
#import "styles.typ": doc-base, ai-disclosure-block

#show: doc-base.with(
  title: "{{title}}",
  subtitle: {{subtitle_or_none}},
  author: "{{author}}",
  date: datetime.today(),
  repo-url: {{repo_url_or_none}},
  license: "{{license}}",
  show-page-numbers: {{show_page_numbers}},
  show-license: {{show_license}},
  show-repo-url: {{show_repo_url}},
  show-author: {{show_author}},
  banner-path: {{banner_or_none}},
  show-toc: true,
  toc-depth: 2,
)

// Body — concatenated from text_sources in manifest order.
// Each markdown source becomes a level-1 section; raw paragraphs pass through.
// Images referenced in markdown are copied in and rendered at their reference point.
```

Convert each markdown source to Typst (pandoc `markdown -> typst`, or a simple transform for headings, paragraphs, lists, code, images). Rewrite image paths to the build dir. Copy referenced images into the build dir. Images not referenced inline are appended at the end of their source's section.

### 5. Compile
```bash
/usr/local/bin/typst compile /tmp/repo-to-docs/<slug>/build/main.typ <output>
```

Fall back to `typst` on PATH if the absolute path is missing.

### 6. Report
- Output path
- Page count (via `pdfinfo` if available)
- Which banner was used (existing / generated / none)
