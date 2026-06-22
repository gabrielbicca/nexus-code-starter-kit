# AGENT_FLOW — Referência rápida (spec-driven)

> Como o trabalho flui neste projeto. A documentação em `docs/` é a fonte de verdade; **o código vem depois da spec**.

## Ordem obrigatória para toda feature nova

```
0. @orchestrator                 → plano multi-domínio (regra de ouro)
1. /spec → SPEC-NNN              → o quê / por quê        (docs/02_Specs/)
   /adr  → ADR-NNN               → decisão arquitetural   (docs/01_Architecture/)
2. Migration SQL + doc           → docs/02_Specs/Migrations/Migration-NNN.md
3. Backend (types, schema, service)
4. Testes de integração (RLS, lógica)
5. Frontend (página, componentes, actions, i18n)
6. Atualizar docs/ (status da SPEC + índice README)
7. Atualizar CLAUDE.md (se mudou regra/convenção)
```

Bug fix trivial (typo, estilo, 1 arquivo, sem mudança de contrato/schema) pode pular o `@orchestrator` e a SPEC.

## Quando usar cada artefato

| Artefato | Quando | Onde | Como criar |
|---|---|---|---|
| **SPEC-NNN** | Toda feature nova / mudança multi-camada | `docs/02_Specs/` | `/spec <descrição>` |
| **ADR-NNN** | Decisão arquitetural com trade-offs duradouros | `docs/01_Architecture/` | `/adr <decisão>` |
| **Migration-NNN.md** | Toda migration de banco | `docs/02_Specs/Migrations/` | a partir do template |
| **Sprint log** | Diário / retrospectiva de sprint | `docs/03_Sprint_Logs/` | manual |

## Quando invocar cada agente

| Situação | Agente |
|---|---|
| Feature multi-domínio | `@orchestrator` |
| Schema / RLS / migrations | `@database-architect` |
| API / services / actions | `@backend-specialist` |
| UI / componentes | `@frontend-specialist` |
| Testes unit/integração | `@test-engineer` |
| E2E | `@qa-automation-engineer` |
| Review de segurança | `@security-auditor` |
| Bug / root-cause | `@debugger` |
| Mapear codebase | `@explorer-agent` |
| Breakdown de requisitos | `@project-planner` |

> Lista completa de agentes no `README.md` do kit e em `.claude/agents/`.
