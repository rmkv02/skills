# Lint, power features, future imports (language rules)

**Authority:** language rule — decides which constructs the code may use. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. When the guide is silent, match the surrounding file.

## 2.1 Lint

Run `pylint` with Google's [pylintrc](https://google.github.io/styleguide/pylintrc).

Suppress inappropriate warnings so real ones stay visible, per line:

```python
def do_PUT(self):  # WSGI name, so pylint: disable=invalid-name
```

Warnings are identified by symbolic name (`empty-docstring`); Google-specific ones start with `g-`. Add an explanation when the symbolic name doesn't make the reason obvious. Use `pylint: disable`, not the deprecated `disable-msg`. `pylint --list-msgs` and `pylint --help-msg=invalid-name` explain a code.

For genuinely unused arguments, delete them at the top of the function with a comment:

```python
def viking_cafe_order(spam: str, beans: str, eggs: str | None = None) -> str:
    del beans, eggs  # Unused by vikings.
    return spam + spam + spam
```

`_` or an `unused_` prefix is allowed but no longer encouraged: those break keyword callers and don't enforce that the argument really is unused.

## 2.19 Power features

Avoid custom metaclasses, access to bytecode, on-the-fly compilation, dynamic inheritance, object reparenting, import hacks, reflection (`getattr()` tricks), modification of system internals, `__del__` hooks. Standard-library constructs that use them internally — `abc.ABCMeta`, `dataclasses`, `enum` — are fine.

## 2.20 Modern Python: `from __future__` imports

Encouraged. They let a file adopt newer semantics on older runtimes, per file.

```python
from __future__ import annotations
```

Keep the import until you are confident the code only runs on a sufficiently modern interpreter: even if the feature is unused today, its presence stops later edits from silently depending on the old behaviour.
