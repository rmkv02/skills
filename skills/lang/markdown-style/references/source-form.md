# Source form: line limit, whitespace, capitalization

**Authority:** the rules here are the guide's own. Distilled from
https://google.github.io/styleguide/docguide/style.html — last synced
2026-09-07; re-derive from upstream rather than patching in place.

**Contents:** §5 Character line limit · §6 Trailing whitespace ·
§7 Capitalization of names

## 5. Character line limit

Markdown content follows the residual convention of an **80-character line
limit**, because that is what the same people do for code. Two reasons:

-   **Tooling integration.** The tooling is built around code, so the closer
    documents are to code conventions, the better it works. Code Search, for
    one, does not soft wrap.
-   **Quality.** Engineers applying their well-worn coding habits to Markdown
    produce better documents, and the existing review culture transfers.

### 5.1 Exceptions

Four things are allowed past column 80:

-   Links
-   Tables
-   Headings
-   Code blocks

A line holding a link may run long, together with the punctuation attached to
it. Text before and after the link still wraps:

```markdown
*   See the
    [foo docs](https://gerrit.googlesource.com/gitiles/+/HEAD/Documentation/markdown.md).
    and find the logfile.
```

Tables may run long too, but that is a fallback, not a licence — an unavoidably
long cell is one thing, a table that is long because its links are inline is a
table that should be using reference links (see `links.md` §11.5 and
`tables-images-html.md` §12).

```markdown
Foo                                                                           | Bar | Baz
----------------------------------------------------------------------------- | --- | ---
Somehow-unavoidable-long-cell-filled-with-content-that-simply-refuses-to-wrap | Foo | Bar
```

Note what is *not* on the exception list: ordinary prose, list items, and block
quotes all wrap at 80.

## 6. Trailing whitespace

**Don't use trailing whitespace. Use a trailing backslash to break lines.**

The CommonMark spec turns two spaces at end of line into a `<br />`, but many
directories run a presubmit check against trailing whitespace and many editors
strip it on save — so a line break encoded as invisible spaces is a line break
that disappears without warning.

Use a trailing backslash, sparingly:

```markdown
For some reason I just really want a break here,\
though it's probably not necessary.
```

Best practice is to not need the `<br />` at all. A pair of newlines creates a
paragraph; that is almost always the better break.

## 7. Capitalization of names

Use the original names of products, tools and binaries, preserving their
capitalization.

```markdown
# Markdown style guide

`Markdown` is a dead-simple platform for internal engineering documentation.
```

Not:

```markdown
# markdown bad style guide example

`markdown` is a dead-simple platform for internal engineering documentation.
```

This is about proper names, not about sentence style: it applies wherever the
name appears, including in a heading whose surrounding words are lowercased.
Capitalization *within* titles and headings is a separate question the guide
hands to the Google developer documentation style guide — see `headings.md`
§8.5.
