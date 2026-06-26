#!/usr/bin/env python3
"""
Bundle Analyzer — peso do build (advisory)
==========================================

Inspeciona o output de build (se existir) e reporta:
  - Tamanho total do bundle
  - Maiores arquivos JS/CSS
  - Aviso para chunks grandes (> 500 KB)

Advisory: sempre sai com código 0. Se não houver build, instrui a rodar o build
antes. Para métricas de runtime (Core Web Vitals) use o lighthouse_audit.py.

Uso:
    python bundle_analyzer.py <project_path>
"""
import sys
from pathlib import Path

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except (AttributeError, ValueError):
    pass

G = "\033[92m"; Y = "\033[93m"; C = "\033[96m"; B = "\033[1m"; E = "\033[0m"

BUILD_DIRS = [".next", "dist", "build", "out", "public/build", ".output"]
ASSET_EXT = {".js", ".mjs", ".cjs", ".css"}
BIG_CHUNK = 500 * 1024  # 500 KB


def info(m): print(f"  {C}→{E} {m}")
def ok(m): print(f"  {G}✓{E} {m}")
def warn(m): print(f"  {Y}!{E} {m}")


def human(n):
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.0f} {unit}"
        n /= 1024
    return f"{n:.0f} TB"


def main():
    root = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
    print(f"\n{B}{C}Bundle Analyzer — {root}{E}")

    build = next((root / d for d in BUILD_DIRS if (root / d).is_dir()), None)
    if not build:
        info("Nenhum diretório de build encontrado (.next/dist/build/out).")
        info("Rode o build do projeto antes (ex.: npm run build) para analisar o bundle.")
        print(f"\n{G}✓ Bundle analyzer concluído (sem build — nada a medir).{E}")
        sys.exit(0)

    assets = []
    total = 0
    for f in build.rglob("*"):
        if f.is_file() and f.suffix.lower() in ASSET_EXT:
            try:
                size = f.stat().st_size
            except OSError:
                continue
            assets.append((size, f))
            total += size

    if not assets:
        info(f"Build em '{build.name}/' sem assets JS/CSS reconhecíveis.")
        print(f"\n{G}✓ Bundle analyzer concluído.{E}")
        sys.exit(0)

    info(f"Build: {build.name}/  |  {len(assets)} asset(s) JS/CSS  |  total {human(total)}")

    assets.sort(reverse=True)
    print(f"\n  {B}Maiores arquivos:{E}")
    for size, f in assets[:8]:
        try:
            rel = f.relative_to(root)
        except ValueError:
            rel = f.name
        flag = f" {Y}(grande){E}" if size > BIG_CHUNK else ""
        print(f"    {human(size):>9}  {rel}{flag}")

    big = [f for s, f in assets if s > BIG_CHUNK]
    print()
    if big:
        warn(f"{len(big)} chunk(s) acima de 500 KB — considere code-splitting / lazy-load.")
    else:
        ok("Nenhum chunk acima de 500 KB.")

    print(f"\n{G}✓ Bundle analyzer concluído (advisory).{E}")
    sys.exit(0)


if __name__ == "__main__":
    main()
