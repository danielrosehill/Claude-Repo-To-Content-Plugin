// =============================================================================
// Shared Typst styling for the repo-to-docs plugin.
//
// Typography : IBM Plex Sans (body + headings) + IBM Plex Mono (code).
//              Fallback to system sans if IBM Plex is not installed.
// Palette    : dark slate body, teal-700 primary accent, soft rule lines.
//
// Public entry point: #doc-base(...) — opinionated cover + TOC + body wrapper
// with a configurable footer/header. All footer slots can be toggled off.
// =============================================================================

#let heading-font = "IBM Plex Sans"

#let palette = (
  text:    rgb("#1F2937"),
  heading: rgb("#0F766E"),  // teal-700
  muted:   rgb("#6B7280"),
  rule:    rgb("#E5E7EB"),
  highlight: rgb("#B45309"),
  link:    rgb("#0369A1"),
)

#let format-date(d) = d.display("[day]-[month]-[year repr:last_two]")

// -----------------------------------------------------------------------------
// Core wrapper used by every repo-to-docs output.
//
// Footer composition (all individually overridable):
//   - left   : repo-url link (if show-repo-url and repo-url != none)
//   - center : "Licensed under <license>" (if show-license)
//              + "By <author> · <date>" (if show-author)
//              + any extra-footer-lines (user-supplied)
//   - right  : "Page N / Total" (if show-page-numbers)
//
// Header:
//   - right : "Page N" always
//   - left  : header-left string (e.g. "CONFIDENTIAL"), optional
//
// Cover:
//   - If banner-path is provided, render it full-width above the title.
// -----------------------------------------------------------------------------
#let doc-base(
  title: none,
  subtitle: none,
  author: "",
  date: datetime.today(),
  repo-url: none,
  license: "MIT",
  show-page-numbers: true,
  show-license: true,
  show-repo-url: true,
  show-author: true,
  extra-footer-lines: (),
  banner-path: none,
  header-left: none,
  header-bold: false,
  show-toc: true,
  toc-depth: 1,
  body,
) = {
  set page(
    paper: "a4",
    margin: (top: 3.2cm, bottom: 3cm, x: 2.5cm),
    header: context {
      set text(size: 9pt, fill: palette.muted)
      let page-num = counter(page).display()
      grid(
        columns: (1fr, auto),
        align: (left, right),
        [
          #if header-left != none {
            if header-bold {
              text(weight: "bold", fill: palette.highlight, header-left)
            } else {
              text(header-left)
            }
          }
        ],
        [Page #page-num],
      )
      v(-0.3em)
      line(length: 100%, stroke: 0.4pt + palette.rule)
    },
    footer: context {
      set text(size: 8.5pt, fill: palette.muted)
      line(length: 100%, stroke: 0.4pt + palette.rule)
      v(0.2em)

      // Left: repo URL
      let left-content = if show-repo-url and repo-url != none {
        link(repo-url)[#repo-url]
      } else { [] }

      // Center: license + author/date + extras
      let center-parts = ()
      if show-license and license != none and license != "" {
        center-parts.push([Licensed under #license])
      }
      if show-author and author != none and author != "" {
        center-parts.push([By #author · #format-date(date)])
      }
      for extra in extra-footer-lines {
        center-parts.push([#extra])
      }
      let center-content = center-parts.join([ · ])

      // Right: page number / total
      let right-content = if show-page-numbers {
        let here = counter(page).display()
        let total = counter(page).final().at(0)
        [Page #here / #total]
      } else { [] }

      grid(
        columns: (1fr, 2fr, 1fr),
        align: (left, center, right),
        left-content,
        center-content,
        right-content,
      )
    },
  )

  // --- Typography -----------------------------------------------------------
  set text(
    font: "IBM Plex Sans",
    size: 10.5pt,
    fill: palette.text,
  )
  set par(justify: true, leading: 0.7em, first-line-indent: 0pt)

  show heading: set text(font: heading-font, fill: palette.heading)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    block(above: 0pt, below: 1.2em)[
      #set text(size: 22pt, weight: "semibold")
      #it.body
    ]
  }
  show heading.where(level: 2): set text(size: 14pt, weight: "semibold")
  show heading.where(level: 3): set text(size: 12pt, weight: "medium")

  show link: set text(fill: palette.link)
  show raw: set text(font: "IBM Plex Mono", size: 9.5pt)

  set table(stroke: 0.5pt + palette.rule, inset: 6pt)
  show table.cell.where(y: 0): strong

  // --- Cover ----------------------------------------------------------------
  if banner-path != none {
    block(width: 100%, image(banner-path, width: 100%))
    v(1em)
  }
  if title != none {
    v(if banner-path == none { 3cm } else { 0.5cm })
    align(left)[
      #text(font: heading-font, size: 30pt, weight: "bold", fill: palette.heading, title)
    ]
    if subtitle != none {
      v(0.4em)
      align(left)[
        #text(size: 14pt, fill: palette.muted, style: "italic", subtitle)
      ]
    }
    v(1.2em)
    line(length: 40%, stroke: 1pt + palette.heading)
    v(0.6em)
    text(size: 10pt, fill: palette.muted)[
      #if show-author and author != "" [ #author · ] #format-date(date)
    ]
  }

  // --- TOC ------------------------------------------------------------------
  if show-toc {
    pagebreak()
    outline(title: [Contents], depth: toc-depth, indent: auto)
  }

  // --- Body -----------------------------------------------------------------
  pagebreak()
  body
}

// -----------------------------------------------------------------------------
// Helper: AI-authorship disclosure block. Place inside the body where a
// disclosure is required (e.g. at end of executive summary).
// -----------------------------------------------------------------------------
#let ai-disclosure-block(tool: none, role: none, human: none) = {
  block(
    fill: rgb("#FEF3C7"),
    stroke: 0.5pt + palette.highlight,
    inset: 10pt,
    radius: 3pt,
    width: 100%,
  )[
    #set text(size: 9pt, fill: palette.text)
    #text(weight: "semibold", fill: palette.highlight)[AI-assisted document] \
    #{
      let parts = ()
      if tool != none { parts.push([Tool: #tool]) }
      if role != none { parts.push([AI role: #role]) }
      if human != none { parts.push([Human work: #human]) }
      parts.join([ · ])
    }
  ]
}
