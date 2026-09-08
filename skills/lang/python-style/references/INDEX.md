# References index

Twelve small files, split so that one lookup costs one file. `SKILL.md` carries the same routing table and is usually enough to pick.

`language/` covers what the code may do (guide §2); `style/` covers how it is written (guide §3). Where the guide is silent, consistency with the surrounding file decides. On anything mechanical, Black/Pyink and Google's pylintrc outrank both.

All files are distilled from https://google.github.io/styleguide/pyguide.html (last synced 2026-09-07) and are re-derived from upstream rather than patched in place.

## language/ — which constructs are allowed

| File | Covers |
|---|---|
| `imports-packages.md` | §2.2 module-vs-symbol imports, aliasing rules, typing exemptions; §2.3 full package paths |
| `exceptions.md` | §2.4 built-in vs custom exceptions, `assert` misuse, bare `except`, `try` scope, `finally` |
| `state-and-scope.md` | §2.5 mutable globals and module constants; §2.6 nesting; §2.16 lexical scoping; §2.18 threading |
| `expressions.md` | §2.7 comprehensions; §2.8 default iterators; §2.11 conditional expressions; §2.14 truthiness |
| `functions.md` | §2.9 generators; §2.10 lambdas; §2.12 default arguments; §2.13 properties; §2.17 decorators; §3.15 getters and setters |
| `tooling.md` | §2.1 pylint and suppressions; §2.19 power features; §2.20 `from __future__` imports |

## style/ — how the code is written

| File | Covers |
|---|---|
| `formatting.md` | §3.1–3.7 semicolons, line length, parentheses, indentation, trailing commas, blank lines, whitespace, shebang; §3.14 statements; §3.13 import layout |
| `docstrings.md` | §3.8 docstrings for modules, tests, functions, overrides and classes; block and inline comments |
| `naming.md` | §3.16 conventions, names to avoid, internal vs public, file names, the Guido table, math notation |
| `strings-logging.md` | §3.10 formatting, accumulation, quotes; §3.10.1 logging calls; §3.10.2 error messages; §3.11 closing resources; §3.12 TODOs |
| `typing.md` | §2.21 and all of §3.19 — annotations, line breaking, `None`, aliases, TypeVars, typing imports, generics |
| `structure.md` | §3.17 `main()` and top-level code; §3.18 function length; §4 consistency |

## Where the guide is deliberately open

Quote character (`'` or `"`), descriptive vs imperative docstring style, hanging-indent width of 2 or 4 spaces in docstring sections, and blank-line usage inside functions. Pick what the file already does; do not raise these as findings.
