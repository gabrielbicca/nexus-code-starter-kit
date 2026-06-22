#!/usr/bin/env python3
"""
Spec-Drift Validator — coerência do fluxo spec-driven
=====================================================

Valida, no projeto-alvo, que:
  1. Toda migration .sql tem um doc Migration-*.md em docs/02_Specs/Migrations/
  2. SPEC-NNN / ADR-NNN referenciados no código existem como arquivo em docs/
  3. O índice docs/README.md lista as SPECs e ADRs existentes

Tolerante a stacks variados: se docs/ ou migrations não existem, não falha.
Falha (exit 1) apenas em drift real: migration sem doc ou referência quebrada.
Avisos (numeração, índice) não derrubam o exit code.

Uso:
    python .claude/scripts/spec_drift.py .
"""
import sys
import re
from pathlib import Path

# Saída robusta em Windows: evita UnicodeEncodeError quando o stdout não é UTF-8
# (console cp1252 ou pipe). Mantém os símbolos sem derrubar a execução.
try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
except (AttributeError, ValueError):
    pass

GREEN = "\033[92m"; YELLOW = "\033[93m"; RED = "\033[91m"
CYAN = "\033[96m"; BOLD = "\033[1m"; END = "\033[0m"

MIGRATION_DIRS = ["supabase/migrations", "db/migrations", "migrations", "prisma/migrations"]
SPEC_DIR = "docs/02_Specs"
ADR_DIR = "docs/01_Architecture"
MIG_DOC_DIR = "docs/02_Specs/Migrations"
INDEX = "docs/README.md"

SKIP_DIRS = {".git", "node_modules", "dist", "build", ".next", "out", "vendor",
             "__pycache__", "coverage", ".turbo", ".venv", "venv"}
TEXT_EXT = {".md", ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs", ".py",
            ".sql", ".json", ".yml", ".yaml", ".sh", ".txt", ".vue", ".svelte"}

warnings = []
errors = []


def info(msg): print(f"  {CYAN}→{END} {msg}")
def ok(msg): print(f"  {GREEN}✓{END} {msg}")
def warn(msg): warnings.append(msg); print(f"  {YELLOW}!{END} {msg}")
def err(msg): errors.append(msg); print(f"  {RED}✗{END} {msg}")


def first_num(name):
    m = re.search(r"(\d{2,})", name)
    return m.group(1) if m else None


def norm(n):
    return (n.lstrip("0") or "0") if n else None


def check_migrations(root):
    sqls = []
    for d in MIGRATION_DIRS:
        p = root / d
        if p.is_dir():
            sqls += [f for f in p.glob("*.sql") if f.is_file()]
    if not sqls:
        info("Nenhuma migration .sql encontrada — checagem migration↔doc pulada.")
        return
    doc_dir = root / MIG_DOC_DIR
    doc_nums = set()
    if doc_dir.is_dir():
        for d in doc_dir.glob("*.md"):
            n = norm(first_num(d.name))
            if n:
                doc_nums.add(n)
    missing = [s.name for s in sqls if norm(first_num(s.name)) not in doc_nums]
    if missing:
        shown = ", ".join(missing[:8]) + (" ..." if len(missing) > 8 else "")
        err(f"{len(missing)} migration(s) sem doc em {MIG_DOC_DIR}: {shown}")
    else:
        ok(f"Todas as {len(sqls)} migration(s) têm doc correspondente.")


def existing_ids(root, subdir, prefix):
    p = root / subdir
    ids = set()
    if p.is_dir():
        for f in p.glob("*.md"):
            m = re.match(prefix + r"-(\d+)", f.name)
            if m:
                ids.add(norm(m.group(1)))
    return ids


def scan_references(root):
    refs = {"SPEC": set(), "ADR": set()}
    pat = re.compile(r"\b(SPEC|ADR)-(\d{1,4})\b")
    for f in root.rglob("*"):
        if not f.is_file() or f.suffix.lower() not in TEXT_EXT:
            continue
        if any(part in SKIP_DIRS for part in f.parts):
            continue
        try:
            if f.stat().st_size > 512_000:
                continue
            text = f.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for m in pat.finditer(text):
            refs[m.group(1)].add(norm(m.group(2)))
    return refs


def check_references(root):
    specs = existing_ids(root, SPEC_DIR, "SPEC")
    adrs = existing_ids(root, ADR_DIR, "ADR")
    if not specs and not adrs:
        info("Nenhuma SPEC/ADR ainda — checagem de referências pulada.")
        return specs, adrs
    refs = scan_references(root)
    broken_spec = sorted(refs["SPEC"] - specs, key=int)
    broken_adr = sorted(refs["ADR"] - adrs, key=int)
    if broken_spec:
        err("Referências a SPEC inexistentes: " + ", ".join("SPEC-" + x.zfill(3) for x in broken_spec))
    if broken_adr:
        err("Referências a ADR inexistentes: " + ", ".join("ADR-" + x.zfill(3) for x in broken_adr))
    if not broken_spec and not broken_adr:
        ok(f"Referências coerentes ({len(specs)} SPEC, {len(adrs)} ADR existentes).")
    return specs, adrs


def check_index(root, specs, adrs):
    idx = root / INDEX
    if not idx.is_file():
        if specs or adrs:
            warn(f"Índice {INDEX} não encontrado.")
        return
    text = idx.read_text(encoding="utf-8", errors="ignore")
    listed_s = {norm(m.group(1)) for m in re.finditer(r"SPEC-(\d+)", text)}
    listed_a = {norm(m.group(1)) for m in re.finditer(r"ADR-(\d+)", text)}
    miss_s = sorted(specs - listed_s, key=int)
    miss_a = sorted(adrs - listed_a, key=int)
    if miss_s:
        warn("Índice não lista: " + ", ".join("SPEC-" + x.zfill(3) for x in miss_s))
    if miss_a:
        warn("Índice não lista: " + ", ".join("ADR-" + x.zfill(3) for x in miss_a))
    if not miss_s and not miss_a and (specs or adrs):
        ok("Índice docs/README.md em dia com as SPECs/ADRs.")


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    print(f"\n{BOLD}{CYAN}Spec-Drift — {root}{END}")
    if not (root / "docs").is_dir():
        info("Sem pasta docs/ — projeto não usa o padrão spec-driven. Nada a validar.")
        sys.exit(0)
    check_migrations(root)
    specs, adrs = check_references(root)
    check_index(root, specs, adrs)
    print()
    if errors:
        print(f"{RED}✗ Spec-drift: {len(errors)} problema(s), {len(warnings)} aviso(s).{END}")
        sys.exit(1)
    if warnings:
        print(f"{YELLOW}! Spec-drift: sem erros, {len(warnings)} aviso(s).{END}")
    else:
        print(f"{GREEN}✓ Spec-driven coerente.{END}")
    sys.exit(0)


if __name__ == "__main__":
    main()
