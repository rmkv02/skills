# Entry points, function length, consistency (style rules)

**Authority:** style rule — decides how the code is written. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. The Black/Pyink formatter and Google's pylintrc win on anything mechanical.

## 3.17 Main

`pydoc` and unit tests require modules to be importable, so an executable's real work goes in a `main()` function guarded by `if __name__ == '__main__':`.

```python
def main():
    ...

if __name__ == '__main__':
    main()
```

With absl:

```python
from absl import app

def main(argv: Sequence[str]):
    ...

if __name__ == '__main__':
    app.run(main)
```

Everything at top level runs on import — do not call functions, build objects or perform work there that should not happen when the file is merely imported or documented. Decorators are a special case of top-level code and run at import time too (`language/functions.md` §2.17).

## 3.18 Function length

Prefer small, focused functions. There is no hard limit, but past roughly 40 lines, ask whether the function can be split without harming the structure.

The argument is about the future: a function that works perfectly today gains behaviour in a few months, and length is where hard-to-find bugs accumulate. Long existing functions are not sacred — if one is hard to debug, or you want part of it elsewhere, break it up.

## 4 Consistency

Be consistent. When editing, read the surrounding code and match it: if it uses `_idx` suffixes for index variables, use them too.

The limits: consistency applies most strongly locally and to choices the guide leaves open. It is not a justification for perpetuating an old style without weighing the newer one, nor for ignoring the codebase's drift toward newer conventions over time.
