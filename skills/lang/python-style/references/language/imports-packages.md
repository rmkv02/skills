# Imports and packages (language rules)

**Authority:** language rule — decides which constructs the code may use. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. When the guide is silent, match the surrounding file.

## 2.2 Imports

Import modules and packages, not the individual classes, functions or types inside them. `x.Obj` then tells every reader where `Obj` came from.

- `import x` — for packages and modules.
- `from x import y` — where `x` is the package prefix and `y` the module name.
- `from x import y as z` — only when two `y` modules collide, when `y` collides with a top-level name in this module, when `y` collides with a public parameter name, when `y` is inconveniently long, or when `y` is too generic in context (`from storage.file_system import options as fs_options`).
- `import y as z` — only for standard abbreviations (`import numpy as np`).

```python
from sound.effects import echo
echo.EchoFilter(input, output, delay=0.7, atten=4)
```

Never use relative imports, even inside the same package — the full package name prevents importing the same module twice under two names.

### 2.2.4.1 Exemptions

Symbols may be imported directly from `typing`, `collections.abc`, and `typing_extensions`, since they support static analysis and read like keywords. `six.moves` redirects are also exempt. Layout of those imports: `style/formatting.md` §3.13 and `style/typing.md` §3.19.12.

## 2.3 Packages

Import every module by its full path location.

```python
# Yes — either form, both unambiguous
import absl.flags
from absl import flags
from doctor.who import jodie

# No — depends on sys.path; which jodie is this?
import jodie
```

Do not assume the main binary's directory is on `sys.path`. Read `import jodie` as referring to a third-party or top-level package named `jodie`, never to a sibling `jodie.py`.
