# Contexto — Agentes, Commands e Skills

> Referência rápida do ferramental Claude Code do projeto. Carregado **sob demanda** pelo `CLAUDE.md` (import `@`).
> Detalhe em `.claude/agents/`, `.claude/commands/`, `.claude/skills/` e no `docs/00_Meta/AGENT_FLOW.md`.

## Agentes mais usados

| Agente | Quando |
|---|---|
| `@orchestrator` | Feature multi-domínio |
| `@database-architect` | Schema / RLS / migrations |
| `@backend-specialist` | API / services / actions |
| `@frontend-specialist` | UI / componentes |
| `@test-engineer` | Testes unit/integração |
| `@security-auditor` | Review de segurança |

## Slash commands

| Comando | Uso |
|---|---|
| `/spec` | Criar SPEC-NNN (antes de codar) |
| `/adr` | Registrar ADR-NNN |
| `/orchestrate` | Orquestrar feature multi-domínio |
| `/plan` | Plano de tarefas (ligado à SPEC) |

## Validation scripts

- `python .claude/scripts/checklist.py .` — roda os validadores em ordem (security → lint → schema → tests → ux → seo → spec-drift)
- `python .claude/scripts/spec_drift.py .` — coerência spec-driven (migration↔doc, refs, índice)
