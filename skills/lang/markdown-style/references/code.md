# Code: inline, spans, and blocks

**Authority:** the rules here are the guide's own. Distilled from
https://google.github.io/styleguide/docguide/style.html — last synced
2026-09-07; re-derive from upstream rather than patching in place.

**Contents:** §10.1 Inline code · §10.2 Code spans for escaping ·
§10.3 Fenced over indented blocks · §10.4 Declare the language ·
§10.5 Escape newlines · §10.6 Nest code blocks within lists

## 10. Code

### 10.1 Inline code

Backticks designate inline code, rendered literally. Use them for short code
quotations, field names, and the like:

```markdown
You'll want to run `really_cool_script.sh arg`.

Pay attention to the `foo_bar_whammy` field in that table.
```

Use inline code for a file *type* referred to generically, rather than one
specific existing file:

```markdown
Be sure to update your `README.md`!
```

### 10.2 Use code span for escaping

When text must not be processed as Markdown — a fake path, an example URL that
would turn into a bad autolink — wrap it in backticks:

```markdown
An example Markdown shortlink would be: `Markdown/foo/Markdown/bar.md`

An example query might be: `https://www.google.com/search?q=$TERM`
```

This is the fix for an entire class of complaint: a placeholder that renders as
a live link, an `_underscored_name_` that turns into emphasis, a `<tag>` that
disappears into HTML.

### 10.3 Use fenced code blocks instead of indented code blocks

Four-space indentation also produces a code block, but **fencing is strongly
recommended for all code blocks**. Indented blocks can look cleaner in source
and have three drawbacks:

-   You cannot specify the language. Some Markdown features are tied to language
    specifiers.
-   The beginning and end of the block are ambiguous.
-   They are harder to search for in Code Search.

Do not write this:

```markdown
You'll need to run:

    bazel run :thing -- --foo

And then:

    bazel run :another_thing -- --bar
```

### 10.4 Declare the language

Declare the language explicitly, so that neither the syntax highlighter nor the
next editor has to guess:

````markdown
```python
def Foo(self, bar):
  self.bar = bar
```
````

An unlabelled fence in a doc full of labelled ones is the common case, and it is
worth fixing precisely because it is invisible until the page renders.

### 10.5 Escape newlines

Most command-line snippets are meant to be copied and pasted straight into a
terminal, so escape the newlines with a single trailing backslash:

````markdown
```shell
$ bazel run :target -- --flag --foo=longlonglonglonglongvalue \
  --bar=anotherlonglonglonglonglonglonglonglonglonglongvalue
```
````

Without the backslash the reader pastes two commands and the second one fails
with a message that has nothing to do with the real problem.

### 10.6 Nest code blocks within lists

A code block inside a list must be indented to the list's text, or it breaks the
list:

````markdown
*   Bullet.

    ```c++
    int foo;
    ```

*   Next bullet.
````

A nested block can also be made with 4 spaces — indent 4 spaces beyond the list
indentation:

```markdown
*   Bullet.

        int foo;

*   Next bullet.
```

Note the tension with §10.3: inside a list, the 4-space form is offered by the
guide, but it carries the same drawbacks as anywhere else — no language tag, no
visible end. Prefer the indented fence.
