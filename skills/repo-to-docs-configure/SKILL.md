---
name: repo-to-docs-configure
description: Interactive setup for the repo-to-docs plugin — writes ~/.config/repo-to-docs/config.json with author details, default license, Typst footer toggles, index-repo publishing targets, and Google Drive settings. Use when the user says "configure repo-to-docs", "set up repo-to-docs", "add a new docs-index target", "change the default license", or is running any repo-to-docs skill for the first time and hits missing config.
---

# repo-to-docs-configure

Create or update `~/.config/repo-to-docs/config.json` interactively.

## Target file

`~/.config/repo-to-docs/config.json`

Schema:

```json
{
  "author_name": "Your Name",
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
      "path": "/absolute/path/to/repo",
      "default": true,
      "gdrive_folder_id": null
    }
  ],
  "gdrive_default_folder_id": null,
  "gdrive_mcp_server": "gws-personal"
}
```

## Procedure

1. Ensure `~/.config/repo-to-docs/` exists (`mkdir -p`).
2. If config file exists, load it and treat each existing value as the default in prompts. Otherwise start from the skeleton above.
3. Walk the user through each field:
   - `author_name`, `author_url`
   - `default_license` (default "MIT")
   - `generate_banner_if_missing` (y/N)
   - `typst_footer_defaults.*` — four independent toggles
   - `index_repos` — offer Add / Edit / Remove / Skip. For each new entry, collect `name`, `path`, `default`, `gdrive_folder_id` (optional).
   - `gdrive_default_folder_id` (optional)
   - `gdrive_mcp_server` (default "gws-personal"; common alternatives: "gws-dsrholdings")
4. Validate:
   - Each `index_repos[].path` must exist. Warn but allow if missing.
   - Warn (don't fail) if `<path>/build-index.sh` is missing — the `repo-to-docs-index` skill will still work but won't rebuild derived indices.
   - Exactly one `index_repos[].default` should be true. Auto-flip if more or none.
5. Write the file with 2-space indentation. Confirm path and print a brief summary.

## Add / remove index repos without full wizard

If the user says "add an index repo X at /path" or "remove index repo X", edit only that entry and save — don't re-prompt other fields.
