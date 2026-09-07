#!/usr/bin/env python3
"""Валидация репозитория скиллов.

Ловит ровно те ошибки, из-за которых скилл молча не установится или не
сработает: несовпадение name и имени каталога, невалидный name, отсутствие
description, ссылки на несуществующие файлы, битые evals, дубли триггеров
между скиллами.

Usage: python3 scripts/validate_skills.py [--strict]
Exit:  0 — чисто, 1 — ошибки
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "skills"

NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
DESC_MIN, DESC_SOFT_MAX = 40, 900  # символов; верхняя граница — мягкая
LINK_RE = re.compile(r"`(references/[^`]+|scripts/[^`]+|assets/[^`]+)`")

errors: list[str] = []
warnings: list[str] = []


def parse_frontmatter(text: str) -> dict[str, str] | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 4)
    if end == -1:
        return None
    fm, out, key = text[4:end], {}, None
    for line in fm.split("\n"):
        if not line.strip():
            continue
        if re.match(r"^[a-zA-Z_-]+:", line):
            key, _, val = line.partition(":")
            key = key.strip()
            out[key] = val.strip()
        elif key:  # продолжение многострочного значения
            out[key] += " " + line.strip()
    return out


def check_skill(d: Path) -> None:
    rel = d.relative_to(ROOT)
    md = d / "SKILL.md"
    if not md.exists():
        errors.append(f"{rel}: нет SKILL.md")
        return

    text = md.read_text(encoding="utf-8")
    fm = parse_frontmatter(text)
    if fm is None:
        errors.append(f"{rel}/SKILL.md: нет YAML frontmatter")
        return

    name = fm.get("name", "")
    if not name:
        errors.append(f"{rel}/SKILL.md: отсутствует обязательное поле name")
    else:
        if not NAME_RE.match(name):
            errors.append(f"{rel}: невалидный name {name!r} (нужно ^[a-z0-9]+(-[a-z0-9]+)*$)")
        if name != d.name:
            errors.append(f"{rel}: name={name!r} не совпадает с именем каталога {d.name!r}")

    desc = fm.get("description", "")
    if not desc:
        errors.append(f"{rel}/SKILL.md: отсутствует обязательное поле description")
    else:
        if len(desc) < DESC_MIN:
            errors.append(f"{rel}: description слишком короткое ({len(desc)} симв.) — по нему решается срабатывание")
        if len(desc) > DESC_SOFT_MAX:
            warnings.append(
                f"{rel}: description {len(desc)} симв. — часть агентов сокращает описания, "
                "вынесите ключевые триггеры и границы в начало"
            )

    body_lines = text.split("\n")
    if len(body_lines) > 500:
        warnings.append(f"{rel}/SKILL.md: {len(body_lines)} строк — выносите детали в references/")

    for m in LINK_RE.finditer(text):
        path = m.group(1).split("#")[0].split()[0].strip()
        target = d / path
        if not target.exists():
            errors.append(f"{rel}/SKILL.md: ссылка на несуществующий файл {path}")

    for script in (d / "scripts").glob("*.sh"):
        if not script.stat().st_mode & 0o111:
            errors.append(f"{rel}/scripts/{script.name}: не исполняемый (chmod +x)")

    evals_dir = d / "evals"
    if not evals_dir.exists():
        warnings.append(f"{rel}: нет evals/ — качество скилла ничем не подтверждено")
        return

    ev = evals_dir / "evals.json"
    if ev.exists():
        try:
            data = json.loads(ev.read_text(encoding="utf-8"))
            if data.get("skill_name") != name:
                errors.append(f"{rel}/evals/evals.json: skill_name не совпадает с name скилла")
            for case in data.get("evals", []):
                for f in case.get("files", []):
                    if not (ROOT / "skills" / d.name / f).exists() and not (d / f).exists():
                        errors.append(f"{rel}/evals: файл фикстуры не найден: {f}")
                if not case.get("expectations"):
                    warnings.append(f"{rel}/evals: кейс {case.get('id')} без expectations")
        except json.JSONDecodeError as e:
            errors.append(f"{rel}/evals/evals.json: невалидный JSON — {e}")

    tv = evals_dir / "trigger-evals.json"
    if tv.exists():
        try:
            items = json.loads(tv.read_text(encoding="utf-8"))
            pos = sum(1 for i in items if i.get("should_trigger"))
            neg = len(items) - pos
            if pos < 5 or neg < 5:
                warnings.append(f"{rel}/evals: перекос trigger-евалов ({pos} позитивных / {neg} негативных)")
        except json.JSONDecodeError as e:
            errors.append(f"{rel}/evals/trigger-evals.json: невалидный JSON — {e}")


def load_registry():
    reg = ROOT / "registry.yaml"
    if not reg.exists():
        errors.append("нет registry.yaml — состав репозитория не определён [E-NOT-REGISTERED]")
        return None
    try:
        import yaml  # type: ignore
    except ImportError:
        warnings.append("pyyaml не установлен — проверки реестра пропущены (pip install pyyaml)")
        return None
    try:
        return yaml.safe_load(reg.read_text(encoding="utf-8"))
    except Exception as e:  # noqa: BLE001
        errors.append(f"registry.yaml: не парсится — {e}")
        return None


def check_registry(reg, found: dict[str, Path]) -> None:
    """Реестр, слои, профили и парность границ."""
    entries = {s["name"]: s for s in (reg.get("skills") or []) if "name" in s}

    for name, path in found.items():
        e = entries.get(name)
        if e is None:
            errors.append(f"{name}: не зарегистрирован в registry.yaml [E-NOT-REGISTERED]")
            continue
        layer_on_disk = path.parent.name
        if e.get("layer") != layer_on_disk:
            errors.append(
                f"{name}: layer={e.get('layer')!r} в реестре, но каталог лежит в {layer_on_disk!r} [E-LAYER-MISMATCH]"
            )
        if e.get("path") and (ROOT / e["path"]) != path:
            errors.append(f"{name}: path в реестре не указывает на {path.relative_to(ROOT)}")
        for field in ("version", "owner", "status", "triggers", "boundaries"):
            if not e.get(field):
                errors.append(f"{name}: в реестре не заполнено обязательное поле {field}")
        if not e.get("boundaries"):
            continue

    for name in entries:
        if name not in found:
            errors.append(f"registry.yaml: скилл {name} зарегистрирован, но каталога нет")

    # Делегирование двусторонне: у адресата обязана быть встречная граница.
    for name, e in entries.items():
        for target in e.get("delegates_to") or []:
            if target not in entries:
                warnings.append(f"{name}: delegates_to -> {target}, которого ещё нет в реестре")
                continue
            back = " ".join(entries[target].get("boundaries") or [])
            if name not in back:
                errors.append(
                    f"{target}: нет встречной границы с {name} — делегирование должно быть парным [E-ASYMMETRIC-BOUNDARY]"
                )

    # Профили: каждый active-скилл минимум в одном, иначе его никто не ставит.
    profiles = reg.get("profiles") or {}
    in_profiles = {n for names in profiles.values() for n in (names or [])}
    for name, e in entries.items():
        status = e.get("status")
        if status == "active" and name not in in_profiles:
            errors.append(f"{name}: active, но не входит ни в один профиль — никем не устанавливается [E-ORPHAN-SKILL]")
        if status == "experimental":
            leaked = [p for p, ns in profiles.items() if name in (ns or []) and p != "authors"]
            if leaked:
                errors.append(f"{name}: experimental в профилях {leaked} — допустим только в authors")
    for prof, names in profiles.items():
        for n in names or []:
            if n not in entries:
                errors.append(f"профиль {prof}: неизвестный скилл {n}")
        if names and len(names) > 8:
            warnings.append(f"профиль {prof}: {len(names)} скиллов — роль определена слишком широко")


def check_routing_matrix(reg, found: dict[str, Path]) -> None:
    """Общая матрица роутинга репозитория: пофайловых trigger-евалов мало,
    негативы одного скилла — позитивы другого."""
    mx = ROOT / "evals" / "routing-matrix.json"
    if not mx.exists():
        errors.append("нет evals/routing-matrix.json — роутинг между скиллами ничем не проверяется [E-MATRIX-COVERAGE]")
        return
    try:
        data = json.loads(mx.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        errors.append(f"evals/routing-matrix.json: невалидный JSON — {e}")
        return

    cases = data.get("cases") or []
    if not cases:
        errors.append("evals/routing-matrix.json: пустая матрица")
        return

    entries = {s["name"]: s for s in (reg.get("skills") or [])} if reg else {}
    for name in found:
        if entries.get(name, {}).get("status") not in (None, "active"):
            continue
        positive = sum(1 for c in cases if name in (c.get("expect") or []))
        negative = sum(1 for c in cases if name not in (c.get("expect") or []))
        if positive == 0:
            errors.append(f"{name}: нет строк матрицы, где скилл ожидается [E-MATRIX-COVERAGE]")
        if negative == 0:
            errors.append(f"{name}: нет строк матрицы, где скилл не должен срабатывать [E-MATRIX-COVERAGE]")
    if data.get("runs_per_query", 1) < 3:
        warnings.append("routing-matrix: runs_per_query < 3 — триггеринг стохастичен, единичный прогон не измерение")


def check_no_committed_mirrors() -> None:
    """Зеркала агентов не коммитятся: это дубль контента и гарантированный дрейф."""
    for mirror in (".claude/skills", ".agents/skills", ".opencode/skills", ".cursor/skills"):
        d = ROOT / mirror
        if d.exists() and not (ROOT / ".gitignore").read_text(encoding="utf-8").count(mirror.split("/")[0]):
            errors.append(f"{mirror}: зеркало агента не в .gitignore — будет закоммичен дубль [E-COMMITTED-MIRROR]")


def main() -> int:
    if not SKILLS.exists():
        print("нет каталога skills/", file=sys.stderr)
        return 1

    found: dict[str, Path] = {}
    for layer in sorted(p for p in SKILLS.iterdir() if p.is_dir()):
        for d in sorted(p for p in layer.iterdir() if p.is_dir()):
            if (d / "SKILL.md").exists() or True:
                if d.name in found:
                    errors.append(
                        f"{d.name}: имя не уникально ({found[d.name].relative_to(ROOT)} и {d.relative_to(ROOT)}) "
                        "— агент видит плоское пространство имён [E-NAME-DUP]"
                    )
                found[d.name] = d
                check_skill(d)

    if not found:
        print("skills/ пуст (ожидается skills/<layer>/<name>/)", file=sys.stderr)
        return 1

    reg = load_registry()
    if reg:
        check_registry(reg, found)
    check_routing_matrix(reg, found)
    if (ROOT / ".gitignore").exists():
        check_no_committed_mirrors()

    for w in warnings:
        print(f"warning: {w}")
    for e in errors:
        print(f"error:   {e}")

    strict = "--strict" in sys.argv
    print(f"\nпроверено скиллов: {len(found)}; ошибок: {len(errors)}, предупреждений: {len(warnings)}")
    return 1 if errors or (strict and warnings) else 0


if __name__ == "__main__":
    raise SystemExit(main())
