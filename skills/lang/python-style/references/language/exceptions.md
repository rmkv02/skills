# Exceptions (language rules)

**Authority:** language rule — decides which constructs the code may use. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. When the guide is silent, match the surrounding file.

## 2.4 Exceptions

Exceptions are allowed, with conditions.

**Use built-ins where they fit.** `ValueError` for a violated precondition such as a bad argument. Reach for a custom class only when callers need to distinguish the failure.

**`assert` is not validation.** Never use `assert` in place of a conditional or to check a precondition, and never let application logic depend on it — assert conditionals are not guaranteed to be evaluated. The litmus test: removing the `assert` must not break the code. Inside pytest-based tests, `assert` is the expected way to state expectations.

```python
# Yes
def connect_to_next_port(self, minimum: int) -> int:
    if minimum < 1024:
        raise ValueError(f'Min. port must be at least 1024, not {minimum}.')
    port = self._find_next_open_port(minimum)
    if port is None:
        raise ConnectionError(f'Could not connect to service on port {minimum} or higher.')
    return port

# No — an assert here is a validation the runtime may skip
def connect_to_next_port(self, minimum: int) -> int:
    assert minimum >= 1024, 'Minimum port must be at least 1024.'
```

**Custom exceptions** must inherit from an existing exception class, end in `Error`, and not repeat the module name — `foo.Error`, not `foo.FooError`.

**Never `except:` bare, never catch `Exception`** — unless you are re-raising, or deliberately creating an isolation point where exceptions are recorded and suppressed (guarding a thread's outermost block, for instance). A bare except swallows misspelled names, `sys.exit()`, Ctrl+C and test failures.

**Keep the `try` body minimal.** The more code inside `try`, the more likely an unexpected line raises and the handler hides a real error.

**Use `finally`** for work that must happen either way, typically cleanup. For resources, prefer `with` — see `style/strings-logging.md` §3.11.
