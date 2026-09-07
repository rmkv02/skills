# Lists

**Authority:** the rules here are the guide's own. Distilled from
https://google.github.io/styleguide/docguide/style.html — last synced
2026-09-07; re-derive from upstream rather than patching in place.

**Contents:** §9.1 Lazy numbering · §9.2 Nested list spacing

## 9. Lists

### 9.1 Use lazy numbering for long lists

Markdown renders numbered lists correctly whatever numbers the source uses. For
longer lists that may change, especially long nested ones, use lazy numbering —
`1.` all the way down — so that inserting an item does not renumber the rest of
the file:

```markdown
1.  Foo.
1.  Bar.
    1.  Foofoo.
    1.  Barbar.
1.  Baz.
```

For a small list you do not expect to change, prefer full numbering; it reads
better in source:

```markdown
1.  Foo.
2.  Bar.
3.  Baz.
```

The trade-off is exactly that: lazy numbering costs source readability and buys
clean diffs. Long or nested list — take the diffs. Three stable items — take the
readability.

### 9.2 Nested list spacing

**Use a 4-space indent for both numbered and bulleted lists.** The number of
spaces after the marker is chosen so the text itself starts at column 4:

```markdown
1.  Use 2 spaces after the item number, so the text itself is indented 4 spaces.
    Use a 4-space indent for wrapped text.
2.  Use 2 spaces again for the next item.

*   Use 3 spaces after a bullet, so the text itself is indented 4 spaces.
    Use a 4-space indent for wrapped text.
    1.  Use 2 spaces with numbered lists, as before.
        Wrapped text in a nested list needs an 8-space indent.
    2.  Looks nice, doesn't it?
*   Back to the bulleted list, indented 3 spaces.
```

| Marker | Spaces after marker | Text starts at | Wrapped text indent |
|---|---|---|---|
| `1.` | 2 | column 4 | 4 |
| `*` | 3 | column 4 | 4 |
| nested `1.` under a bullet | 2 | column 8 | 8 |

The following renders, but it is very messy — and irregular nesting is where
renderers start to disagree with each other:

```markdown
* One space,
with no indent for wrapped text.
     1. Irregular nesting... DO NOT DO THIS.
```

Even with no nesting at all, the 4-space indent keeps wrapped text lined up:

```markdown
*   Foo,
    wrapped with a 4-space indent.

1.  Two spaces for the list item
    and 4 spaces before wrapped text.
2.  Back to 2 spaces.
```

The exception, and it is a real one: when a list is small, not nested, and every
item is a single line, one space suffices.

```markdown
* Foo
* Bar
* Baz.

1. Foo.
2. Bar.
```

So a one-space list is not automatically a finding. It becomes one as soon as an
item wraps, an item is nested, or the list is likely to grow.
