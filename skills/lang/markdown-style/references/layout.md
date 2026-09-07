# Document layout and the review bar

**Authority:** the rules here are the guide's own. Distilled from
https://google.github.io/styleguide/docguide/style.html — last synced
2026-09-07; re-derive from upstream rather than patching in place. If a rule
here conflicts with the three goals in `SKILL.md`, the goals win.

**Contents:** §1 Minimum viable documentation · §2 Better is better than best ·
§3 Document layout · §4 Table of contents

## 1. Minimum viable documentation

A small set of fresh and accurate docs beats a sprawling, loose assembly of
"documentation" in various states of disrepair. Ownership of docs is held to the
same standard as ownership of tests.

Two operational rules follow:

-   **Identify what is actually needed** — release docs, API docs, testing
    guidelines — rather than documenting everything that exists.
-   **Delete cruft frequently and in small batches.** A large cleanup that never
    happens is worth less than a paragraph deleted today.

In review terms: proposing a deletion is a normal finding. A section that no
longer matches the system is a defect, not neutral filler.

## 2. Better is better than best

The standards for a documentation review are **not** the standards for a code
review. The author can always invoke the Better/Best Rule. Fast iteration is the
point: authors must stay productive making short-term improvements, so each
change carries a lower bar and more changes happen.

As a reviewer:

1.  When reasonable, approve immediately and trust that comments get fixed
    appropriately.
2.  Prefer suggesting an alternative over leaving a vague comment.
3.  For substantial changes, start a separate follow-up change instead.
    Especially avoid comments of the form "You should *also*…".
4.  On rare occasions, hold up submission — only if the change actually makes
    the docs worse. Asking for a revert is acceptable in that case.

As an author:

1.  Avoid wasting cycles on trivial argument. Capitulate early and move on.
2.  Cite the Better/Best Rule as often as needed.

## 3. Document layout

Most documents benefit from a variation of this layout:

```markdown
# Document Title

Short introduction.

[TOC]

## Topic

Content.

## See also

* https://link-to-more-info
```

| Element | Rule |
|---|---|
| `# Document Title` | First heading, level one, ideally the same or nearly the same as the filename. The first H1 becomes the page `<title>`. |
| `author` | Optional. Add yourself under the title to claim ownership; revision history generally suffices. |
| Short introduction | 1–3 sentences of high-level overview. Write for someone who landed here knowing nothing: "What is Foo? Why would I extend it?" |
| `[TOC]` | After the short introduction, if the hosting supports it. See §4. |
| `## Topic` | Every remaining heading starts at level 2. |
| `## See also` | Miscellaneous links at the bottom, for the reader who wants more or did not find what they needed. |

The introduction is the part most often skipped, and it is the part a newcomer
needs most: the author already knows what Foo is, so the sentence that says so
feels redundant to write and is not.

## 4. Table of contents

### 4.1 Use a `[TOC]` directive

Use `[TOC]` unless all of the content is above the fold on a laptop — that is,
visible without scrolling when the page first displays. On hosting that does not
support the directive (`[TOC]` is a Gitiles feature), it is inert text; check
what renders the corpus before adding it.

### 4.2 Place `[TOC]` after the introduction

`[TOC]` goes after the page's introduction and before the first H2.

```markdown
# My Page

This is my introduction **before** the TOC.

[TOC]

## My first H2
```

Not:

```markdown
# My Page

[TOC]

This is my introduction **after** the TOC where it should not be.

## My first H2
```

This is an accessibility rule, not a cosmetic one. Visually the position makes
no difference — the rendered TOC appears at the top right of the page either
way. But the directive injects the table of contents into the DOM exactly where
it sits in the source, so a screen reader or keyboard user meets it in that
order. A `[TOC]` at the bottom of the file is read last, after everything it was
supposed to help navigate.
