#!/usr/bin/env bash
# Mechanical half of a Google Markdown Style pass. Everything here is decided by
# counting characters, not by judgment — a formatter configured in the repo
# outranks this script, and this script outranks memory.
#
#   ./check_markdown.sh                # every .md under the current directory
#   ./check_markdown.sh docs/          # a subtree
#   ./check_markdown.sh README.md      # explicit files
#
# Prints FINDINGS (what the checks said about the files), RAN, and SKIPPED —
# always all three. Read SKIPPED first: empty FINDINGS next to a list of skipped
# checks means nothing was verified, not that the docs are clean. A check that
# fails for its own reasons (tool missing, no project config, unreadable file)
# lands in SKIPPED, never in FINDINGS, so a bare environment cannot read as a
# pile of style defects.
#
# What is NOT checked here, because it needs judgment: whether a table should be
# a list, whether a link title is informative in context, whether the document
# needs to exist at all. Those stay in SKILL.md.
#
# Exit: 0 clean, 1 findings, 2 nothing could be checked.
# No network is initiated.

set -uo pipefail

TARGETS=("$@")
[ ${#TARGETS[@]} -eq 0 ] && TARGETS=(".")

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
    *"command not found"*|*"No such file or directory"*|*"Cannot find module"*|\
    *"not recognized"*|*"ENOENT"*|*"permission denied"*|*"Permission denied"*|\
    *"EACCES"*|*"npm ERR"*|*"Could not resolve"*) return 0 ;;
  esac
  return 1
}

# --- file list ---------------------------------------------------------------
files=()
for t in "${TARGETS[@]}"; do
  if [ -f "$t" ]; then
    files+=("$t")
  elif [ -d "$t" ]; then
    while IFS= read -r f; do files+=("$f"); done < <(
      find "$t" -type f -name '*.md' \
        -not -path '*/.git/*' -not -path '*/node_modules/*' \
        -not -path '*/vendor/*' -not -path '*/.venv/*' | sort
    )
  else
    add_skip "$t: no such file or directory — NOT checked"
  fi
done

