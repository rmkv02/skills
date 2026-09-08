#!/usr/bin/env bash
# Deterministic Python style checks. Everything here is settled by tooling, so
# the model should not spend tokens re-deriving it.
#
# Usage: scripts/check_py.sh [path]   (default: current directory)
# Exit:  0 = clean, 1 = findings, 2 = no Python toolchain
#
# Missing tools are reported, not fatal — report what did not run rather than
# implying a clean result.

set -uo pipefail

TARGET="${1:-.}"
FINDINGS=0
SKIPPED=()

have() { command -v "$1" >/dev/null 2>&1; }
section() { printf '\n=== %s ===\n' "$1"; }

if ! have python3; then
  echo "no 'python3' on PATH — cannot run any check" >&2
  exit 2
fi

# Google's pylintrc, if the project vendored it next to the code.
PYLINTRC=""
for candidate in "$TARGET/pylintrc" "$TARGET/.pylintrc" "$PWD/pylintrc"; do
  [ -f "$candidate" ] && { PYLINTRC="$candidate"; break; }
done

section "syntax"
if OUT="$(python3 -m compileall -q "$TARGET" 2>&1)"; then
  echo "clean"
else
  echo "$OUT"; FINDINGS=1
fi

section "pylint"
if have pylint; then
  if [ -n "$PYLINTRC" ]; then
    echo "using $PYLINTRC"
    OUT="$(pylint --rcfile="$PYLINTRC" "$TARGET" 2>&1)"
  else
    echo "no pylintrc found — running with defaults; Google's is at https://google.github.io/styleguide/pylintrc"
    OUT="$(pylint "$TARGET" 2>&1)"
  fi
  if [ $? -eq 0 ]; then echo "clean"; else echo "$OUT"; FINDINGS=1; fi
else
  SKIPPED+=("pylint (pip install pylint)")
fi

section "formatter (pyink/black)"
if have pyink; then
  if OUT="$(pyink --check --diff "$TARGET" 2>&1)"; then echo "clean"; else echo "$OUT"; FINDINGS=1; fi
elif have black; then
  if OUT="$(black --check --diff "$TARGET" 2>&1)"; then echo "clean"; else echo "$OUT"; FINDINGS=1; fi
else
  SKIPPED+=("pyink or black (pip install pyink)")
fi

section "type check"
if have pytype; then
  if OUT="$(pytype "$TARGET" 2>&1)"; then echo "clean"; else echo "$OUT"; FINDINGS=1; fi
elif have mypy; then
  if OUT="$(mypy "$TARGET" 2>&1)"; then echo "clean"; else echo "$OUT"; FINDINGS=1; fi
else
  SKIPPED+=("pytype or mypy (pip install pytype)")
fi

section "summary"
if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "not run (tool unavailable):"
  for t in "${SKIPPED[@]}"; do echo "  - $t"; done
  echo "state this in the review; do not report these areas as clean."
fi

if [ "$FINDINGS" -eq 0 ]; then
  echo "mechanical checks passed — review the semantic rules by hand."
else
  echo "mechanical findings above — fix these before commenting on style."
fi

exit "$FINDINGS"
