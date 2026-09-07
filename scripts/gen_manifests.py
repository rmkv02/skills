#!/usr/bin/env python3
"""Генерация манифестов плагинов из registry.yaml.

Манифесты — производный артефакт: единственный источник состава репозитория
это registry.yaml. Руками их не правят: CI падает на расхождении
(код E-MANIFEST-DRIFT).

Usage:
  python3 scripts/gen_manifests.py            # записать манифесты
  python3 scripts/gen_manifests.py --check    # только сверить, ничего не писать

Exit: 0 — совпадает/записано, 1 — дрейф или ошибка реестра.

Сейчас генерируется только .claude-plugin/. Форматы .codex-plugin/ и
.cursor-plugin/ не реализованы намеренно: писать манифест по
неподтверждённой схеме хуже, чем не писать его. Точка расширения — GENERATORS
внизу файла: добавляется функция, возвращающая {путь: объект}.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def load_registry() -> dict:
    import yaml  # pyyaml обязателен: тихо деградировать здесь нельзя

    return yaml.safe_load((ROOT / "registry.yaml").read_text(encoding="utf-8"))


def active_skills(reg: dict) -> list[dict]:
    """Только устанавливаемые скиллы: experimental в манифест не попадает."""
    return [s for s in (reg.get("skills") or []) if s.get("status") == "active"]


def claude_plugin(reg: dict) -> dict[str, dict]:
    meta = reg.get("meta") or {}
    skills = active_skills(reg)
    name = meta.get("name", "agent-skills")

    plugin = {
        "$comment": "Сгенерировано scripts/gen_manifests.py из registry.yaml. Не редактировать.",
        "name": name,
        "version": str(meta.get("version", "0.0.0")),
        "description": (
            "Agent skills: "
            + ", ".join(s["name"] for s in skills)
            + ". Ставится профилями через scripts/install.sh."
        ),
        "author": {"name": meta.get("owner", "unknown")},
        "license": meta.get("license", "UNLICENSED"),
        "keywords": sorted({s["layer"] for s in skills} | {"agent-skills"}),
        "skills": [f"./{s['path']}" for s in skills],
    }

    marketplace = {
        "$comment": "Сгенерировано scripts/gen_manifests.py из registry.yaml. Не редактировать.",
        "name": name,
        "owner": {"name": meta.get("owner", "unknown")},
        "plugins": [
            {
                "name": name,
                "source": "./",
                "description": plugin["description"],
                "version": plugin["version"],
            }
        ],
    }
    return {
        ".claude-plugin/plugin.json": plugin,
        ".claude-plugin/marketplace.json": marketplace,
    }


GENERATORS = [claude_plugin]


def render(obj: dict) -> str:
    return json.dumps(obj, indent=2, ensure_ascii=False) + "\n"


def main() -> int:
    check = "--check" in sys.argv
    try:
        reg = load_registry()
    except ImportError:
        print("нужен pyyaml: pip install pyyaml", file=sys.stderr)
        return 1

    if not active_skills(reg):
        print("в registry.yaml нет ни одного active-скилла — манифест был бы пустым", file=sys.stderr)
        return 1

    drift, wrote = [], []
    for gen in GENERATORS:
        for rel, obj in gen(reg).items():
            path = ROOT / rel
            new = render(obj)
            old = path.read_text(encoding="utf-8") if path.exists() else None
            if old == new:
                continue
            if check:
                drift.append(rel if old is not None else f"{rel} (отсутствует)")
                continue
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(new, encoding="utf-8")
            wrote.append(rel)

    if check:
        if drift:
            print("манифесты разошлись с registry.yaml [E-MANIFEST-DRIFT]:", file=sys.stderr)
            for d in drift:
                print(f"  {d}", file=sys.stderr)
            print("\nпочинить: python3 scripts/gen_manifests.py", file=sys.stderr)
            return 1
        print("манифесты совпадают с registry.yaml")
        return 0

    print("обновлено: " + (", ".join(wrote) if wrote else "нечего (уже актуально)"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