if [ ${#files[@]} -eq 0 ]; then
  echo "FINDINGS"; echo "  none"
  echo "RAN";      echo "  nothing"
  echo "SKIPPED";  printf '%s' "${skipped:-  no Markdown files in the given targets}"
  echo "  ^ nothing was verified."
  exit 2
fi

# --- built-in source checks --------------------------------------------------
# One pass per file, fence-aware. Every rule below is mechanical; anything that
# needed a judgment call was left out on purpose.
builtin_out=""
for f in "${files[@]}"; do
  [ -r "$f" ] || { add_skip "$f: unreadable — NOT checked"; continue; }
  out="$(LC_ALL=C awk -v F="$f" '
    function emit(ln, ref, msg) { printf "%s:%d: [%s] %s\n", F, ln, ref, msg }
    function slug(s) { s = tolower(s); gsub(/[^a-z0-9 ]/, "", s); gsub(/  +/, " ", s); return s }
    # awk runs under LC_ALL=C so length() counts bytes; drop UTF-8 continuation
    # bytes to get the character count the 80-column rule is actually about.
    function clen(s,   t) { t = s; gsub(/[\200-\277]/, "", t); return length(t) }
    # Inline code spans are literal text: a <br> or [here]( inside backticks is
    # quoted, not written. Strip them before any content check.
    function bare(s,   t) { t = s; gsub(/`[^`]*`/, "", t); return t }
    function trackHeading(ln, level, text,   key) {
      if (firstLevel == 0) {
        firstLevel = level
        if (level != 1) emit(ln, "§8.4", "first heading of the document is H" level ", expected a single H1 title")
      }
      if (level == 1) { h1++; if (h1 == 1) h1Line = ln; else emit(ln, "§8.4", "second H1 — one H1 per document, the rest H2 or deeper") }
      if (level == 2 && firstH2 == 0) firstH2 = ln
      key = slug(text)
      if (key != "" && (key in seen)) emit(ln, "§8.2", "duplicate heading name (also line " seen[key] ") — anchors collide")
      else seen[key] = ln
      listSince = 0
    }
    { L[NR] = $0 }
    END {
      n = NR; fence = 0; fm = 0; h1 = 0; firstLevel = 0
      h1Line = 0; firstH2 = 0; introSeen = 0; listSince = 0; fenceOpen = 0
      for (i = 1; i <= n; i++) {
        line = L[i]
        if (i == 1 && line == "---") { fm = 1; continue }
        if (fm) { if (line == "---" || line == "...") fm = 0; continue }

        if (line ~ /^[ \t]*(```|~~~)/) {
          marker = line; sub(/^[ \t]*/, "", marker)
          ch = substr(marker, 1, 1); run = 0
          while (substr(marker, run + 1, 1) == ch) run++
          if (!fence) {
            fence = 1; fenceOpen = i; fenceChar = ch; fenceLen = run
            info = substr(marker, run + 1); gsub(/^[ \t]+|[ \t]+$/, "", info)
            if (info == "") emit(i, "§10.4", "fenced code block with no language declared")
            continue
          }
          # Only a fence of the same character and at least the same length
          # closes the block; anything shorter is content being quoted.
          if (ch == fenceChar && run >= fenceLen && substr(marker, run + 1) ~ /^[ \t]*$/) { fence = 0; continue }
        }
        if (fence) continue

        if (line ~ /[ \t]+$/) emit(i, "§6", "trailing whitespace (use a trailing backslash for a deliberate break)")

        isHeading = (line ~ /^#{1,6}( |$)/)
        isTable   = (line ~ /\|/)
        hasLink   = (index(line, "](") > 0 || line ~ /^\[[^]]+\]:/ || line ~ /https?:\/\//)
        width = clen(line)
        if (width > 80 && !isHeading && !isTable && !hasLink)
          emit(i, "§5", "line is " width " characters (limit 80; links, tables, headings and code blocks are exempt)")

        if (line ~ /^(=+|-+)$/ && length(line) >= 2 && i > 1 &&
            L[i-1] !~ /^[ \t]*$/ && L[i-1] !~ /^[ \t]*([*+>-]|[0-9]+[.)])[ \t]/) {
          emit(i, "§8.1", "setext heading — use ATX (\"" (line ~ /^=/ ? "# " : "## ") L[i-1] "\")")
          trackHeading(i - 1, (line ~ /^=/ ? 1 : 2), L[i-1])
          continue
        }

        if (line ~ /^#{1,6}[^ #]/) emit(i, "§8.3", "no space after # in heading")

        if (isHeading) {
          match(line, /^#+/); level = RLENGTH
          text = substr(line, level + 1); gsub(/^[ \t]+|[ \t]+$/, "", text)
          if (i > 1 && L[i-1] !~ /^[ \t]*$/) emit(i, "§8.3", "no blank line before heading")
          if (i < n && L[i+1] !~ /^[ \t]*$/) emit(i, "§8.3", "no blank line after heading")
          trackHeading(i, level, text)
          continue
        }

        if (line ~ /^[ \t]*\[TOC\][ \t]*$/) {
          if (h1Line > 0 && !introSeen) emit(i, "§4.2", "[TOC] before the introduction — it belongs after the intro, before the first H2")
          if (firstH2 > 0 && i > firstH2) emit(i, "§4.2", "[TOC] after the first H2 — screen readers reach it at that point in the document")
          continue
        }

        if (line !~ /^[ \t]*$/ && h1Line > 0 && i > h1Line) introSeen = 1
        if (line ~ /^[ \t]*([*+-]|[0-9]+[.)])[ \t]/) listSince = 1

        txt = bare(line)
        if (txt ~ /\]\([ ]*\.\.\//) emit(i, "§11.3", "link climbs out with ../ — use an explicit path from the corpus root")
        if (txt ~ /\]\(https?:\/\/[^)]*\.md[)#]/) emit(i, "§11.2", "fully qualified URL to a Markdown page — link by explicit path instead")
        if (tolower(txt) ~ /\[(here|link|this|click here|read more|more|link here)\]\(/) emit(i, "§11.4", "uninformative link title — wrap the phrase that names the destination")
        if (txt ~ /\[https?:\/\/[^]]*\]\(/) emit(i, "§11.4", "link title duplicates the URL — title it with what it is")

        if (tolower(txt) ~ /<\/?(br|div|table|tr|td|th|img|details|summary|span|center|font|sup|sub|h[1-6])( [^>]*)?\/?>/)
          emit(i, "§14", "raw HTML — prefer Markdown; Gitiles does not render HTML at all")

        if (!listSince && line ~ /^    [^ ]/ && i > 1 && L[i-1] ~ /^[ \t]*$/)
          emit(i, "§10.3", "indented code block — use a fenced block so it can declare a language")
      }
      if (fence) emit(fenceOpen, "§10.3", "code fence opened here is never closed")
    }
  ' "$f" 2>&1)"
  rc=$?
  if [ $rc -ne 0 ]; then
    add_skip "$f: awk failed — NOT checked"
    [ -n "$out" ] && skipped="${skipped}$(indent "$out")"$'\n'
    continue
  fi
  [ -n "$out" ] && builtin_out="${builtin_out}${out}"$'\n'
done

add_ran "source checks over ${#files[@]} file(s): line limit, whitespace, headings, [TOC], code fences, links, HTML"
[ -n "$builtin_out" ] && add_finding "markdown source checks (§ refers to references/)" "${builtin_out%$'\n'}"

# --- project tooling ---------------------------------------------------------
# Linters run only against a config the project has adopted. Running them with
# stock defaults would report rules nobody agreed to, and those are not findings.
root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
config_for() {  # <glob...> -> prints the first match found
  for pat in "$@"; do
    for dir in "." "$root"; do
      for c in "$dir"/$pat; do [ -e "$c" ] && { echo "$c"; return 0; }; done
    done
  done
  return 1
}

if mdl_cfg="$(config_for '.markdownlint.json' '.markdownlint.jsonc' '.markdownlint.yaml' '.markdownlint.yml' '.markdownlint-cli2.jsonc' '.markdownlint-cli2.yaml')"; then
  if have markdownlint-cli2 || have markdownlint; then
    tool=$(have markdownlint-cli2 && echo markdownlint-cli2 || echo markdownlint)
    if out="$("$tool" "${files[@]}" 2>&1)"; then
      add_ran "$tool (config: $mdl_cfg)"
    elif [ -z "$out" ] || is_env_error "$out"; then
      add_skip "$tool: could not run here — NOT verified"
      [ -n "$out" ] && skipped="${skipped}$(indent "$out")"$'\n'
    else
      add_finding "$tool (config: $mdl_cfg)" "$out"; add_ran "$tool"
    fi
  else
    add_skip "markdownlint: config $mdl_cfg exists but the tool is not installed — project rules NOT checked"
  fi
else
  add_skip "markdownlint: no project config — not run (stock defaults would report rules this repo has not adopted)"
fi

if prettier_cfg="$(config_for '.prettierrc' '.prettierrc.json' '.prettierrc.yaml' '.prettierrc.yml' '.prettierrc.js' 'prettier.config.js' 'prettier.config.mjs')"; then
  if have prettier; then
    if out="$(prettier --check "${files[@]}" 2>&1)"; then
      add_ran "prettier --check (config: $prettier_cfg)"
    elif [ -z "$out" ] || is_env_error "$out"; then
      add_skip "prettier: could not run here — NOT verified"
      [ -n "$out" ] && skipped="${skipped}$(indent "$out")"$'\n'
    else
      add_finding "prettier --check — formatting differs from the project config (fix: prettier --write)" "$out"
      add_ran "prettier --check"
    fi
  else
    add_skip "prettier: config $prettier_cfg exists but the tool is not installed — formatting NOT checked"
  fi
else
  add_skip "prettier: no project config — not run (it would impose a layout the repo has not chosen)"
fi

# --- report ------------------------------------------------------------------
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
