#!/usr/bin/env bash
# md2epub.sh <in.md> [out.epub] [--author NAME] [--cover IMG]
# Markdown (pandoc, YAML front matter honoured) -> reflowable EPUB 3 for phone reading.
# Needs pandoc >= 2.19. One chapter per top-level heading, TOC to depth 2.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
in="$1"; shift
out="${1:-${in%.md}.epub}"; [[ "${1:-}" == --* || -z "${1:-}" ]] || shift
args=()
while [[ $# -gt 0 ]]; do case "$1" in
  --author) args+=(--metadata "author=$2"); shift 2;;
  --cover) args+=(--epub-cover-image "$2"); shift 2;;
  *) echo "unknown arg $1" >&2; exit 2;; esac; done
# strip HTML comments (placeholders) so they don't leak into the book
tmp="$(mktemp --suffix=.md)"; trap 'rm -f "$tmp"' EXIT
perl -0pe 's/<!--.*?-->//gs' "$in" > "$tmp"
pandoc "$tmp" -f markdown -t epub3 -o "$out" \
  --css "$here/epub.css" --toc --toc-depth=2 --split-level=1 \
  --metadata lang=en-GB --resource-path="$(dirname "$in")" "${args[@]}"
echo "$out"
