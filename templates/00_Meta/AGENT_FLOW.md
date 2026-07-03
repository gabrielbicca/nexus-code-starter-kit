# AGENT_FLOW — Guia rápido (spec-driven)

> Como o trabalho flui neste projeto. A documentação em `docs/` é a **fonte de verdade**; **o código vem depois da spec**.

## Spec-driven em 5 passos (o caminho feliz)

```
1. /spec  → SPEC-NNN     O QUÊ e POR QUÊ  + critérios de aceite   (docs/02_Specs/)
2. /plan  → PLAN-<slug>  COMO: quebra de tarefas, dependências    (docs/02_Specs/, linkado à SPEC)
3. /adr   → ADR-NNN      decisões arquiteturais (quando houver)    (docs/01_Architecture/)
4. @orchestrator         implementa seguindo a SPEC/PLAN, acionando os especialistas
5. @test-engineer        implementa os testes — TODA funcionalidade mapeada em teste  🔴 obrigatório
6. @security-auditor     review de segurança da implementação                          🔴 obrigatório
7. /verify               valida tudo (inclui a checagem spec-driven) — a saída real é a EVIDÊNCIA de conclusão
```

> Ao fim: atualize o `Status` da SPEC, marque os critérios de aceite `[x]`, marque o **Gate de qualidade** (com a evidência do `/verify` registrada) e preencha a **Rastreabilidade → Arquivos de código**.

## 🔴 Gate de qualidade — regra obrigatória do kit

**Todo desenvolvimento novo** só está concluído quando:

1. **Testes implementados na camada de testes** — toda funcionalidade da SPEC mapeada em pelo menos um teste (`@test-engineer`; E2E com `@qa-automation-engineer`). Nenhuma funcionalidade fica sem teste.
2. **Review de segurança executado** — `@security-auditor` revisou a implementação e os apontamentos foram tratados.
3. **Verificação executada com evidência** — `/verify` (ou a suíte de testes) rodou **após** a implementação e a **saída real** foi registrada na SPEC/PR. Concluído se declara com evidência — "deve funcionar" não é evidência.

Isso não é convenção: o `spec_drift.py` **falha** (erro, exit 1) se uma SPEC for marcada `concluída` com o Plano de testes pendente ou o Gate de qualidade aberto — e o gate roda no pre-commit e no CI, se instalados.

Bug fix trivial (typo, estilo, 1 arquivo, sem mudança de contrato/schema) pode pular o `@orchestrator` e a SPEC.

## 🔌 Plugins externos (ex.: Superpowers)

Plugins como o **Superpowers** **complementam** o kit — nunca o substituem:

- O fluxo principal é o do Nexus (spec-driven, acima). Plugins entram como **apoio técnico pontual** dentro das etapas: **TDD**, **code review**, **refatoração** e **debugging**.
- **Não** criar specs, planos ou brainstorms paralelos aos gerados pelo Nexus — `/spec` e `/plan` do kit são a fonte de verdade.
- **Não** substituir o fluxo obrigatório `/spec → /plan → @orchestrator → @test-engineer → @security-auditor → /verify`.
- Em conflito de instruções, **as regras do kit prevalecem**.

## SPEC × PLAN × ADR × Migration — quem é quem

| Artefato | Responde | É a/o… | Onde | Como criar |
|---|---|---|---|---|
| **SPEC-NNN** | *o quê / por quê* + critérios de aceite | **contrato** (o destino) | `docs/02_Specs/` | `/spec <descrição>` |
| **PLAN-\<slug\>** | *como*: tarefas, ordem, dependências | **execução** (o caminho) | `docs/02_Specs/` (linkado à SPEC) | `/plan <descrição>` |
| **ADR-NNN** | *por que decidimos assim* | **decisão** durável c/ trade-offs | `docs/01_Architecture/` | `/adr <decisão>` |
| **Migration-NNN.md** | *o quê mudou no banco* | **registro** da mudança de schema | `docs/02_Specs/Migrations/` | a partir do template |
| **Module-\<nome\>.md** | *o que existe no módulo* (funcionalidades, entidades, regras) | **mapeamento** por módulo | `docs/02_Specs/Modules/` | um arquivo **por módulo** |
| **Sprint log** | *o que foi feito / retro* | **diário** | `docs/03_Sprint_Logs/` | manual |

> Regra de ouro contra duplicação: a **SPEC** descreve o destino em alto nível; o **PLAN** detalha o caminho. Não copie a quebra de tarefas para dentro da SPEC.

> **Mapeamento sempre por módulo:** ao mapear funcionalidades/entidades, gere **um arquivo por módulo** em `02_Specs/Modules/` — **nunca** um único arquivo compilado. O resumo/índice vai para `.claude/context/*.md` (import `@`), não para o `CLAUDE.md`.

## Quando invocar cada agente

| Situação | Agente |
|---|---|
| Feature multi-domínio | `@orchestrator` |
| Quebra de requisitos / plano | `@project-planner` |
| Schema / migrations (RLS se Postgres/Supabase) | `@database-architect` |
| API / services / actions | `@backend-specialist` |
| UI / componentes | `@frontend-specialist` |
| Testes unit/integração (🔴 obrigatório em todo desenvolvimento novo) | `@test-engineer` |
| E2E | `@qa-automation-engineer` |
| Review de segurança (🔴 obrigatório em todo desenvolvimento novo) | `@security-auditor` |
| Bug / root-cause | `@debugger` |
| Mapear codebase | `@explorer-agent` |
| Varredura de débito técnico / código morto (periódica: fim de sprint, pré-release) | `@clean-code-auditor` |

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

## 🏁 Fechamento de branch — fim de um desenvolvimento

Antes de considerar um desenvolvimento **encerrado** (e antes do merge):

1. **Gate de qualidade completo na SPEC** — testes (toda funcionalidade mapeada), review do `@security-auditor` e verificação com evidência: os três checkboxes marcados.
2. **`/verify` verde, com a saída real registrada** — a evidência vai na SPEC ou no PR.
3. **Docs atualizados** — `Status` da SPEC, critérios `[x]`, rastreabilidade, índice `docs/README.md` e arquivos de contexto (`.claude/context/`) afetados.
4. **`CLAUDE.md` atualizado** — se a mudança alterou regras, arquitetura ou migrations.
5. **PR referencia a SPEC** — `SPEC-NNN` no título ou corpo; merge só com CI verde.
6. **Limpeza** — apague a branch após o merge (e o worktree, se usou um para trabalho paralelo — `git worktree remove` + `git worktree prune`).

> Pendência "pra depois" não existe: se sobrou passo, a SPEC é `em-progresso` — não a marque `concluída`.
