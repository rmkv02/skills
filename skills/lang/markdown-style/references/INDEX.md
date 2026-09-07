# References index

Seven small files, split so that one lookup costs one file. Open exactly the one
you need — `SKILL.md` carries the same routing table and is usually enough to
pick.

All files are distilled from
https://google.github.io/styleguide/docguide/style.html (last synced 2026-09-07)
and are re-derived from upstream rather than patched in place. Section numbers
(§1–§14) are stable across files, so a checklist item can cite one exactly.

| File | Sections | Covers |
|---|---|---|
| `layout.md` | §1–§4 | minimum viable documentation, the Better/Best review bar, document skeleton, `[TOC]` use and placement |
| `source-form.md` | §5–§7 | 80-character line limit and its exceptions, trailing whitespace and line breaks, capitalizing product names |
| `headings.md` | §8 | ATX style, unique names and anchors, spacing, single H1, title capitalization |
| `lists.md` | §9 | lazy vs full numbering, indent counts, nesting, wrapped text |
| `code.md` | §10 | inline code, code spans for escaping, fenced vs indented blocks, language tags, shell newlines, code inside lists |
| `links.md` | §11 | shortening links, explicit and relative paths, informative titles, reference links and where to define them |
| `tables-images-html.md` | §12–§14 | table vs list, keeping cells short, images and their text descriptions, Markdown over HTML |

## Where this guide stops

The guide is intentionally silent on these. Follow the surrounding corpus and do
not raise them as findings:

-   Bullet character: `*` vs `-` vs `+` (the guide's own examples use `*`).
-   Emphasis markers: `*italic*` vs `_italic_`, `**bold**` vs `__bold__`.
-   Table column alignment and whether the pipes line up in source.
-   YAML front matter — its presence, its fields, its ordering.
-   Ordered-list marker style: `1.` vs `1)`.
-   Fence character: backticks vs tildes.
-   Line ending of the file, final newline, and other things a formatter owns.

Two topics look like they belong here and do not:

-   **Prose style** — voice, tense, terminology, and capitalization *within* a
    title — belongs to the Google developer documentation style guide, which
    this guide explicitly defers to (`headings.md` §8.5).
-   **Documentation inside source code** — Go doc comments, docstrings, JSDoc —
    belongs to the language skill, not here.
