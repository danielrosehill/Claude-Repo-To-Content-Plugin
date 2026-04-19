---
name: repo-to-white-paper
description: Produce a structured long-form white paper PDF (Executive Summary, Background, Methodology, Findings, Recommendations, References) from a GitHub repository's documentation. Uses the same Typst template as repo-to-pdf but with deeper TOC and formal section structure. Use when the user says "generate a white paper from this repo", "make a long-form report from this project", "turn this research repo into a formal paper", or wants structured long-form output.
---

# repo-to-white-paper

Formal, structured long-form PDF. Good for research projects, methodology write-ups, or anything that benefits from a defined section skeleton.

## Inputs

- `path` (optional): repo path; defaults to cwd.
- `title`, `subtitle` (optional): overrides.
- `output` (optional): default `./<slug>-whitepaper.pdf`.
- `license` (optional): overrides config default.
- `banner` / `no-banner` (optional).

## Sections (required)

1. **Executive Summary** — 1-paragraph overview.
2. **Background** — context and prior work; draw from README intro + any `background.md` or `context/*.md`.
3. **Methodology** — approach taken; draw from `planning/`, `methodology.md`, or architecture docs.
4. **Findings** — results; draw from `report/`, `reports/`, `findings.md`, or conclusions in docs.
5. **Recommendations** — next steps, implications.
6. **References** — any URLs or citations encountered in source files.

## Procedure

1. Invoke `repo-scan` if manifest missing.
2. Load config.
3. For each required section, map relevant text_sources:
   - If a matching source exists, use its content (lightly edited for flow).
   - If none exists for a section, prompt the user: "No source content found for Methodology. Leave placeholder, skip section, or would you like to supply a file?"
4. Assemble Typst with `doc-base` using `toc-depth: 2`.
5. Include an `ai-disclosure-block` near the end if the content was substantially AI-synthesized.
6. Compile via `/usr/local/bin/typst compile`.
7. Report output path + which sections were placeholders / skipped.

## Typst scaffold shape

```typst
#import "styles.typ": doc-base, ai-disclosure-block
#show: doc-base.with(
  title: "{{title}}",
  subtitle: "White Paper",
  author: "{{author}}",
  repo-url: {{repo_url_or_none}},
  license: "{{license}}",
  banner-path: {{banner_or_none}},
  toc-depth: 2,
)

= Executive Summary
...
= Background
...
= Methodology
...
= Findings
...
= Recommendations
...
= References
...
```
