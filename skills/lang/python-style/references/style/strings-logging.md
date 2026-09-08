# Strings, logging, error messages, resources, TODOs (style rules)

**Authority:** style rule — decides how the code is written. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. The Black/Pyink formatter and Google's pylintrc win on anything mechanical.

**Contents:** string formatting · accumulation · quotes · multi-line strings · logging · error messages · closing resources · TODO comments

## 3.10 Strings

Use an f-string, the `%` operator, or `.format()` — even when every parameter is already a string. A single `+` join is fine; formatting with `+` is not.

```python
# Yes
x = f'name: {name}; score: {n}'
x = 'name: %s; score: %d' % (name, n)
x = 'name: {}; score: {}'.format(name, n)
x = a + b

# No
x = 'name: ' + name + '; score: ' + str(n)
```

**Never accumulate a string with `+`/`+=` in a loop** — it can be quadratic, and the CPython optimisation that sometimes hides this is an implementation detail. Append substrings to a list and `''.join(...)` after the loop, or write into an `io.StringIO`.

```python
# Yes
items = ['<table>']
for last_name, first_name in employee_list:
    items.append('<tr><td>%s, %s</td></tr>' % (last_name, first_name))
items.append('</table>')
employee_table = ''.join(items)
```

**Quotes:** pick `'` or `"` and be consistent within a file; switch only to avoid escaping. Prefer `"""` for multi-line strings; `'''` is allowed for non-docstring multi-line strings only in projects that use `'` everywhere. Docstrings are `"""` regardless.

Multi-line strings do not follow program indentation. To avoid embedded leading spaces, use concatenated single-line strings or `textwrap.dedent()`.

## 3.10.1 Logging

For logging functions taking a pattern string, always pass a **string literal** first — never an f-string — with the parameters as separate arguments. Some logging backends index the unexpanded pattern, and lazy interpolation avoids rendering messages nobody outputs.

```python
# Yes
logging.info('Current $PAGER is: %s', os.getenv('PAGER', default=''))
# No
logging.info(f'Current $PAGER is: {os.getenv("PAGER", default="")}')
```

## 3.10.2 Error messages

Three requirements: the message matches the actual error condition precisely; interpolated pieces are clearly identifiable as such; and the result is easy to grep.

```python
# Yes
if not 0 <= p <= 1:
    raise ValueError(f'Not a probability: {p=}')
# No — also false for NaN, so the message can lie
if p < 0 or p > 1:
    raise ValueError(f'Not a probability: {p=}')
```

Do not assert a cause the code hasn't established: log the actual reason (`'Could not remove directory (reason: %r): %r'`) rather than guessing at it.

## 3.11 Files, sockets and other stateful resources

Close them explicitly — this extends to database connections, mmaps, h5py files, pyplot figures. Leaving them open exhausts file descriptors, blocks moves, deletes and unmounts, and lets code read or write something that is logically closed.

Do not rely on destructors: there is no guarantee when `__del__` runs, implementations differ, and stray references in globals or tracebacks extend lifetimes arbitrarily.

```python
with open("hello.txt") as hello_file:
    for line in hello_file:
        print(line)

import contextlib
with contextlib.closing(urllib.urlopen("http://www.python.org/")) as page:
    ...
```

Where context management is genuinely infeasible, document how the resource's lifetime is managed.

## 3.12 TODO comments

Use `TODO` for temporary, short-term or good-enough-for-now code. Format: `TODO`, colon, a link to context — ideally a tracked bug — then a hyphen and an explanation.

```python
# TODO: crbug.com/192795 - Investigate cpufreq optimizations.
```

The older `TODO(crbug.com/192795):` form is discouraged in new code, and a person or team as the context (`TODO: @user - ...`) should be avoided entirely. "Do X later" needs a specific date or a specific event a future maintainer can recognise.
