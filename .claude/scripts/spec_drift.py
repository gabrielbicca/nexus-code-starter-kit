#!/usr/bin/env python3
"""
Spec-Drift Validator — coerência do fluxo spec-driven
=====================================================

Valida, no projeto-alvo, que a documentação spec-driven está coerente:

  REFERENCIAL (links não quebrados)
  1. Toda migration .sql tem um doc Migration-*.md em docs/02_Specs/Migrations/
  2. SPEC-NNN / ADR-NNN referenciados no código existem como arquivo em docs/
  3. O índice docs/README.md lista as SPECs e ADRs existentes

  CONFORMIDADE (a spec reflete a realidade)
  4. Toda Migration-*.md referencia uma SPEC-NNN
  5. SPEC `concluída` tem TODOS os critérios de aceite marcados ([x])
  6. SPEC `em-progresso`/`concluída` tem "Arquivos de código" preenchido (elo SPEC↔código)

  GATE DE QUALIDADE (regra do kit: testes + segurança obrigatórios)
  7. SPEC `concluída` tem TODOS os itens do "Plano de testes" marcados
     (toda funcionalidade mapeada em teste na camada de testes)
  8. SPEC `concluída` tem o "Gate de qualidade" marcado
     (testes implementados + review do @security-auditor executado)

Tolerante a stacks variados: se docs/ ou migrations não existem, não falha.
Falha (exit 1) em drift REAL: migration sem doc, referência quebrada,
spec concluída com critério pendente, teste pendente ou gate de qualidade aberto.
Avisos (numeração, índice, rastreabilidade, migration sem SPEC) não derrubam o exit code.

Uso:
    python .claude/scripts/spec_drift.py .
"""
import sys
import re
import unicodedata
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

# Marcadores que indicam um campo ainda NÃO preenchido (placeholder do template).
PLACEHOLDER_MARKS = ("preencher", "<caminhos", "<caminho", "adicione aqui", "_(", "—", "n/a", "tbd")

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


def strip_accents(s):
    return "".join(c for c in unicodedata.normalize("NFD", s) if unicodedata.category(c) != "Mn")


# ---------------------------------------------------------------------------
# REFERENCIAL
# ---------------------------------------------------------------------------

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


# ---------------------------------------------------------------------------
# CONFORMIDADE
# ---------------------------------------------------------------------------

def check_migration_docs_reference_spec(root):
    """Toda Migration-*.md deve citar uma SPEC-NNN (elo banco↔feature)."""
    doc_dir = root / MIG_DOC_DIR
    if not doc_dir.is_dir():
        return
    docs = [f for f in doc_dir.glob("*.md") if f.is_file()]
    if not docs:
        return
    no_spec = []
    for d in docs:
        try:
            text = d.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        if not re.search(r"\bSPEC-\d{1,4}\b", text):
            no_spec.append(d.name)
    if no_spec:
        shown = ", ".join(no_spec[:8]) + (" ..." if len(no_spec) > 8 else "")
        warn(f"{len(no_spec)} doc(s) de migration sem referência a SPEC: {shown}")
    else:
        ok(f"Todas as {len(docs)} migration(s) documentadas referenciam uma SPEC.")


def section_boxes(text, title_pattern):
    """Conta checkboxes de uma seção "## <título>...". Retorna (total, pendentes)
    ou (None, None) se a seção não existe no arquivo (template antigo)."""
    sec = re.search(r"(?is)" + title_pattern + r"(.*?)(?:\n##\s|\Z)", text)
    if not sec:
        return None, None
    total = pend = 0
    for box in re.finditer(r"^\s*[-*]\s*\[( |x|X)\]", sec.group(1), re.MULTILINE):
        total += 1
        if box.group(1) == " ":
            pend += 1
    return total, pend


