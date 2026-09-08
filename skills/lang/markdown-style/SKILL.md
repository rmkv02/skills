---
name: markdown-style
description: Applies Google's Markdown style guide to Markdown source. Use this skill whenever .md files are written, generated, reviewed or restructured — READMEs, design docs, changelogs, Markdown pasted into chat — even when no style review was asked for. Also use for questions about document layout, `[TOC]` placement, heading levels, list indentation, fenced code blocks, links, or whether something should be a table or a list. Do NOT use for the prose itself (voice, tense, wording — that is the Google developer documentation style guide), for documentation inside code (Go doc comments are go-style, Python docstrings python-style), or for other markup formats and docs tooling.
license: CC-BY-3.0
---

# Google Markdown Style

This guide governs the **source text** of a Markdown document — the plain
text an author edits — not the words in it. Rendered output that looks
identical can still be wrong here, because the reader this guide protects is
the next author opening the file in an editor.

Most disagreements are settled by knowing what outranks what:

| Layer | Where | Authority |
|---|---|---|
| Renderer and repo formatter | outside this skill | Mechanical facts — override everything below |
| Better/Best rule | "The review bar" | Gate — decides whether a violation is worth raising at all |
| The three goals | "The three goals" | Tiebreaker when two concrete rules pull apart |
| Concrete rules | `references/` | The rules themselves |
| Corpus consistency | the surrounding docs | Weakest tiebreaker |

Two mechanical facts sit above the whole guide, because arguing with them wastes
everyone's time: the renderer decides what is possible (Gitiles, for one, does
not render HTML at all), and a configured formatter decides layout the moment
the repo has one. The guide states this itself about reference-link placement:
"If your editor has its own opinion about where they should go, don't fight it;
the tools always win."

