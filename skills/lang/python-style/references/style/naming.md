# Naming (style rules)

**Authority:** style rule — decides how the code is written. Distilled from https://google.github.io/styleguide/pyguide.html — last synced 2026-09-07; re-derive from upstream rather than patching in place. The Black/Pyink formatter and Google's pylintrc win on anything mechanical.

**Contents:** conventions · names to avoid · internal vs public · file names · the Guido table · math notation

## 3.16 Naming

`module_name`, `package_name`, `ClassName`, `method_name`, `ExceptionName`, `function_name`, `GLOBAL_CONSTANT_NAME`, `global_var_name`, `instance_var_name`, `function_parameter_name`, `local_var_name`, `query_proper_noun_for_thing`, `send_acronym_via_https`.

Names describe. Avoid abbreviations, especially ones ambiguous outside your project, and never abbreviate by deleting letters inside a word. Filenames always end `.py` and never contain dashes.

## 3.16.1 Names to avoid

- Single characters, except: counters and iterators (`i`, `j`, `k`, `v`), `e` for an exception in `except`, `f` for a file handle in `with`, unconstrained private type variables (`_T = TypeVar("_T")`), and names matching established notation from a cited paper or algorithm. Descriptiveness should scale with the name's visibility — `i` is fine in a five-line block, vague across nested scopes.
- Dashes in any package or module name.
- `__double_leading_and_trailing_underscore__` names — reserved by Python.
- Offensive terms.
- Names that bake in the type: `id_to_name_dict`.

## 3.16.2 Naming conventions

- "Internal" means internal to a module, or protected/private within a class.
- One leading underscore marks module-level and class-level internals; linters flag protected access. Unit tests may read protected constants of the module under test.
- Two leading underscores mangle the name and are **discouraged** — worse readability and testability, and not truly private. Prefer one.
- Related classes and top-level functions live together in a module; there is no one-class-per-file rule.
- `CapWords` for classes, `lower_with_under.py` for modules — a module named after its class is confusing.
- New unit test files use PEP 8 method names: `test_<method_under_test>_<state>`. For consistency with legacy CapWords modules, `test<MethodUnderTest>_<state>` is tolerated.

## 3.16.3 File naming

`.py` extension, no dashes — otherwise the file can't be imported or unit-tested. For an extension-less executable, use a symlink or a `exec "$0.py" "$@"` wrapper.

## 3.16.4 The table

| Type | Public | Internal |
|---|---|---|
| Packages | `lower_with_under` | |
| Modules | `lower_with_under` | `_lower_with_under` |
| Classes | `CapWords` | `_CapWords` |
| Exceptions | `CapWords` | |
| Functions | `lower_with_under()` | `_lower_with_under()` |
| Global/class constants | `CAPS_WITH_UNDER` | `_CAPS_WITH_UNDER` |
| Global/class variables | `lower_with_under` | `_lower_with_under` |
| Instance variables | `lower_with_under` | `_lower_with_under` (protected) |
| Method names | `lower_with_under()` | `_lower_with_under()` (protected) |
| Function/method parameters | `lower_with_under` | |
| Local variables | `lower_with_under` | |

## 3.16.5 Mathematical notation

In maths-heavy code, short names matching a reference paper are preferred over style-compliant ones. When you do that: cite the source (hyperlink to the paper if possible) in a comment or docstring; still prefer descriptive names for public APIs; and silence the linter narrowly with `pylint: disable=invalid-name` — per line for a few variables, at the top of a block for many.
