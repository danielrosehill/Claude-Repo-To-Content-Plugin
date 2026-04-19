---
name: repo-to-blog-post
description: Synthesize a concise, first-person, technical blog post (markdown, with frontmatter) from a GitHub repository's README, docs, and planning files. Writes intro / body / conclusion in a no-marketing-fluff voice. Use when the user says "turn this repo into a blog post", "draft a blog post about this project", "write up this repo as an article", or wants a publishable narrative of the repository.
---

# repo-to-blog-post

Generate a markdown blog post that explains what the repository is, why it exists, and what was built.

## Inputs

- `path` (optional): repo path; defaults to cwd.
- `output` (optional): output markdown path. Default: `./<slug>-blog-post.md`.
- `tone` (optional): default "concise, first-person, technical". Accept overrides.

## Procedure

1. Invoke `repo-scan` if manifest missing.
2. Read the key text sources from the manifest — prioritise README, then top-level docs. Limit total input to roughly the first ~8K tokens worth of content to stay focused.
3. Synthesize the post with three sections:
   - **Intro** — what prompted the project, the problem being solved, in 1–2 paragraphs.
   - **Body** — key design decisions, interesting bits, what was built. Pull direct content from README/docs where useful. Use subheadings sparingly.
   - **Conclusion** — status, what's next, how to try it (link to the repo via `remote_url` from manifest).
4. Generate a title (short, specific, no buzzwords) and three tags (lowercase, hyphenated).
5. Write markdown with frontmatter:

```markdown
---
title: "<generated title>"
date: <today YYYY-MM-DD>
tags: [tag-1, tag-2, tag-3]
source_repo: <remote_url>
---

<body>
```

6. Save to `output`. Print the path and the generated title.

## Voice guidelines

- First person ("I built...", "I wanted...").
- No marketing fluff ("revolutionary", "seamless", "unleash").
- Technical specifics over vague claims.
- Short paragraphs. No filler transitions.
- Code fences only where code illustrates a point.
