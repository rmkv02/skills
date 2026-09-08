# Generators, lambdas, defaults, properties, decorators, accessors (language rules)

**Authority:** language rule — decides which constructs the code may use. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. When the guide is silent, match the surrounding file.

## 2.9 Generators

Fine to use. Document with `Yields:` rather than `Returns:` — the section describes what `next()` produces, not the generator object.

If the generator manages an expensive resource, force cleanup; wrapping the generator in a context manager is the reliable way.

## 2.10 Lambda functions

Okay for one-liners. If the body spans multiple lines or runs past roughly 60–80 characters, make it a named nested function.

Prefer generator expressions to `map()`/`filter()` with a lambda. For common operations use the `operator` module — `operator.mul` over `lambda x, y: x * y`.

## 2.12 Default argument values

Fine, with one hard rule: **never a mutable object as a default**. Defaults are evaluated once, at definition time.

```python
# Yes
def foo(a, b=None):
    if b is None:
        b = []
def foo(a, b: Sequence = ()):   # empty tuple is immutable
    ...

# No
def foo(a, b=[]): ...
def foo(a, b=time.time()): ...        # time of module load, not of call
def foo(a, b=_FOO.value): ...         # flags not parsed yet at import
```

## 2.13 Properties

Properties may control get/set of attributes that need trivial computation or logic, and must behave the way plain attribute access is expected to: cheap, straightforward, unsurprising.

- A property that only reads and writes an internal attribute is not allowed — make the attribute public instead.
- Create properties with `@property`; hand-written descriptors are a power feature (`language/tooling.md` §2.19).
- Do not use properties for computations a subclass may want to override — inheritance with properties is non-obvious.

## 2.17 Function and method decorators

Use judiciously, when there is a clear advantage. Decorators follow the same import and naming rules as functions; their docstring must state that the function is a decorator; write unit tests for them.

No external dependencies inside the decorator itself — no files, sockets, database connections. Decorators run at import time, possibly under `pydoc` or other tooling, where those may not exist. A decorator called with valid parameters should succeed in all cases.

**Never `staticmethod`**, unless forced by an existing library's API — write a module-level function. **`classmethod` only** for named constructors or a class-specific routine that modifies process-wide state such as a cache.

## 3.15 Getters and setters

Use accessor functions when getting or setting carries meaningful behaviour — the value is expensive, or setting invalidates or rebuilds state. The call syntax then signals that something non-trivial happens.

A getter/setter pair that merely reads and writes an internal attribute means the attribute should be public. Name them `get_foo()` / `set_foo()`.

If a value used to be reachable through a property, do not bind new getter/setter functions to that property — let old access break visibly so callers learn the cost changed.
