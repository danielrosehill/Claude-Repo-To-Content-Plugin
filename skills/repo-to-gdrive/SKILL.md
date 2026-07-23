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
4. **Stage the file via MinIO.** The GWS MCP runs on `residencehome` — it cannot read workstation paths like `/home/daniel/...`. Translate the local path to a presigned URL first:
   ```bash
   python3 ~/.claude/lib/minio-stage.py /absolute/local/path/file.pdf --expires 3600
   # → {"url":"http://10.0.0.2:9100/mcp-staging/<uuid>/file.pdf?X-Amz-...",...}
   ```
5. Invoke the appropriate MCP upload tool (`mcp__gateway__google-workspace-personal__create_drive_file` or `mcp__gateway__google-workspace-dsrh__create_drive_file`) with:
   - `sourceUrl`: the MinIO presigned URL from step 4 — **never** a raw workstation path.
   - `parents`: `[<folder-id>]`
   - `name`: optional target filename
6. On success, report Drive file ID, `webViewLink`, and target folder.
7. On failure, surface the MCP error message and suggest verifying the MCP server is enabled (`claude mcp list`).

**Do NOT** fall back to `rclone`, `scp`, `gcloud`, `gdrive`, direct Drive API `curl`, or any other workaround when the upload fails. MinIO staging + `sourceUrl` is the only supported route from this workstation. If staging fails, fix that — don't route around it. The `mcp-staging` bucket on `10.0.0.2:9100` self-cleans after 1 day.

## Notes

- The plugin does not implement Drive auth itself — it relies on whatever GWS MCP server the user has configured.
- This skill never modifies the source file or generates content — it's a thin upload wrapper.
