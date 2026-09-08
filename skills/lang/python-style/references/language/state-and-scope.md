# Global state, nesting, scoping, threading (language rules)

**Authority:** language rule — decides which constructs the code may use. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. When the guide is silent, match the surrounding file.

## 2.5 Mutable global state

Avoid mutable global state.

In the rare warranted case, declare the entity at module level or as a class attribute and make it internal with a leading underscore; expose it through public functions or methods if external access is needed. Document in a comment why the design requires it.

Module-level constants are permitted and encouraged: `_MAX_HOLY_HANDGRENADE_COUNT = 3` internally, `SIR_LANCELOTS_FAVORITE_COLOR = "blue"` publicly. Constants use all caps with underscores (`style/naming.md` §3.16).

## 2.6 Nested / local / inner classes and functions

Fine when they close over a local value other than `self` or `cls`. Inner classes are fine.

Do not nest a function merely to hide it from a module's users — prefix its name with an underscore at module level instead, so tests can still reach it.

## 2.16 Lexical scoping

Allowed. Closures over enclosing-scope variables are normal Python; be aware that a name assigned anywhere in a function is local throughout that function, which can make an enclosing-scope read fail at runtime.

## 2.18 Threading

Do not rely on the atomicity of built-in types. Dict operations look atomic but are not in corner cases — a Python-level `__hash__` or `__eq__`, for example — and variable assignment depends on dicts in turn.

Prefer `queue.Queue` for passing data between threads. Otherwise use `threading` and its primitives, favouring `threading.Condition` over raw low-level locks.
