# Headings

**Authority:** the rules here are the guide's own. Distilled from
https://google.github.io/styleguide/docguide/style.html — last synced
2026-09-07; re-derive from upstream rather than patching in place.

**Contents:** §8.1 ATX style · §8.2 Unique, complete names · §8.3 Spacing ·
§8.4 A single H1 · §8.5 Capitalization of titles

## 8. Headings

### 8.1 ATX-style headings

Use `#` headings:

```markdown
# Heading 1

## Heading 2
```

Underlined headings are annoying to maintain and do not fit the rest of the
syntax — an editor has to stop and ask whether `---` means H1 or H2:

```markdown
Heading - do you remember what level? DO NOT DO THIS.
---------
```

### 8.2 Use unique, complete names for headings

Every heading, including sub-sections, gets a unique and fully descriptive name.
Anchors are constructed from heading text, so duplicated names produce anchors
that are neither intuitive nor stable.

Instead of:

```markdown
## Foo
### Summary
### Example
## Bar
### Summary
### Example
```

prefer:

```markdown
## Foo
### Foo summary
### Foo example
## Bar
### Bar summary
### Bar example
```

The practical failure this prevents: someone links to `#summary`, a second
`### Summary` is added above it later, and the link now lands in the wrong
section — silently, because nothing is broken enough to notice.

### 8.3 Add spacing to headings

A space after the `#`, and blank lines before and after:

```markdown
...text before.

## Heading 2

Text after...
```

Without the spacing the source is harder to read, and some renderers will not
treat it as a heading at all:

```markdown
...text before.

##Heading 2
Text after... DO NOT DO THIS.
```

### 8.4 Use a single H1 heading

One H1, the title of the document. Every subsequent heading is H2 or deeper. See
`layout.md` §3 for what belongs under the title.

A second H1 competes with the first for the page `<title>` and flattens the
document outline, which is what a table of contents and a screen reader both
navigate by.

### 8.5 Capitalization of titles and headers

The Markdown guide does not decide this. It defers to the capitalization
guidance in the Google developer documentation style guide
(https://developers.google.com/style/capitalization).

When asked which case a heading takes, say where the answer lives instead of
inventing one — this skill covers Markdown source form, not prose style.
