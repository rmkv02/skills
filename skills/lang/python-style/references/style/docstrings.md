# Docstrings and comments (style rules)

**Authority:** style rule — decides how the code is written. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. The Black/Pyink formatter and Google's pylintrc win on anything mechanical.

**Contents:** docstring basics · modules · test modules · functions and methods · overridden methods · classes · block and inline comments · punctuation

## 3.8.1 Docstrings

Always `"""`, even for one-liners. A docstring is a summary line — one physical line, within 80 characters, ending in a period, question mark or exclamation point. If more follows, put a blank line after the summary and start the rest at the same column as the opening quote.

## 3.8.2 Modules

Files start with a docstring describing contents and usage: a one-line summary, a blank line, then the overall description, optionally listing exported classes and functions and a typical usage example. License boilerplate as the project requires.

### 3.8.2.1 Test modules

Module docstrings are not required for test files. Add one only when it carries real information — how to run the test, an unusual setup pattern, an external dependency. `"""Tests for foo.bar."""` adds nothing and should be omitted.

## 3.8.3 Functions and methods

"Function" here means function, method, generator or property. A docstring is **mandatory** when the function is part of the public API, is of nontrivial size, or has non-obvious logic.

The docstring must let a reader write a call without reading the body: calling syntax and semantics, not implementation details — except details the caller must know, such as mutating an argument.

Descriptive (`"""Fetches rows from a Bigtable."""`) or imperative (`"""Fetch rows..."""`) style, consistent within a file. A `@property` docstring reads like an attribute description (`"""The Bigtable path."""`), not `"""Returns the path."""`.

Sections, each heading ending in a colon, body kept at a hanging indent of 2 or 4 spaces consistently:

- **`Args:`** — every parameter by name, description after a colon and space or newline; hanging indent for long descriptions. Include types only where there is no annotation. List varargs as `*foo` and `**bar`.
- **`Returns:`** (or **`Yields:`** for generators) — the semantics of the value, including anything the annotation doesn't convey. Omit for `None`, or when the docstring opens with "Returns"/"Yields" and that sentence says enough. Describe a tuple return as a whole ("A tuple (mat_a, mat_b), where..."), not as pseudo-named multiple values. For a generator, document what `next()` yields.
- **`Raises:`** — exceptions relevant to the interface, same formatting as `Args:`. Do not document exceptions raised when the caller violates the documented API.

Sections may be dropped entirely when the name and signature already say everything.

```python
def fetch_smalltable_rows(
    table_handle: smalltable.Table,
    keys: Sequence[bytes | str],
    require_all_keys: bool = False,
) -> Mapping[bytes, tuple[str, ...]]:
    """Fetches rows from a Smalltable.

    Retrieves rows pertaining to the given keys from the Table instance.

    Args:
      table_handle: An open smalltable.Table instance.
      keys: A sequence of strings representing the key of each table row to
        fetch.
      require_all_keys: If True, only rows with values set for all keys will be
        returned.

    Returns:
      A dict mapping keys to the corresponding table row data fetched.

    Raises:
      IOError: An error occurred accessing the smalltable.
    """
```

### 3.8.3.1 Overridden methods

A method overriding a base-class method needs no docstring if it is decorated with `@override` (from `typing` or `typing_extensions`) — unless it materially refines the contract or adds side effects, in which case document at least the differences. Without `@override`, a docstring is required.

## 3.8.4 Classes

Docstring below the class definition. It opens with a one-line summary of what an *instance represents* — including for `Exception` subclasses, which describe the error, not the situation that triggers it. Do not restate that the class is a class.

Public attributes (properties excluded) go in an `Attributes:` section formatted like `Args:`.

```python
class CheeseShopAddress:
    """The address of a cheese shop.

    Attributes:
      likes_spam: A boolean indicating if we like SPAM or not.
    """
```

## 3.8.5 Block and inline comments

Comment the tricky parts — anything you would have to explain in review. Complicated operations get a few lines above them; non-obvious details get an end-of-line comment starting at least two spaces from the code, with a space after `#`.

Never describe *what* the code does; assume the reader knows Python better than you do and needs to know why.

## 3.8.6 Punctuation, spelling, grammar

Comments read like narrative text: proper capitalization and punctuation, usually complete sentences. End-of-line comments may be less formal, but be consistent.
