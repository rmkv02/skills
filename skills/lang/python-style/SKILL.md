---
name: python-style
description: Applies the Google Python Style Guide (pyguide) to Python code. Use this skill whenever Python (.py) code is written, generated, reviewed, refactored, or discussed — including snippets pasted into chat, diffs, PR reviews, notebook cells, and example code — even when no style review was asked for. Also use for questions like "is this Pythonic?", "is this Google style?", or anything about Python naming, docstrings, imports, exceptions, type annotations, mutable defaults, comprehensions, or logging calls. Do NOT use for other languages (Go is go-style), for .md files (markdown-style owns those), for packaging, dependency or CI questions, or when the user explicitly says to skip style.
license: CC-BY-3.0
---

# Google Python Style

The Google Python Style Guide has two rule sets with different jobs, plus a closing rule that decides ties. This skill mirrors that structure.

| Layer | Where | Authority |
|---|---|---|
| Language rules — which constructs to use at all | `references/language/` | What the code may do |
| Style rules — how the code looks | `references/style/` | How the code is written |
| Be consistent | this file, "Consistency" | Tiebreaker when the guide is silent |

Mechanical authority outranks opinion: `pylint` with Google's [pylintrc](https://google.github.io/styleguide/pylintrc) and the Black/Pyink auto-formatter settle formatting. If a suggestion disagrees with the formatter, the formatter wins.

