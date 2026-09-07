#!/usr/bin/env bash
# Mechanical half of a Google Go Style pass. Everything here is decided by
# tooling — gofmt outranks the guide on anything it reports, so never re-derive
# these findings by reading the code.
#
#   ./check_go.sh                 # module rooted at the current directory
#   ./check_go.sh ./internal/...  # a subtree
#   ./check_go.sh handler.go      # explicit files
#
# Prints FINDINGS (what the tools said about the code), RAN, and SKIPPED —
# always all three. Read SKIPPED first: empty FINDINGS with four skipped checks
# means nothing was verified, not that the code is clean. A tool that fails for
# its own reasons (no toolchain, unresolved modules, unreadable cache) lands in
# SKIPPED, never in FINDINGS, so a broken environment cannot read as a pile of
# style defects.
#
# Exit: 0 clean, 1 findings, 2 nothing could be checked.
# No network is initiated: tools run from PATH against the local module cache.

set -uo pipefail

TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=("./...")

findings=""; ran=""; skipped=""; status=0
add_ran()  { ran="${ran}  ${1}"$'\n'; }
add_skip() { skipped="${skipped}  ${1}"$'\n'; }
have()     { command -v "$1" >/dev/null 2>&1; }
indent()   { echo "$1" | sed 's/^/      /'; }
add_finding() {  # <label> <output>
  findings="${findings}  ${1}:"$'\n'"$(indent "$2")"$'\n'; status=1
}

is_env_error() {
  case "$1" in
    *"toolchain not available"*|*"go: downloading go1"*|*"go.mod file not found"*|\
    *"cannot find module"*|*"no required module"*|*"missing go.sum"*|\
    *"cannot find main module"*|*"Failed to discover go env"*|\
    *"context loading failed"*|*"failed to load packages"*|*"build cache"*|\
    *"permission denied"*|*"no Go files"*|*"matched no packages"*|\
    *"directory not found"*) return 0 ;;
  esac
  return 1
}

# run_check <label> -- <command...>
# ok -> RAN. Environment failure -> SKIPPED with cause. Otherwise -> FINDINGS
# plus RAN, because the tool did look at the code.
run_check() {
  label="$1"; shift 2
  if out="$("$@" 2>&1)"; then add_ran "$label"; return; fi
  if [ -z "$out" ]; then add_skip "$label: failed with no output — NOT verified"; return; fi
  if is_env_error "$out"; then
    add_skip "$label: could not run here — NOT verified"
    skipped="${skipped}$(indent "$out")"$'\n'
    return
  fi
  add_finding "$label" "$out"
  add_ran "$label"
}

# gofmt and goimports parse files directly, so they survive a broken module
# graph and are checked first, against a plain file list.
files=""
for t in "${TARGETS[@]}"; do
  case "$t" in
    *.go)      [ -f "$t" ] && files="$files $t" ;;
    ./...|...) files="$files ." ;;
    *)         files="$files ${t%/...}" ;;
  esac
done

if ! have gofmt; then
  add_skip "gofmt: not on PATH — formatting NOT checked"
elif [ -z "${files// /}" ]; then
  add_skip "gofmt: no existing Go files in the given targets — NOT checked"
else
  out="$(gofmt -s -l $files 2>&1)"
  [ -n "$out" ] && add_finding "gofmt -s — not formatted (fix: gofmt -s -w)" "$out"
  add_ran "gofmt -s"
fi

if ! have goimports; then
  add_skip "goimports: not installed — import grouping NOT checked (decisions §3.2)"
elif [ -z "${files// /}" ]; then
  add_skip "goimports: no existing Go files in the given targets — NOT checked"
else
  out="$(goimports -l $files 2>&1)"
  [ -n "$out" ] && add_finding "goimports — import grouping wrong (fix: goimports -w)" "$out"
  add_ran "goimports"
fi

if have go; then run_check "go vet" -- go vet "${TARGETS[@]}"
else add_skip "go: not on PATH — vet and every build-dependent check NOT run"; fi

if have staticcheck; then run_check "staticcheck" -- staticcheck "${TARGETS[@]}"
else add_skip "staticcheck: not installed — extended static analysis NOT run"; fi

if have golangci-lint; then run_check "golangci-lint" -- golangci-lint run "${TARGETS[@]}"
else add_skip "golangci-lint: not installed — lint NOT run"; fi

echo "FINDINGS"; if [ -n "$findings" ]; then printf '%s' "$findings"; else echo "  none"; fi
echo "RAN";      if [ -n "$ran" ];      then printf '%s' "$ran";      else echo "  nothing"; fi
echo "SKIPPED"
if [ -n "$skipped" ]; then
  printf '%s' "$skipped"
  echo "  ^ the above did not run. Their scope is unverified, not clean."
else
  echo "  none"
fi

[ -z "$ran" ] && exit 2
exit $status
