# AGENT_FLOW — Guia rápido (spec-driven)

> Como o trabalho flui neste projeto. A documentação em `docs/` é a **fonte de verdade**; **o código vem depois da spec**.

## Spec-driven em 5 passos (o caminho feliz)

```
1. /spec  → SPEC-NNN     O QUÊ e POR QUÊ  + critérios de aceite   (docs/02_Specs/)
2. /plan  → PLAN-<slug>  COMO: quebra de tarefas, dependências    (docs/02_Specs/, linkado à SPEC)
3. /adr   → ADR-NNN      decisões arquiteturais (quando houver)    (docs/01_Architecture/)
4. @orchestrator         implementa seguindo a SPEC/PLAN, acionando os especialistas
5. /verify               valida tudo (inclui a checagem spec-driven) antes de concluir
```

> Ao fim: atualize o `Status` da SPEC, marque os critérios de aceite `[x]` e preencha a **Rastreabilidade → Arquivos de código**.

Bug fix trivial (typo, estilo, 1 arquivo, sem mudança de contrato/schema) pode pular o `@orchestrator` e a SPEC.

## SPEC × PLAN × ADR × Migration — quem é quem

| Artefato | Responde | É a/o… | Onde | Como criar |
|---|---|---|---|---|
| **SPEC-NNN** | *o quê / por quê* + critérios de aceite | **contrato** (o destino) | `docs/02_Specs/` | `/spec <descrição>` |
| **PLAN-\<slug\>** | *como*: tarefas, ordem, dependências | **execução** (o caminho) | `docs/02_Specs/` (linkado à SPEC) | `/plan <descrição>` |
| **ADR-NNN** | *por que decidimos assim* | **decisão** durável c/ trade-offs | `docs/01_Architecture/` | `/adr <decisão>` |
| **Migration-NNN.md** | *o quê mudou no banco* | **registro** da mudança de schema | `docs/02_Specs/Migrations/` | a partir do template |
| **Sprint log** | *o que foi feito / retro* | **diário** | `docs/03_Sprint_Logs/` | manual |

> Regra de ouro contra duplicação: a **SPEC** descreve o destino em alto nível; o **PLAN** detalha o caminho. Não copie a quebra de tarefas para dentro da SPEC.

## Quando invocar cada agente

| Situação | Agente |
|---|---|
| Feature multi-domínio | `@orchestrator` |
| Quebra de requisitos / plano | `@project-planner` |
| Schema / migrations (RLS se Postgres/Supabase) | `@database-architect` |
| API / services / actions | `@backend-specialist` |
| UI / componentes | `@frontend-specialist` |
| Testes unit/integração | `@test-engineer` |
| E2E | `@qa-automation-engineer` |
| Review de segurança | `@security-auditor` |
| Bug / root-cause | `@debugger` |
| Mapear codebase | `@explorer-agent` |

> Lista completa de agentes no `README.md` do kit e em `.claude/agents/`.

## Verificação (mantém o spec-driven coerente)

```bash
# Checagem rápida durante o desenvolvimento (inclui spec-drift):
python .claude/scripts/checklist.py .

# Só a coerência spec-driven (specs ↔ migrations ↔ índice ↔ código):
python .claude/scripts/spec_drift.py .

# Suíte completa antes de release (--url é opcional; sem ele, pula performance/E2E):
python .claude/scripts/verify_all.py . --url http://localhost:3000
```

> Atalho: o command **`/verify`** explica e roda essas verificações pra você.