def parse_spec(text):
    """Extrai status, critérios de aceite, plano de testes, gate e rastreabilidade."""
    # Status: célula da tabela "| Status | <valor> |"
    status = ""
    m = re.search(r"\|\s*Status\s*\|\s*`?([^|`]+?)`?\s*\|", text, re.IGNORECASE)
    if m:
        status = strip_accents(m.group(1).strip().lower())

    # Critérios de aceite: checkboxes na seção "Critérios de aceite"
    total, pend = section_boxes(text, r"crit[ée]rios de aceite")
    total = total or 0
    pend = pend or 0

    # Gate de qualidade do kit: testes obrigatórios + review de segurança
    tests_total, tests_pend = section_boxes(text, r"plano de testes")
    gate_total, gate_pend = section_boxes(text, r"gate de qualidade")

    # "Arquivos de código" preenchido? (linha da tabela de rastreabilidade)
    code_filled = None  # None = campo não encontrado no arquivo
    cm = re.search(r"(?im)^\|\s*Arquivos de c[óo]digo\s*\|\s*(.+?)\s*\|", text)
    if cm:
        val = strip_accents(cm.group(1).strip().lower())
        val_clean = val.strip("`<> ")
        code_filled = bool(val_clean) and not any(p in val for p in PLACEHOLDER_MARKS)

    return status, total, pend, code_filled, tests_total, tests_pend, gate_total, gate_pend


def check_spec_conformance(root, specs):
    """Status × critérios de aceite × rastreabilidade de código."""
    p = root / SPEC_DIR
    if not p.is_dir() or not specs:
        return
    files = [f for f in p.glob("SPEC-*.md") if f.is_file()]
    if not files:
        return

    inventory = {}
    conform = 0
    for f in files:
        try:
            text = f.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        status, total, pend, code_filled, tests_total, tests_pend, gate_total, gate_pend = parse_spec(text)
        bucket = status if status in ("rascunho", "em-progresso", "concluida", "arquivada") else "outro"
        # normaliza "em progresso" / "em-progresso"
        if "progress" in status:
            bucket = "em-progresso"
        if "conclu" in status:
            bucket = "concluida"
        if "arquiv" in status:
            bucket = "arquivada"
        if "rascun" in status:
            bucket = "rascunho"
        inventory[bucket] = inventory.get(bucket, 0) + 1

        active = bucket in ("em-progresso", "concluida")

        # Regra 5: concluída com critério pendente = drift real (erro)
        if bucket == "concluida" and pend > 0:
            err(f"{f.name}: status 'concluída' mas {pend}/{total} critério(s) de aceite ainda pendente(s).")
            continue

        # Regras 7 e 8 — Gate de qualidade do kit (testes + segurança obrigatórios)
        if bucket == "concluida":
            gate_ok = True
            if tests_total is None:
                warn(f"{f.name}: sem seção 'Plano de testes' — regra do kit: toda funcionalidade mapeada em teste.")
            elif tests_pend and tests_pend > 0:
                err(f"{f.name}: status 'concluída' mas {tests_pend}/{tests_total} item(ns) do Plano de testes pendente(s) — regra do kit: testes obrigatórios na camada de testes.")
                gate_ok = False
            if gate_total is None:
                warn(f"{f.name}: sem seção 'Gate de qualidade' (template antigo?) — regra do kit: testes implementados + review do @security-auditor são obrigatórios.")
            elif gate_pend and gate_pend > 0:
                err(f"{f.name}: status 'concluída' mas Gate de qualidade aberto ({gate_pend}/{gate_total}) — testes implementados e review do @security-auditor são obrigatórios.")
                gate_ok = False
            if not gate_ok:
                continue

        # Regra 6: ativa sem rastreabilidade de código = aviso
        if active and code_filled is False:
            warn(f"{f.name}: status '{status or '?'}' mas 'Arquivos de código' não preenchido (elo SPEC↔código).")
            continue

        if active:
            conform += 1

    # Inventário didático
    if inventory:
        resumo = ", ".join(f"{v} {k}" for k, v in sorted(inventory.items()))
        info(f"Inventário de SPECs: {resumo}.")
    if conform:
        ok(f"{conform} SPEC(s) ativa(s) com critérios e rastreabilidade coerentes.")


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    print(f"\n{BOLD}{CYAN}Spec-Drift — {root}{END}")
    if not (root / "docs").is_dir():
        info("Sem pasta docs/ — projeto não usa o padrão spec-driven. Nada a validar.")
        sys.exit(0)

    # Referencial
    check_migrations(root)
    specs, adrs = check_references(root)
    check_index(root, specs, adrs)

    # Conformidade
    check_migration_docs_reference_spec(root)
    check_spec_conformance(root, specs)

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
