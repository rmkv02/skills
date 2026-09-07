#!/usr/bin/env bash
# Установка скиллов репозитория в любого кодового агента.
#
# Модель: canonical source один (skills/<layer>/<name>), каталоги агентов —
# симлинки на него. Обновил репозиторий — обновилось везде, без копий,
# расходящихся между собой.
#
#   ./scripts/install.sh --list
#   ./scripts/install.sh --profile backend-go
#   ./scripts/install.sh --profile everyone --global
#   ./scripts/install.sh --skill go-style --agent claude-code --agent codex
#   ./scripts/install.sh --profile backend-go --dry-run
#   ./scripts/install.sh --profile backend-go --copy     # Windows, CI, песочницы
#   ./scripts/install.sh --profile backend-go --uninstall
#
# Установка "всего" по умолчанию не поддерживается: ставьте профилями.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/skills"
REGISTRY="$REPO/registry.yaml"

MODE=project
LINK=symlink
UNINSTALL=0
DRYRUN=0
LIST=0
AGENTS=()
SKILLS=()
PROFILES=()

# Шапка файла и есть справка. Границей служит первая не-комментарная строка,
# а не фиксированный номер: жёсткий диапазон при правке шапки начинал печатать код.
usage() { awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; }

while [ $# -gt 0 ]; do
  case "$1" in
    -p|--profile)  PROFILES+=("$2"); shift 2 ;;
    -s|--skill)    SKILLS+=("$2");   shift 2 ;;
    -a|--agent)    AGENTS+=("$2");   shift 2 ;;
    -g|--global)   MODE=global;      shift ;;
    --copy)        LINK=copy;        shift ;;
    --dry-run)     DRYRUN=1;         shift ;;
    --list)        LIST=1;           shift ;;
    --uninstall)   UNINSTALL=1;      shift ;;
    -h|--help)     usage; exit 0 ;;
    *) echo "неизвестный аргумент: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# --- обнаружение скиллов -----------------------------------------------------
# Слой в пути не участвует: агент видит плоское пространство имён и ждёт скилл
# в каталоге под своим name — .claude/skills/go-style, а не .../lang/go-style.
skill_path() {  # name -> путь или пусто
  find "$SRC" -mindepth 2 -maxdepth 2 -type d -name "$1" -print -quit 2>/dev/null
}

all_skills() {
  find "$SRC" -mindepth 2 -maxdepth 2 -type d -exec test -f '{}/SKILL.md' \; -print \
    | sed 's|.*/||' | sort
}

# Профили читаются из flow-списков registry.yaml: profiles: \n  name: [a, b]
profile_skills() {
  awk -v want="$1" '
    /^profiles:/ { inp=1; next }
    inp && /^[^[:space:]]/ { inp=0 }
    inp && $0 ~ "^[[:space:]]+" want ":" {
      sub(/^[^:]*:[[:space:]]*/, ""); gsub(/[][,]/, " "); print; exit
    }
  ' "$REGISTRY"
}

list_profiles() { awk '/^profiles:/{p=1;next} p&&/^[^[:space:]]/{p=0} p&&/:/{sub(/:.*/,"");gsub(/[[:space:]]/,"");if($0)print}' "$REGISTRY"; }

if [ "$LIST" = 1 ]; then
  echo "скиллы:"
  while IFS= read -r s; do
    p="$(skill_path "$s")"; layer="$(basename "$(dirname "$p")")"
    printf '  %-20s %s\n' "$s" "$layer"
  done < <(all_skills)
  echo
  echo "профили:"
  while IFS= read -r pr; do
    printf '  %-20s %s\n' "$pr" "$(profile_skills "$pr" | xargs)"
  done < <(list_profiles)
  exit 0
fi

for pr in "${PROFILES[@]:-}"; do
  [ -n "$pr" ] || continue
  resolved="$(profile_skills "$pr")"
  if [ -z "$(echo "$resolved" | xargs)" ]; then
    echo "профиль '$pr' не найден или пуст (см. registry.yaml)" >&2; exit 2
  fi
  for s in $resolved; do SKILLS+=("$s"); done
done

