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
   1. Presign a PUT URL via the `minio` MCP (gateway namespace):
      `minio__presign_url(bucket="personal-transient", key="staging/file.pdf", method="put", expires=1800)`
   2. Upload from the workstation:
      ```bash
      curl -sSf -X PUT -T /local/path/to/file.pdf -H "Content-Type: application/pdf" "<put-url>"
      ```
   3. Presign a GET URL for the server to fetch:
      `minio__presign_url(bucket="personal-transient", key="staging/file.pdf", method="get", expires=3600)`
   (Business destination → bucket `dsrholdings-transient`.)
5. Invoke the appropriate MCP upload tool (`mcp__gateway__google-workspace-personal__create_drive_file` or `mcp__gateway__google-workspace-dsrh__create_drive_file`) with:
   - `fileUrl`: the MinIO presigned GET URL from step 4 — **never** a raw workstation path.
   - `folder_id`: `<folder-id>`
   - `file_name`: target filename
6. On success, report Drive file ID, `webViewLink`, and target folder.
7. On failure, surface the MCP error message and suggest verifying the MCP server is enabled (`claude mcp list`).

**Do NOT** fall back to `rclone`, `scp`, `gcloud`, `gdrive`, direct Drive API `curl`, or any other workaround when the upload fails. MinIO staging + `fileUrl` is the only supported route from this workstation. If staging fails, fix that — don't route around it. The `*-transient` staging buckets at `https://s3.residencejlm.com` self-clean after 1 day.

## Notes

- The plugin does not implement Drive auth itself — it relies on whatever GWS MCP server the user has configured.
- This skill never modifies the source file or generates content — it's a thin upload wrapper.
