---
name: generate-pdf-from-outputs
description: Use when the user wants to generate a styled PDF from repository outputs using Typst with IBM Plex Sans and a clean brand palette. Triggers on phrases like "generate a PDF", "make a PDF from outputs", "typst PDF", "pdf this".
---

Generate a PDF from the outputs the user specifies (feel free to suggest obvious candidates).

## Styling

- **Engine:** Typst
- **Font:** IBM Plex Sans
- **Text color:** black (or very close)
- **Default accent palette** (override via plugin config — see below):
  - `#2B304D` (deep indigo)
  - `#F58258` (coral)
  - `#AA697D` (rosewood)
  - `#5F4FA2` (purple)

To override, read `repo-to-content` plugin config per `claude-rudder:plugin-data-storage` (key `pdf.palette`, an array of hex colors).

## Footer elements

- Page number (center aligned)
- Today's date in `DD/MM/YY` format
- Attribution: `Document: <author>` (resolve `<author>` from git config `user.name` or plugin config key `pdf.author`)
- For open source projects: `License: MIT`
