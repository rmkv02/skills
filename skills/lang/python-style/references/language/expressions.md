# Comprehensions, iterators, conditionals, truthiness (language rules)

**Authority:** language rule — decides which constructs the code may use. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. When the guide is silent, match the surrounding file.

## 2.7 Comprehensions and generator expressions

Allowed for simple cases. **One `for` clause maximum, no stacked filter expressions.** Optimise for readability, not for fitting everything in one expression; use a loop when the logic outgrows a single clause.

```python
# Yes
result = [mapping_expr for value in iterable if filter_expr]
result = [
    is_valid(metric={'key': value})
    for value in interesting_iterable
    if a_longer_filter_expression(value)
]

# No — multiple for clauses
result = [(x, y) for x in range(10) for y in range(5) if x * y > 10]
```

## 2.8 Default iterators and operators

Use the default iterators and operators of types that provide them — lists, dicts, files.

```python
# Yes
for key in adict: ...
for k, v in adict.items(): ...
for line in afile: ...
if obj in alist: ...

# No
for key in adict.keys(): ...
for line in afile.readlines(): ...
```

Do not mutate a container while iterating over it.

## 2.11 Conditional expressions

Allowed for simple cases: each of the three parts — true-expression, if-expression, else-expression — must fit on one line. Anything more complicated becomes a full `if` statement.

```python
one_line = 'yes' if predicate(value) else 'no'
the_longest = (
    'yes, true, affirmative'
    if predicate(value)
    else 'no, false, negative')
```

## 2.14 True/false evaluations

Use implicit false where possible — `if foo:` rather than `if foo != []:` — with these caveats:

- **`None` checks are always explicit:** `if foo is None:` / `is not None`. Another falsy value is not the same as unset.
- **Never compare a bool with `==`.** Use `if not x:`; to separate `False` from `None`, chain: `if not x and x is not None:`.
- **Sequences:** `if seq:` and `if not seq:`, never `if len(seq):`.
- **Integers carry risk:** implicit false conflates `0` with `None`. Compare a known integer explicitly — `if i % 10 == 0:`, not `if not i % 10:`.
- `'0'` (the string) is true.
- NumPy arrays may raise in a boolean context — test `if not users.size`.

```python
# Yes
if not users: print('no users')
if i % 10 == 0: self.handle_multiple_of_ten()
def f(x=None):
    if x is None:
        x = []

# No
if len(users) == 0: print('no users')
if not i % 10: self.handle_multiple_of_ten()
def f(x=None):
    x = x or []
```
