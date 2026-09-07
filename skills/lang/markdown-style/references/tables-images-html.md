# Tables, images, and HTML

**Authority:** the rules here are the guide's own. Distilled from
https://google.github.io/styleguide/docguide/style.html — last synced
2026-09-07; re-derive from upstream rather than patching in place.

**Contents:** §12 Tables · §13 Images · §14 Strongly prefer Markdown to HTML

## 12. Tables

Use tables when they make sense: **tabular data that needs to be scanned
quickly**. Avoid them when the data could just as easily be a list — lists are
much easier to write and read in Markdown.

### 12.1 Three signs the table should be a list

```markdown
DO NOT DO THIS

Fruit  | Metrics      | Grows on | Acute curvature    | Attributes                | Notes
------ | ------------ | -------- | ------------------ | ------------------------- | ---------------------------
Apple  | Very popular | Trees    |                    | [Juicy](http://cs/LongQ)  | Apples keep doctors away.
Banana | Very popular | Trees    | 16 degrees average | [Convenient](http://cs/Q) | Contrary to popular belief…
```

-   **Poor distribution.** Several columns do not differ across rows, and some
    cells are empty. Usually a sign the data does not benefit from tabular
    display at all.
-   **Unbalanced dimensions.** Few rows relative to columns (or the reverse).
    The table becomes an inflexible format for text rather than a comparison.
-   **Rambling prose in cells.** A table should tell a succinct story at a
    glance.

Headings and lists carry the same information with room to breathe:

```markdown
## Fruits

Both types are highly popular, sweet, and grow on trees.

### Apple

*   [Juicy](http://SomeReallyLongURL)
*   Firm

Apples keep doctors away.

### Banana

*   [Convenient](http://cs/SomeDifferentLongQuery)
*   Soft
*   16 degrees average acute curvature.

Contrary to popular belief, most apes prefer mangoes.
```

Note what moved: the repeated columns became one sentence of shared context, and
the prose cell became a paragraph under its own heading.

### 12.2 When a table is the right choice

A table earns its place when there is:

-   Relatively uniform data distribution across two dimensions.
-   Many parallel items with distinct attributes.

Then a compact table genuinely improves readability:

```markdown
Transport        | Favored by     | Advantages
---------------- | -------------- | -----------------------------------------------
Swallow          | Coconuts       | [Fast when unladen][airspeed]
Bicycle          | Miss Gulch     | [Weatherproof][tornado_proofing]
X-34 landspeeder | Whiny farmboys | [Cheap][tosche_station] since the XP-38 came out

[airspeed]: http://google3/airspeed.h
[tornado_proofing]: http://google3/kansas/
[tosche_station]: http://google3/power_converter.h
```

Reference links are what keep the cells manageable — Markdown cannot break cell
text across lines, so an inline URL sets the width of the whole column. See
`links.md` §11.5.

## 13. Images

Use images sparingly, and prefer simple screenshots. The guide is built on the
idea that plain text gets people to the point faster, with less reader
distraction and less author procrastination — but sometimes showing beats
telling.

-   **Use an image when it is easier to *show* than to *describe*.** Explaining
    how to navigate a UI is the standard example.
-   **Always provide text describing the image.** Readers who are not sighted
    cannot see it and still need the content. An image whose meaning exists only
    in the pixels is content some readers simply do not get.

## 14. Strongly prefer Markdown to HTML

Prefer standard Markdown syntax wherever possible and avoid HTML hacks. If
something seems impossible in Markdown, reconsider whether it is really needed:
except for big tables, Markdown already meets almost every need.

Every bit of HTML hacking reduces the readability and portability of the corpus,
which in turn limits integrations with other tools — tools that may present the
source as plain text rather than render it.

And the hard constraint behind the preference: **Gitiles does not render HTML.**
On that renderer, an HTML hack is not a degraded experience, it is missing
content. Before reaching for a `<details>` block, a `<br>`, or an inline
`<table>`, check what renders the corpus.
