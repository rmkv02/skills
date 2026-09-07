# Links

**Authority:** the rules here are the guide's own. Distilled from
https://google.github.io/styleguide/docguide/style.html — last synced
2026-09-07; re-derive from upstream rather than patching in place.

**Contents:** §11.1 Shorten links · §11.2 Explicit paths ·
§11.3 Relative paths · §11.4 Informative titles · §11.5 Reference links

## 11. Links

### 11.1 Shorten your links

Long links make source Markdown difficult to read and break the 80-character
wrapping. **Wherever possible, shorten the link.** Everything below is a way of
doing that: a shorter path (§11.2), or moving the URL out of the sentence
(§11.5).

### 11.2 Use explicit paths for links within Markdown

Inside the corpus, link by path:

```markdown
[...](/path/to/other/markdown/page.md)
```

The fully qualified URL to the same page is not needed:

```markdown
[...](https://bad-full-url.example.com/path/to/other/markdown/page.md)
```

A full URL pins the document to one host, so it survives neither a move of the
corpus nor a reader browsing it from a mirror.

### 11.3 Avoid relative paths unless within the same directory

Relative paths are fairly safe within the same directory:

```markdown
[...](other-page-in-same-dir.md)
[...](/path/to/another/dir/other-page.md)
```

Avoid relative links that have to climb out with `../`:

```markdown
[...](../../bad/path/to/another/dir/other-page.md)
```

They break as soon as either file moves, and a reader cannot resolve them by
eye.

### 11.4 Use informative Markdown link titles

Users do not read documents, they scan them; links catch the eye. Titling a link
"here", "link", or with the target URL itself tells the scanning reader nothing
and wastes the space.

Do not do this:

```markdown
See the Markdown guide for more info: [link](markdown.md), or check out the
style guide [here](style.md).

Check out a typical test result:
[https://example.com/foo/bar](https://example.com/foo/bar).
```

Write the sentence naturally first, then wrap the phrase that already describes
the destination:

```markdown
See the [Markdown guide](markdown.md) for more info, or check out the
[style guide](style.md).

Check out a
[typical test result](https://example.com/foo/bar).
```

### 11.5 Reference links

Split the link use from its definition for long links and image URLs:

```markdown
See the [Markdown style guide][style], which has suggestions for making docs
more readable.

[style]: http://Markdown/corp/Markdown/docs/reference/style.md
```

#### 11.5.1 Use reference links for long links

Use a reference link where inlining the URL would detract from the readability
of the surrounding text. Reference links are not free: they hide the destination
from the source reader and add syntax.

Not appropriate — the link is not long enough to disrupt the text:

```markdown
DO NOT DO THIS.

The [style guide][style_guide] says not to use reference links unless you have
to.

[style_guide]: https://google.com/Markdown-style
```

Appropriate — the destination is long enough to be worth moving:

```markdown
The [style guide] says not to use reference links unless you have to.

[style guide]: https://docs.google.com/document/d/13HQBxfhCwx8lVRuN2Wf6poqvAfVeEXmFVcawP5I6B3c/edit
```

Use reference links **more often in tables**. Markdown cannot break cell text
across lines, so cell content has to stay short; see `tables-images-html.md`
§12.

#### 11.5.2 Use reference links to reduce duplication

When the same destination is referenced several times in a document, a single
reference definition means one place to update when the target moves.

#### 11.5.3 Define reference links after their first use

Put reference definitions **just before the next heading**, at the end of the
section where they are first used. A "section" is all the text between two
headings; think of the definitions as footnotes and the section as the page.

If the editor has its own opinion about placement, don't fight it — the tools
always win.

**Exception:** definitions used in several sections go at the end of the
document, so that updating or moving one section does not leave dangling links
in another.

Definitions parked far from their use make the document harder to read:

```markdown
# Header FOR A BAD DOCUMENT

Some text with a [link][link_def].

Some more text with the same [link][link_def].

## Header 2

... lots of text ...

## Header 3

Some more text using a [different_link][different_link_def].

[link_def]: http://reallyreallyreallylonglink.com
[different_link_def]: http://differentreallyreallylonglink.com
```

Put each one before the heading that follows its first use:

```markdown
# Header

Some text with a [link][link_def].

Some more text with the same [link][link_def].

[link_def]: http://reallyreallyreallylonglink.com

## Header 2

... lots of text ...

## Header 3

Some more text using a [different_link][different_link_def].

[different_link_def]: http://differentreallyreallylonglink.com
```

This keeps destinations findable in source view and prevents footnote overload
at the bottom of a long file, where picking out the relevant definition becomes
its own task.