> Attribution: derived from Google's Markdown style guide
> (https://google.github.io/styleguide/docguide/style.html), licensed CC-BY 3.0.

## Workflow

1.  **Delegate mechanical checks.** With shell access, run
    `scripts/check_markdown.sh <path>` before reading anything closely. Line
    length, trailing whitespace, setext headings, stray H1s, `[TOC]` placement,
    unlabelled fences and `../` links are decided by counting characters, not by
    judgment. Without shell access, say the checks were not run rather than
    guessing at their output.
2.  **Apply the review bar before writing anything down.** Most Markdown
    findings are not worth a round trip. Decide what actually gets raised
    first, then review.
3.  **Run the fast pass checklist.** It is a screen for what shows up in real
    docs, not the full ruleset.
4.  **Look up specifics in `references/` when the answer must be exact.** Use
    the routing table below. Do not answer from memory on the fine print — the
    indentation counts, the `[TOC]` position, and the reference-link placement
    rule are all easy to state backwards.
5.  **Report findings in the format below**, structure before syntax.

## The review bar

The guide is explicit that documentation review runs at a lower bar than code
review, and the reason is throughput: authors must stay productive on short-term
improvements, so each change gets a lower standard and more changes happen.
Applied to a review pass:

-   **Approve when the change makes the doc better**, even when it is not what
    you would have written. "Not best" is not a finding.
-   **Suggest the replacement text, never a vague note.** `[docs](x.md)` beats
    "link titles should be informative" — the author can paste the first one.
-   **Don't stack "you should also…" onto someone else's change.** For a
    substantial restructure, offer to do it as a separate pass instead of
    turning one edit into ten.
-   **Hold something up only when the change makes the docs worse.** That is the
    single case where blocking is the right call.

The counterpart rule for authors: capitulate early on trivia and move on.

## The three goals

When two rules conflict, the ranking is the guide's own:

1.  **Source text is readable and portable.** The file has to read well as plain
    text and survive being rendered by something other than today's renderer.
    This is what kills HTML hacks and 400-character table rows.
2.  **The corpus is maintainable over time and across teams.** The corpus is
    edited by people who did not write it. Predictable structure beats clever
    structure.
3.  **The syntax is simple and easy to remember.** A rule nobody can recall is
    not followed, so the guide prefers one obvious form over a precise taxonomy.

Underneath all three: a small set of fresh, accurate docs beats a sprawling
assembly of stale ones. Deleting cruft is an improvement, not a loss — treat a
doc that no longer matches reality as a defect on par with a broken test.

## Fast pass checklist

Each item names the file with the exact rule. Open one file, not the set.

### Document shape

-   [ ] Exactly one H1, first thing in the file, matching the filename; every
        other heading is H2 or deeper. [headings.md §8.4 · layout.md §3]
-   [ ] A 1–3 sentence introduction sits under the title and assumes the reader
        knows nothing: what this is, why they would want it. [layout.md §3]
-   [ ] `[TOC]` present unless the whole doc fits above the fold, placed after
        the introduction and before the first H2 — placement is an accessibility
        rule, not a cosmetic one. [layout.md §4]
-   [ ] Loose links collected under a trailing `## See also`. [layout.md §3]

### Source form

-   [ ] Lines wrap at 80 characters, except links, tables, headings and code
        blocks; text before and after a long link still wraps.
        [source-form.md §5]
-   [ ] No trailing whitespace. A deliberate line break is a trailing backslash,
        used sparingly; a blank line and a new paragraph is better.
        [source-form.md §6]
-   [ ] Product, tool and binary names keep their own capitalization.
        [source-form.md §7]

### Headings

-   [ ] ATX headings (`## Foo`), never `=====` or `-----` underlines.
        [headings.md §8.1]
-   [ ] Heading names unique and fully descriptive across the document — not
        `### Summary` under both `## Foo` and `## Bar`, because anchors are
        built from them. [headings.md §8.2]
-   [ ] A space after the `#`, and a blank line before and after the heading.
        [headings.md §8.3]

### Lists

-   [ ] Long or nested numbered lists use lazy numbering (`1.` throughout);
        short stable ones are fully numbered. [lists.md §9.1]
-   [ ] Nested content indents 4 spaces: 2 spaces after `1.`, 3 after `*`, so
        the text starts at column 4. [lists.md §9.2]
-   [ ] Wrapped text lines up with the text above it, not with the marker.
        [lists.md §9.2]

### Code

-   [ ] Fenced code blocks everywhere, never 4-space-indented blocks — a fence
        can carry a language and has an unambiguous end. [code.md §10.3]
-   [ ] Every fence declares its language. [code.md §10.4]
-   [ ] Multi-line shell commands escape newlines with a trailing backslash so
        they can be pasted into a terminal. [code.md §10.5]
-   [ ] Code blocks inside a list are indented to the list text, so they don't
        break the list. [code.md §10.6]
-   [ ] Backticks around field names, filenames, commands, and anything that
        must not be processed as Markdown — fake paths and example URLs that
        would otherwise autolink. [code.md §10.1 §10.2]

### Links

-   [ ] Link titles are informative in a scanned sentence: no "here", no "link",
        no URL duplicated as its own title. [links.md §11.4]
-   [ ] In-repo links use explicit paths (`/path/to/page.md`), not a fully
        qualified URL to the same corpus. [links.md §11.2]
-   [ ] Relative paths only within the same directory; no `../../` chains.
        [links.md §11.3]
-   [ ] Reference links where an inline URL would wreck the line — and only
        there; a short URL inline is easier to follow. [links.md §11.5]
-   [ ] Reference definitions sit at the end of the section that first uses
        them, just before the next heading; definitions used across sections
        go at the end of the file. [links.md §11.5]

### Tables, images, HTML

-   [ ] The table earns its shape: uniform data on two dimensions, many parallel
        items. Empty cells, columns that repeat down every row, or two rows
        against six columns mean it should be a list with subheadings.
        [tables-images-html.md §12]
-   [ ] Cells are short; long link targets move into reference links.
        [tables-images-html.md §12]
-   [ ] Images used only where showing beats describing, and every image has
        text describing it for readers who cannot see it.
        [tables-images-html.md §13]
-   [ ] No HTML where Markdown can do the job; big tables are the one routine
        exception. [tables-images-html.md §14]

## Which reference to load

One question, one file. Every file is small enough to read in full.

| The question is about | Read |
|---|---|
| Document skeleton, title, introduction, `## See also`, `[TOC]` use and placement, doc scope and deleting cruft, the review bar | `references/layout.md` |
| Line length and its exceptions, trailing whitespace and line breaks, capitalizing product names | `references/source-form.md` |
| Heading syntax, uniqueness and anchors, spacing, single H1, title capitalization | `references/headings.md` |
| Lazy vs full numbering, indentation counts, nesting, wrapped text | `references/lists.md` |
| Inline code, escaping with code spans, fenced vs indented blocks, language tags, shell newlines, code in lists | `references/code.md` |
| Link titles, explicit vs relative paths, reference links: when to use them and where to define them | `references/links.md` |
| Table vs list, table readability, images and alt text, Markdown vs HTML | `references/tables-images-html.md` |
| Where a rule stops and something else takes over | `references/INDEX.md`, "Where this guide stops" |

The guide is deliberately silent on several things people expect it to cover —
bullet characters, emphasis markers, table alignment, front matter. Say so
instead of inventing a rule; corpus consistency decides those.

## Reporting findings

Lead with anything that changes what the reader gets: a broken structure, a
wrong or dangling link, a missing language tag on a block someone will copy.
Only then syntax.

```text
[severity] rule — file:line
  current: <the source as written>
  fix:     <the replacement source, paste-ready>
  why:     <one sentence: what breaks for the next reader>
```

Order: structure and correctness (multiple H1s, `[TOC]` before the intro,
`../..` links, tables that should be lists, HTML that will not render) →
readability (link titles, line length, indentation) → nits.

Three things keep this useful rather than annoying:

-   **Give the replacement, not the rule name.** A finding the author can paste
    costs them seconds; a finding they have to interpret costs a round trip.
-   **Don't pad the list.** If the doc is fine, say so in one line. Manufactured
    nits are exactly what the Better/Best rule exists to stop.
-   **Don't bury a content problem under formatting.** If the doc is
    out of date or wrong, lead with that; indentation can wait.

## Out of scope

The prose itself — voice, tense, terminology, sentence length, and the
capitalization *style* of a title (the guide defers that one to the Google
developer documentation style guide; say so rather than inventing a rule).
Documentation embedded in source code: Go doc comments (`go-style`), Python
docstrings (`python-style`), JSDoc.
Other markup: reStructuredText, AsciiDoc, Jupyter, raw HTML pages. Docs tooling:
site generators, link checkers in CI, publishing. Throwaway Markdown — a chat
message, a scratch note, a PR description — where a style pass is pure noise.
And when the user says to leave the formatting alone: respect it, note a broken
link if you see one, and skip the rest.

## Provenance and maintenance

-   Source of truth: https://google.github.io/styleguide/docguide/style.html.
-   `references/` is a distillation, not a copy, split so one lookup costs one
    small file. When upstream changes, re-derive the affected file; do not patch
    the checklist here without updating the matching reference, or the two
    drift.
-   Last synced with upstream: 2026-09-07.
-   Owner and version: see `registry.yaml` at the repository root.
