---
name: repo-to-gdrive
description: Upload a generated document (PDF, markdown, etc.) to Google Drive via the configured Google Workspace MCP server (gws-personal by default, gws-dsrholdings or other overridable). Use when the user says "upload this PDF to Drive", "send this doc to Google Drive", "put this in my Drive folder", or after generating a document and wanting to distribute it via Google Drive.
---

# repo-to-gdrive

Upload a single file to Google Drive via an MCP tool.

## Inputs

- `file` (required): absolute path to the file to upload.
- `folder_id` (optional): target Drive folder ID. Resolution order:
  1. Explicit `folder_id` arg
  2. Per-index-repo `gdrive_folder_id` (if invoked after `repo-to-docs-index`)
  3. Config `gdrive_default_folder_id`
  4. Prompt the user
- `name` (optional): name to use on Drive. Defaults to local filename.
- `mcp_server` (optional): MCP server key (default: config `gdrive_mcp_server`, itself defaulting to `gws-personal`).

## Procedure

1. Load config from `~/.config/repo-to-docs/config.json`.
2. Resolve MCP server: prefer `mcp_server` arg, then `config.gdrive_mcp_server`, then `"gws-personal"`.
3. Resolve `folder_id` via the order above. If prompting, show the user the available configured folders.
4. Invoke the appropriate MCP upload tool. The expected tool name pattern is `<mcp_server>__upload_file` (common variants: `gws-personal`, `gws-dsrholdings`). Typical arguments:
   - `file_path`: absolute path to the local file
   - `folder_id`: Drive folder ID
   - `name`: optional target filename
5. On success, report:
   - Drive file ID
   - Drive web link (if returned)
   - Target folder (ID + name if the MCP resolves it)
6. On failure, surface the MCP error message and suggest verifying the MCP server is enabled (`claude mcp list`).

## Notes

- The plugin does not implement Drive auth itself — it relies on whatever GWS MCP server the user has configured.
- This skill never modifies the source file or generates content — it's a thin upload wrapper.
