# Type annotations (style rules)

**Authority:** style rule — decides how the code is written. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. The Black/Pyink formatter and Google's pylintrc win on anything mechanical.

**Contents:** general rules · line breaking · forward declarations · default values · NoneType · aliases · ignoring types · typing variables · tuples vs lists · type variables · string types · typing imports · conditional imports · circular dependencies · generics

## 2.21 / 3.19.1 General

Annotate and type-check with a checker such as pytype. Annotations live in source files; stub `.pyi` files are for third-party or extension modules.

- `self` and `cls` generally need no annotation; `Self` is available when the type information matters.
- Don't annotate `__init__`'s return type — `None` is the only option.
- Use `Any` when a type genuinely cannot be expressed.
- Not every function must be annotated. At minimum annotate public APIs; also annotate code prone to type errors, code that is hard to understand, and code that has stabilised.

## 3.19.2 Line breaking

Follow the normal indentation rules. Annotated signatures often become one parameter per line; a trailing comma after the last parameter forces the return type onto its own line.

```python
def my_method(
    self,
    first_var: int,
    third_var: Bar | None,
) -> int:
```

Break between parameters, not between a name and its annotation. Align the closing parenthesis with `def`. Putting the return type on the last parameter's line is acceptable; moving the closing parenthesis onto its own line aligned with the opening one is not. Prefer not to break a type at all — if a single name plus type is too long, introduce an alias; breaking after the colon with a 4-space indent is the last resort.

## 3.19.3 Forward declarations

For a class name not yet defined, use `from __future__ import annotations`, or quote the name: `Sequence['MyClass']`.

## 3.19.4 Default values

Spaces around `=` **only** when the parameter has both an annotation and a default: `def func(a: int = 0)`, but `def func(a=0)`.

## 3.19.5 NoneType

If an argument can be `None`, say so. Prefer `X | None` in new code; `Optional[X]` and `Union[X, None]` remain valid.

```python
# Yes
def f(a: str | int | None, b: str | None = None) -> str: ...
# No
def f(a: Union[None, str]) -> str: ...
def f(a: str = None) -> str: ...      # implicit Optional is not accepted
```

## 3.19.6 Type aliases

Alias complex types with a `CapWorded` name, `_Private` if module-local. `: TypeAlias` requires 3.10+.

```python
_LossAndGradient: TypeAlias = tuple[tf.Tensor, tf.Tensor]
ComplexTFMap: TypeAlias = Mapping[str, _LossAndGradient]
```

## 3.19.7 Ignoring types

`# type: ignore` disables checking for a line; pytype also supports targeted `# pytype: disable=attribute-error`.

## 3.19.8 Typing variables

Annotate an assignment when the type is hard to infer: `a: Foo = SomeUndecoratedFunction()`. Do not add new `# type: Foo` trailing comments — they predate 3.6 syntax.

## 3.19.9 Tuples vs lists

A typed list holds one type; a typed tuple is either a repeated type or a fixed sequence of different types — the usual shape of a function's return.

```python
a: list[int] = [1, 2, 3]
b: tuple[int, ...] = (1, 2, 3)
c: tuple[int, str, float] = (1, "2", 3.5)
```

## 3.19.10 Type variables

A `TypeVar` or `ParamSpec` needs a descriptive name **unless** it is both not externally visible and unconstrained. `AnyStr` is the standard choice when several annotations must all be `bytes` or all `str`.

```python
# Yes
_T = TypeVar("_T")
_P = ParamSpec("_P")
AddableType = TypeVar("AddableType", int, float, str)
AnyFunction = TypeVar("AnyFunction", bound=Callable)

# No
T = TypeVar("T")                              # externally visible, undescriptive
_T = TypeVar("_T", int, float, str)           # constrained, so needs a real name
_F = TypeVar("_F", bound=Callable)            # bound counts as constrained
```

## 3.19.11 String types

`str` for text, `bytes` for binary. `typing.Text` is Python 2 compatibility and must not appear in new code. When a function's string types must all match, use `AnyStr`.

## 3.19.12 Imports for typing

Import symbols from `typing` and `collections.abc` **directly**, several per line if convenient — this is the documented exemption from the module-import rule.

```python
from collections.abc import Mapping, Sequence
from typing import Any, Generic, cast, TYPE_CHECKING
```

Treat those names like keywords: don't define your own. On collision, `from typing import Any as AnyType`.

In signatures prefer abstract containers (`Sequence`, `Mapping`) over concrete `list`/`dict`; when a concrete type is required, use the builtin (`tuple[int, str]`), not `typing.Tuple`.

## 3.19.13 Conditional imports

Only in exceptional cases where a type-only import must not exist at runtime; refactoring to allow a normal top-level import is preferred. Put them in `if typing.TYPE_CHECKING:` right after the normal imports, reference the types as strings, define nothing there but typing entities and aliases, no blank lines inside the list, sorted like any import list.

## 3.19.14 Circular dependencies

Circular imports caused by typing are a code smell and a refactoring candidate. As a workaround, replace the offending module with `Any` under a meaningful alias and keep using the real type name in annotations, separating the alias from the imports by one blank line.

```python
from typing import Any

some_mod = Any  # some_mod.py imports this module.

def my_method(self, var: "some_mod.SomeType") -> None: ...
```

## 3.19.15 Generics

Always parameterise a generic — an unparameterised one silently means `Any`.

```python
# Yes
def get_names(employee_ids: Sequence[int]) -> Mapping[int, str]: ...
# No — reads as Sequence[Any] -> Mapping[Any, Any]
def get_names(employee_ids: Sequence) -> Mapping: ...
```

If `Any` really is the right parameter, write it explicitly — but a `TypeVar` is often the better answer, since it ties the input type to the output type.
