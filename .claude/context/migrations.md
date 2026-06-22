# Contexto — Migrations

> Resumo/índice das migrations do projeto, para acesso rápido pelo Claude.
> Carregado **sob demanda** pelo `CLAUDE.md` (import `@`). Mantenha atualizado.
> O detalhe de cada migration vive em `docs/02_Specs/Migrations/Migration-NNN-*.md`; a fonte de verdade do SQL são os `.sql` no repo.

## Padrão de cabeçalho da migration (.sql)

```sql
-- Migration: NNN_descricao_curta.sql
-- Descrição: o que esta migration faz
-- Data: YYYY-MM-DD
-- Depende de: migration anterior relevante (se houver)
```

## Tabela das migrations

| # | Arquivo | O que faz | Doc |
|---|---|---|---|
| 001 | `<arquivo>.sql` | `<resumo de uma linha>` | `docs/02_Specs/Migrations/Migration-001-*.md` |

> **Próxima migration disponível:** `NNN`.