> Attribution: derived from the Google Python Style Guide (https://google.github.io/styleguide/pyguide.html), licensed CC-BY 3.0.

## Workflow

1. **Delegate mechanical checks.** With shell access, run `scripts/check_py.sh <path>` before reviewing by hand. Line length, whitespace, quote consistency, import order and unused names are decided deterministically. Without shell access, say the tools weren't run rather than guessing their output.
2. **Run the fast pass checklist.** It covers the violations that actually appear in review; it is a screen, not the full ruleset.
3. **Look up specifics in `references/` when the answer must be exact.** Use the routing table. Do not load references preemptively and do not answer fine print from memory — the easy-to-invert rules are `assert` usage, implicit false, `%`-style logging calls, `X | None`, abstract vs concrete container types, and TypeVar naming.
4. **Report findings in the format below**, ordered by severity.

## Consistency

Local consistency wins when the guide is silent, and only then. Match the surrounding file for choices the guide leaves open (quote character, descriptive vs imperative docstrings, hanging indent width). Consistency is not a defence for keeping a style the guide has since moved away from, and never a defence for a bug.

## Fast pass checklist

Each item points at the file with the exact rule. Open one file, not the set.

### Imports
- [ ] `import` names modules and packages, never individual classes or functions — exempt: `typing`, `collections.abc`, `typing_extensions`. [language/imports-packages.md §2.2]
- [ ] Full package paths; no relative imports. [language/imports-packages.md §2.3]
- [ ] One import per line, grouped `__future__` → stdlib → third-party → own sub-packages, sorted lexicographically by full path. [style/formatting.md §3.13]

### Naming
- [ ] `module_name`, `ClassName`, `function_name`, `GLOBAL_CONSTANT_NAME`, `_internal`; no dashes in module names, `.py` always. [style/naming.md §3.16]
- [ ] Single-character names only for counters, `e` in except, `f` in with, unconstrained private TypeVars, or established math notation. [style/naming.md §3.16.1]
- [ ] No dunder-wrapped custom names, no type baked into the name (`id_to_name_dict`). [style/naming.md §3.16.1]
- [ ] Prefer one leading underscore over two — name mangling hurts testability. [style/naming.md §3.16.2]

### Docstrings and comments
- [ ] Docstring mandatory for public API, nontrivial size, or non-obvious logic; `"""` always; summary line one physical line ending in a period. [style/docstrings.md §3.8.1, §3.8.3]
- [ ] `Args:` / `Returns:` (`Yields:` for generators) / `Raises:` where they carry information the signature doesn't. [style/docstrings.md §3.8.3]
- [ ] Class docstring says what an instance *represents*, with an `Attributes:` section for public attributes. [style/docstrings.md §3.8.4]
- [ ] Overriding method may skip the docstring only when decorated `@override` and behaviour is unchanged. [style/docstrings.md §3.8.3.1]
- [ ] `TODO: <bug link> - explanation`, not a person's name. [style/strings-logging.md §3.12]

### Exceptions and errors
- [ ] No bare `except:`, no catching `Exception`, unless re-raising or at a deliberate isolation boundary. [language/exceptions.md §2.4]
- [ ] `assert` never validates preconditions or carries application logic — it must be removable. Fine inside pytest tests. [language/exceptions.md §2.4]
- [ ] Custom exceptions inherit an existing class, end in `Error`, don't repeat the module (`foo.FooError`). [language/exceptions.md §2.4]
- [ ] `try` body minimal; cleanup in `finally`. [language/exceptions.md §2.4]
- [ ] Error message matches the actual condition and marks interpolated values clearly (`f'Not a probability: {p=}'`). [style/strings-logging.md §3.10.2]

### Language constructs
- [ ] No mutable default arguments; `None` plus in-body default, or an immutable literal. [language/functions.md §2.12]
- [ ] Mutable global state avoided; module constants `CAPS_WITH_UNDER`, internal ones underscored. [language/state-and-scope.md §2.5]
- [ ] Comprehensions: at most one `for` clause, no stacked filters. [language/expressions.md §2.7]
- [ ] Default iterators: `for k in adict`, `for line in afile`; never `.keys()`/`.readlines()` for plain iteration. [language/expressions.md §2.8]
- [ ] Implicit false (`if not seq:`), but `is None` for None and explicit `== 0` for integers. [language/expressions.md §2.14]
- [ ] Never `staticmethod`; `classmethod` only for named constructors or class-wide state. [language/functions.md §2.17]
- [ ] Files, sockets and other stateful resources closed via `with` or `contextlib.closing`. [style/strings-logging.md §3.11]
- [ ] No reliance on built-in type atomicity in threaded code; use `queue.Queue` or explicit locks. [language/state-and-scope.md §2.18]

### Strings and logging
- [ ] f-string, `%`, or `.format()`; never build a message with `+` across pieces. [style/strings-logging.md §3.10]
- [ ] No `+=` accumulation in a loop — append to a list and `''.join`, or use `io.StringIO`. [style/strings-logging.md §3.10]
- [ ] Logging pattern-string calls take a literal first argument and lazy parameters: `logging.info('x: %s', x)`, never an f-string. [style/strings-logging.md §3.10.1]

### Type annotations
- [ ] Public APIs annotated; `self`/`cls` and `__init__` return type left alone. [style/typing.md §3.19.1]
- [ ] Optional is explicit: `str | None`, never a bare `str` with a `None` default. [style/typing.md §3.19.5]
- [ ] Abstract containers in signatures (`Sequence`, `Mapping`) over concrete `list`/`dict`; built-in generics over `typing.List`. [style/typing.md §3.19.12]
- [ ] Generics parameterised — a bare `Sequence` silently means `Sequence[Any]`. [style/typing.md §3.19.15]
- [ ] TypeVar names descriptive unless private *and* unconstrained: `_T` fine, `T` and `_F = TypeVar("_F", bound=Callable)` not. [style/typing.md §3.19.10]
- [ ] `str` for text, `bytes` for binary; `typing.Text` is dead. [style/typing.md §3.19.11]

### Layout
- [ ] 4-space indent, never tabs; 80-column target, no backslash continuations. [style/formatting.md §3.2, §3.4]
- [ ] No spaces around `=` for keyword arguments, *unless* an annotation is present, then spaces are required. [style/formatting.md §3.6]
- [ ] Executable logic lives in `main()` behind `if __name__ == '__main__':`. [style/structure.md §3.17]

## Which reference to load

One question, one file. Start at `references/INDEX.md` only if the question fits no row.

| The question is about | Read |
|---|---|
| What may be imported, module vs symbol, full paths, import exemptions | `references/language/imports-packages.md` |
| Raising, catching, custom exception classes, `assert`, `try` scope | `references/language/exceptions.md` |
| Mutable globals, module constants, nested functions and classes, closures, threading | `references/language/state-and-scope.md` |
| Comprehensions, generator expressions, default iterators, conditional expressions, truthiness | `references/language/expressions.md` |
| Generators, lambdas, default argument values, properties, decorators, getters and setters | `references/language/functions.md` |
| pylint and suppressions, power features, `from __future__` imports | `references/language/tooling.md` |
| Line length, indentation, whitespace, parentheses, blank lines, statements, import layout, shebang | `references/style/formatting.md` |
| Docstring structure, `Args`/`Returns`/`Raises`, module, class, test and overridden-method docstrings, comments | `references/style/docstrings.md` |
| Naming conventions, names to avoid, file names, internal vs public, math notation | `references/style/naming.md` |
| String formatting and quotes, accumulation, logging calls, error messages, resource closing, TODOs | `references/style/strings-logging.md` |
| Annotations: syntax, line breaking, `None`, aliases, TypeVars, typing imports, generics, circular deps | `references/style/typing.md` |
| `main()`, function length, top-level code, consistency | `references/style/structure.md` |

If the reference doesn't settle it, say so and fall back to consistency with the surrounding code rather than inventing a rule.

## Reporting findings

For each violation:

```
[severity] rule name — file:line
  current: <the code as written>
  fix:     <the corrected code>
  why:     <one sentence: the failure the rule prevents>
```

Order by severity: correctness and safety (mutable defaults, bare `except:`, `assert` as validation, resources never closed, unparameterised generics hiding `Any`) → clarity (naming, docstrings, string building) → layout nits the formatter would fix anyway. Both snippets must be valid Python.

- **Don't pad the list.** Clean code gets one line saying so. Manufactured nits train people to ignore reviews.
- **Don't bury a real bug under style.** Lead with the correctness problem.

## Out of scope

Non-Python code — Go is `go-style`. Markdown files: layout and prose in READMEs and design docs are `markdown-style`; only docstrings and comments inside `.py` belong here. Packaging, dependency resolution, virtualenvs, CI configuration. Framework-specific idioms (Django models, pandas chains) unless the question is about style. Language trivia with no code in play. And when the user says "don't worry about style" — note a correctness bug if you see one, skip the rest.

## Provenance and maintenance

- Source of truth: https://google.github.io/styleguide/pyguide.html
- Reference files are a distillation, not a copy, split so one lookup costs one small file. Re-derive the affected file when upstream changes; never patch this checklist without updating the matching reference.
- Last synced with upstream: 2026-09-07.
- Owner and version: see `registry.yaml` at the repository root.
