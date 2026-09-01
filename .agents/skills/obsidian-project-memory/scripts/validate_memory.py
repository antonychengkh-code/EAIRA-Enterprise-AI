from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


REQUIRED_PATHS = (
    "AGENTS.md",
    "docs/project/status/README.md",
    "docs/project/status/CURRENT_STATUS.md",
    "docs/project/status/TODAY_OBJECTIVE.md",
    "docs/project/status/ACTIVE_TASK.yaml",
    "docs/project/status/AGENT_CONTEXT_VERSION.yaml",
    "docs/specifications/EAIRA_CONTEXT_CONTRACT_V1.md",
    "docs/project/memory/README.md",
    "docs/project/memory/MEMORY_SCHEMA.md",
    "docs/project/memory/MEMORY_INBOX.md",
    "docs/project/memory/HANDOFF.md",
    "docs/project/memory/OPEN_QUESTIONS.md",
    "docs/project/memory/DECISION_INDEX.md",
    "docs/project/memory/DISCOVERY_INDEX.md",
    "docs/project/memory/PROCEDURE_INDEX.md",
    "docs/project/memory/STABILITY_CHECKLIST.md",
)

MEMORY_FILES = tuple(path for path in REQUIRED_PATHS if path.startswith("docs/project/memory/"))
FRONTMATTER_KEYS = ("type", "status", "created", "updated", "source", "project", "authority")
CANONICAL_REFERENCES = (
    "docs/project/status/CURRENT_STATUS",
    "docs/project/status/TODAY_OBJECTIVE",
    "docs/project/status/ACTIVE_TASK",
    "docs/project/status/AGENT_CONTEXT_VERSION",
    "docs/project/context/CURRENT_CONTEXT",
    "docs/specifications/EAIRA_CONTEXT_CONTRACT_V1",
)
WIKILINK_PATTERN = re.compile(r"\[\[([^\]]+)\]\]")


def find_repo_root(start: Path) -> Path:
    current = start.resolve()
    if current.is_file():
        current = current.parent
    for candidate in (current, *current.parents):
        if (candidate / "AGENTS.md").is_file() and (candidate / "docs/project/status").is_dir():
            return candidate
    raise FileNotFoundError("Could not locate an EAIRA repository root from the supplied path.")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def frontmatter(text: str) -> dict[str, str]:
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return {}
    result: dict[str, str] = {}
    for line in lines[1:]:
        if line.strip() == "---":
            return result
        if ":" in line:
            key, value = line.split(":", 1)
            result[key.strip()] = value.strip()
    return {}


def validate(root: Path) -> list[str]:
    errors: list[str] = []

    for relative in REQUIRED_PATHS:
        if not (root / relative).is_file():
            errors.append(f"missing required file: {relative}")

    for relative in MEMORY_FILES:
        path = root / relative
        if not path.is_file():
            continue
        metadata = frontmatter(read_text(path))
        for key in FRONTMATTER_KEYS:
            if not metadata.get(key):
                errors.append(f"{relative}: missing frontmatter key '{key}'")

    agents_path = root / "AGENTS.md"
    if agents_path.is_file() and "docs/project/memory/README.md" not in read_text(agents_path):
        errors.append("AGENTS.md does not load docs/project/memory/README.md")

    home_path = root / "docs/project/memory/README.md"
    if home_path.is_file():
        home = read_text(home_path)
        for reference in CANONICAL_REFERENCES:
            if reference not in home:
                errors.append(f"memory README is missing canonical reference: {reference}")

    for relative in MEMORY_FILES:
        path = root / relative
        if not path.is_file():
            continue
        for raw_target in WIKILINK_PATTERN.findall(read_text(path)):
            target = raw_target.split("|", 1)[0].split("#", 1)[0].strip()
            if not target:
                continue
            target_path = root / target
            if not target_path.suffix:
                target_path = target_path.with_suffix(".md")
            if not target_path.is_file():
                errors.append(f"{relative}: broken wikilink target '{target}'")

    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate the EAIRA Obsidian project-memory layer.")
    parser.add_argument("root", nargs="?", default=".", help="Repository root or a path inside it.")
    args = parser.parse_args()

    try:
        root = find_repo_root(Path(args.root))
    except FileNotFoundError as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        return 2

    errors = validate(root)
    if errors:
        print(f"FAIL: {len(errors)} project-memory validation error(s)")
        for error in errors:
            print(f"- {error}")
        return 1

    print(f"OK: EAIRA project-memory structure is valid at {root}")
    print(f"OK: {len(REQUIRED_PATHS)} required files and {len(MEMORY_FILES)} memory frontmatters verified")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
