# repo-to-docs

Convert a GitHub repository's content (README, docs/, planning/, diagrams, images) into polished, publishable documents via [Typst](https://typst.app). Supports multiple output formats and publishing targets.

## Skills

| Skill | Purpose |
|-------|---------|
| `repo-scan` | Shared helper. Walks a repo and emits a manifest of text sources, images, and metadata. |
| `repo-to-pdf` | Generate a public-facing PDF from a repo, with optional AI-generated banner. |
| `repo-to-internal-doc` | Generate a private/internal PDF — no repo URL, no license line, optional CONFIDENTIAL header. |
| `repo-to-blog-post` | Synthesize a markdown blog post (intro / body / conclusion) from the repo. |
| `repo-to-white-paper` | Produce a structured long-form white paper PDF. |
| `repo-to-docs-index` | Publish a generated file into a configured docs-index repo and push. |
| `repo-to-gdrive` | Upload a generated file to Google Drive via the configured GWS MCP. |
| `repo-to-docs-configure` | Interactive setup for `~/.config/repo-to-docs/config.json`. |

## Install

```bash
claude plugins install repo-to-content@danielrosehill
```

After installing, restart Claude Code so the skills are registered.

## Configure

Run the configure skill, or hand-edit `~/.config/repo-to-docs/config.json`.

Example config:

```json
{
  "author_name": "<Your Name>",
  "author_url": "https://example.com",
  "default_license": "MIT",
  "generate_banner_if_missing": false,
  "typst_footer_defaults": {
    "show_page_numbers": true,
    "show_repo_url": true,
    "show_license": true,
    "show_author": true
  },
  "index_repos": [
    {
      "name": "public",
      "path": "~/repos/Public-Docs",
      "default": true,
      "gdrive_folder_id": null
    }
  ],
  "gdrive_default_folder_id": null,
  "gdrive_mcp_server": "gws-personal"
}
```

All defaults are example values — set them to your own name, URL, and paths.

## How it works

Skills chain via a shared manifest at `/tmp/repo-to-docs/<slug>/manifest.json`. The entry-point skills (e.g. `repo-to-pdf`) invoke `repo-scan` first if the manifest is missing. Typst compilation uses `shared/styles.typ` for consistent styling across all output formats.

## Requirements

- [Typst](https://github.com/typst/typst) at `/usr/local/bin/typst` (or adjust the skill).
- IBM Plex Sans font (falls back to system sans).
- Optional: an MCP that exposes `text_to_image` for AI banners (the skills default to `nano-tech-diagrams`).
- Optional: a Google Workspace MCP (`gws-personal` or similar) for Drive uploads.

## License

MIT — see [LICENSE](./LICENSE).
