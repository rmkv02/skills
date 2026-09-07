#!/usr/bin/env python3
"""Сводка скиллов профиля для агентов без поддержки skills.

Результат — dist/AGENTS.bundle.md: тела SKILL.md выбранного профиля, склеенные
в один файл. Не заменяет корневой AGENTS.md: тот адресован агентам, которые
работают НАД этим репозиторием.

Usage:
  python3 scripts/gen_bundle.py --profile backend-go
  python3 scripts/gen_bundle.py --profile backend-go --with-references
  python3 scripts/gen_bundle.py --profile backend-go -o -      # в stdout

Без --with-references тела references/ не вкладываются: у бандла нет
прогрессивной загрузки, и вложение превращает экономию контекста в его расход.
Вместо содержимого печатается список файлов, чтобы агент мог попросить нужный.

Exit: 0 — записано, 1 — профиль не найден или скилл отсутствует.
"""

from __future__ import annotations

import argparse
import datetime
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def strip_frontmatter(text: str) -> tuple[dict, str]:
    import yaml

    if not text.startswith("---\n"):
        return {}, text
    end = text.find("\n---", 4)
    if end == -1:
        return {}, text
    fm = yaml.safe_load(text[4:end]) or {}
    return fm, text[end + 4 :].lstrip("\n")


def main() -> int:
    import yaml

    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", required=True)
    ap.add_argument("--with-references", action="store_true")
    ap.add_argument("-o", "--out", default="dist/AGENTS.bundle.md")
    args = ap.parse_args()

    reg = yaml.safe_load((ROOT / "registry.yaml").read_text(encoding="utf-8"))
    profiles = reg.get("profiles") or {}
    if args.profile not in profiles:
        print(f"профиль '{args.profile}' не найден. есть: {', '.join(profiles)}", file=sys.stderr)
        return 1

    names = profiles[args.profile] or []
    if not names:
        print(f"профиль '{args.profile}' пуст — бандл был бы пустым", file=sys.stderr)
        return 1

    entries = {s["name"]: s for s in (reg.get("skills") or [])}
    parts = [
        f"# Agent skills — профиль `{args.profile}`",
        "",
        f"Сгенерировано `scripts/gen_bundle.py` из `registry.yaml` "
        f"{datetime.date.today().isoformat()}. Не редактировать: правки вносятся "
        f"в `skills/<layer>/<name>/SKILL.md`.",
        "",
        "Файл для агентов, которые не умеют загружать скиллы по описанию. "
        "Здесь все инструкции профиля загружены сразу, поэтому применять их "
        "нужно по секции «когда применять» каждого скилла, а не подряд.",
        "",
    ]

    for name in names:
        e = entries.get(name)
        if not e:
            print(f"скилл '{name}' из профиля отсутствует в реестре", file=sys.stderr)
            return 1
        md = ROOT / e["path"] / "SKILL.md"
        if not md.exists():
            print(f"нет файла {md.relative_to(ROOT)}", file=sys.stderr)
            return 1
        fm, body = strip_frontmatter(md.read_text(encoding="utf-8"))
        parts += [
            "---",
            "",
            f"## Скилл: `{name}` ({e.get('layer')}, v{e.get('version')})",
            "",
            "**Когда применять.** " + " ".join((fm.get("description") or "").split()),
            "",
            body.rstrip(),
            "",
        ]
        refs = sorted((ROOT / e["path"] / "references").glob("*.md"))
        if refs and args.with_references:
            for r in refs:
                parts += [f"### `{name}` / references/{r.name}", "", r.read_text(encoding="utf-8").rstrip(), ""]
        elif refs:
            listed = ", ".join(f"`{e['path']}/references/{r.name}`" for r in refs)
            parts += [f"Подробные правила не вложены — по запросу читать: {listed}.", ""]

    out = "\n".join(parts).rstrip() + "\n"
    if args.out == "-":
        sys.stdout.write(out)
        return 0
    dst = ROOT / args.out
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(out, encoding="utf-8")
    print(f"{args.out}: {len(names)} скилл(ов), {len(out.splitlines())} строк")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