if [ ${#SKILLS[@]} -eq 0 ]; then
  echo "нечего устанавливать: укажите --profile или --skill." >&2
  echo "доступное показывает: $0 --list" >&2
  exit 2
fi

# дедупликация с сохранением порядка. Без mapfile: он появился в bash 4, а в
# macOS штатный /bin/bash — 3.2, и скрипт обязан работать на машине разработчика,
# а не только в ubuntu-раннере CI.
UNIQ=()
for s in "${SKILLS[@]}"; do
  dup=0
  for u in ${UNIQ[@]+"${UNIQ[@]}"}; do
    if [ "$u" = "$s" ]; then dup=1; break; fi
  done
  if [ "$dup" = 0 ]; then UNIQ+=("$s"); fi
done
SKILLS=("${UNIQ[@]}")

if [ ${#AGENTS[@]} -eq 0 ]; then
  AGENTS=(claude-code codex cursor opencode)
fi

# --- целевые каталоги --------------------------------------------------------
# Самая хрупкая часть: при обновлении агента сверяйте пути с его документацией.
target_dir() {
  local agent="$1"
  if [ "$MODE" = global ]; then
    case "$agent" in
      claude-code) echo "$HOME/.claude/skills" ;;
      codex)       echo "$HOME/.agents/skills" ;;
      cursor)      echo "$HOME/.cursor/skills" ;;
      opencode)    echo "$HOME/.config/opencode/skills" ;;
      generic)     echo "$HOME/.agents/skills" ;;
    esac
  else
    case "$agent" in
      claude-code) echo "$PWD/.claude/skills" ;;
      codex)       echo "$PWD/.agents/skills" ;;
      cursor)      echo "$PWD/.cursor/skills" ;;
      opencode)    echo "$PWD/.opencode/skills" ;;
      generic)     echo "$PWD/.agents/skills" ;;
    esac
  fi
}

echo "репозиторий: $REPO"
echo "режим:       $MODE / $LINK$([ "$DRYRUN" = 1 ] && echo ' / dry-run')"
[ ${#PROFILES[@]} -gt 0 ] && echo "профили:     ${PROFILES[*]}"
echo "скиллы:      ${SKILLS[*]}"
echo "агенты:      ${AGENTS[*]}"
echo

for agent in "${AGENTS[@]}"; do
  dir="$(target_dir "$agent")"
  [ -n "$dir" ] || { echo "  ! неизвестный агент: $agent" >&2; continue; }
  [ "$DRYRUN" = 1 ] || mkdir -p "$dir"
  for skill in "${SKILLS[@]}"; do
    src="$(skill_path "$skill")"
    dst="$dir/$skill"
    [ -n "$src" ] || { echo "  ! нет скилла: $skill" >&2; continue; }

    if [ "$UNINSTALL" = 1 ]; then
      [ "$DRYRUN" = 1 ] || rm -rf "$dst"
      echo "  - $agent: удалён $skill"
      continue
    fi

    if [ "$DRYRUN" = 1 ]; then
      echo "  ~ $agent: $skill -> $dst ($LINK)"
      continue
    fi

    rm -rf "$dst"
    if [ "$LINK" = symlink ]; then ln -s "$src" "$dst"; else cp -R "$src" "$dst"; fi
    echo "  + $agent: $skill -> $dst"
  done
done

[ "$DRYRUN" = 1 ] && { echo; echo "dry-run: изменений не внесено."; exit 0; }
[ "$UNINSTALL" = 1 ] && { echo; echo "готово. перезапустите агента."; exit 0; }

cat <<'NOTE'

готово. перезапустите агента, чтобы он перечитал каталог скиллов.

Проверка:
  Claude Code  — скилл виден в списке доступных, вызов по описанию задачи
  Codex        — /skills или $go-style
  Cursor       — слэш-меню в чате агента
  opencode     — скилл появляется как инструмент skill

Если агент не видит скилл: имя каталога обязано совпадать с полем name
во frontmatter, иначе он будет отброшен при загрузке. Прогоните
python3 scripts/validate_skills.py --strict — эта проверка там первая.
NOTE
