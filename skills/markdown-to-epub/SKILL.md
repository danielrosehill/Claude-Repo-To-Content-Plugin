---
name: markdown-to-epub
description: Turn a markdown document (report, guide, analysis, notes) into a reflowable EPUB for reading on a phone or e-reader, alongside or instead of a PDF. Use when the user says "make it an ebook", "EPUB", "MOBI", "something I can read on my phone", "Kindle version", or finds a dense PDF hard to read on mobile.
---

# Markdown to EPUB

PDFs are fixed pages: on a phone, dense text means pinch-zooming. EPUB reflows to the
screen, and the reader app controls font, size, margins and night mode. Use it for any
long text a person will *read*; keep PDF for things to print, sign or share as a fixed record.

**MOBI is obsolete.** Amazon stopped accepting MOBI for Send to Kindle in 2022 and
now takes EPUB directly. When someone asks for "MOBI", make an EPUB and say so in one line.
Only make AZW3/MOBI if they name an old Kindle that can't take EPUB (needs Calibre's
`ebook-convert in.epub out.azw3`).

## Build

```bash
skills/markdown-to-epub/scripts/md2epub.sh <in.md> [out.epub] [--author NAME] [--cover IMG]
```

- Needs `pandoc` (≥ 2.19). YAML front matter `title`, `subtitle`, `date`, `author` become book metadata.
- One chapter per `#` heading (`--split-level=1`), table of contents to `##`.
- HTML comments (`<!-- placeholders -->`) are stripped first.
- `scripts/epub.css` sets structure only (headings, quotes, tables). It deliberately leaves font
  family and size to the reader app.
- Images resolve relative to the input file's folder.

Check before delivering:

1. `unzip -l out.epub` lists one `chNNN.xhtml` per chapter and a `nav.xhtml`.
2. Skim the headings: `unzip -p out.epub EPUB/nav.xhtml | grep -o '<a [^>]*>[^<]*' | sed 's/.*>//'`.
3. If `epubcheck` is available, run it. pandoc output normally passes.

Docs written for PDF often lean on page layout. Before building, fix anything that breaks on
reflow: very wide tables (more than 4 columns) become lists; "see page N" becomes "see section X".

## Filing

Ebooks go in a dedicated folder per audience, so a reader app or sync tool can watch one
folder. The user's folders, and which material goes where, live in their own Drive or filing
skill or config, not here. Never put private material in a folder another person can see.
Upload by whatever route the user's setup uses. Name files `YYYY-MM-DD <Title>.epub`.

## Reading on a phone (what to recommend)

- **Android:** ReadEra. Free, no ads, reads EPUB, PDF and DOCX, has a good night mode, and
  picks up files from a local folder automatically. To keep a Drive folder in sync with the
  phone, add a one-way Drive-to-phone sync such as *Autosync for Google Drive* (MetaCtrl) or
  FolderSync into the folder ReadEra watches. Moon+ Reader is the power-user alternative.
- **iPhone:** Apple Books. Open the EPUB from the Drive app with Share → Books.
- **Kindle app or device:** Send to Kindle (email, app or web) accepts EPUB directly.
- **Google Play Books** syncs across devices, but files have to be uploaded to it by hand,
  and they live in Google's Play library, not your Drive.
