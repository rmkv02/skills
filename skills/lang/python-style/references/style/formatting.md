# Layout: lines, indentation, whitespace, statements, imports (style rules)

**Authority:** style rule — decides how the code is written. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. The Black/Pyink formatter and Google's pylintrc win on anything mechanical.

**Contents:** semicolons · line length · parentheses · indentation · trailing commas · blank lines · whitespace · shebang · statements · import formatting

## 3.1 Semicolons

Never terminate a line with a semicolon, never join two statements with one.

## 3.2 Line length

Maximum 80 characters. Explicit exceptions: long import statements; URLs, pathnames and long flags in comments; long module-level string constants without whitespace (URLs, paths); `# pylint: disable=` comments. Docstring summary lines must stay within 80.

**No backslash continuations.** Use Python's implicit joining inside parentheses, brackets and braces; add a pair of parentheses if needed. (This does not ban backslash-escaped newlines *inside* string literals.)

```python
# Yes
foo_bar(self, width, height, color='black', design=None, x='foo',
        emphasis=None, highlight=0)
if (width == 0 and height == 0 and
        color == 'red' and emphasis == 'strong'):

# No
if width == 0 and height == 0 and \
        color == 'red' and emphasis == 'strong':
```

Break at the highest syntactic level available; if you must break twice, break at the same level both times. Long literal strings join implicitly inside parentheses. Put a long URL in a comment on its own line rather than splitting it.

When a line still exceeds 80 and Black/Pyink cannot bring it down, the line is allowed to stay long.

## 3.3 Parentheses

Sparingly. Fine around tuples. Not in `return` or conditional statements unless they mark a tuple or carry an implied continuation.

```python
# Yes: if foo:      while x:      if x and y:      return foo
# No:  if (x):      if not(x):    return (foo)
```

## 3.4 Indentation

4 spaces, never tabs. Continuations either align vertically with the opening delimiter or use a 4-space hanging indent — nothing on the first line in the hanging case, and no 2-space hanging indent. A closing bracket goes at the end of the expression or on its own line indented like the line that opened it.

### 3.4.1 Trailing commas

Recommended only when the closing `]`, `)` or `}` is not on the same line as the final element, and for single-element tuples. The trailing comma also tells Black/Pyink to explode the container to one item per line.

```python
# Yes
golomb3 = [0, 1, 3]
golomb4 = [
    0,
    1,
    4,
    6,
]
# No — closing bracket glued to the last element
golomb4 = [
    0,
    6,]
```

## 3.5 Blank lines

Two between top-level definitions, one between methods and between a class docstring and the first method, none after a `def` line. Inside a function, use single blank lines as judgment dictates. A blank line need not be anchored to the definition — a related comment may sit directly above it, though consider whether it belongs in the docstring.

## 3.6 Whitespace

Standard typographic rules.

- None inside parentheses, brackets or braces: `spam(ham[1], {'eggs': 2}, [])`.
- None before a comma, semicolon or colon; one after, except at line end.
- None before an opening paren/bracket that starts a call, index or slice: `spam(1)`, `dict['key']`.
- No trailing whitespace.
- One space each side of assignment, comparison and boolean operators; judgment for arithmetic.
- **No spaces around `=` for keyword arguments and defaults — unless an annotation is present, and then spaces are required:**

```python
# Yes
def complex(real, imag=0.0): ...
def complex(real, imag: float = 0.0): ...
# No
def complex(real, imag = 0.0): ...
def complex(real, imag: float=0.0): ...
```

- Do not align tokens vertically across lines (`:`, `#`, `=`) — it is a maintenance burden.

## 3.7 Shebang line

Only the file meant to be executed directly needs one: `#!/usr/bin/env python3` (virtualenv-friendly) or `#!/usr/bin/python3`. Library modules do not.

## 3.14 Statements

Generally one statement per line. A test and its result may share a line only if the whole statement fits and there is no `else`; never for `try`/`except`.

```python
# Yes:  if foo: bar(foo)
# No:   if foo: bar(foo)
#       else:   baz(foo)
```

## 3.13 Imports formatting

One import per line — except symbols from `typing` and `collections.abc`, which may be grouped on one line.

```python
from collections.abc import Mapping, Sequence
import os
import sys
from typing import Any, NewType
```

Imports sit at the top of the file, after the module docstring and before module globals, grouped from most to least generic, with an optional blank line between groups:

1. `__future__` imports
2. standard library
3. third-party packages
4. code-repository sub-package imports

(The old fifth group — application-specific imports from the same top-level sub-package — is deprecated; treat them like any other sub-package import.)

Within each group, sort lexicographically ignoring case, by the module's full package path.
