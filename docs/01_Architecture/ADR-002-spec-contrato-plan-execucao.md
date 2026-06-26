# ADR-002 — SPEC é o contrato; PLAN é a execução

| Campo | Valor |
|---|---|
| Status | Aceita |
| Data | 2026-06-26 |
| Decisores | gabrielbicca |
| SPEC relacionada | — |

> Um ADR registra **uma decisão arquitetural e o porquê dela**. ADRs são imutáveis: para mudar de ideia, crie um novo ADR que substitui este.

---

## Contexto

O kit tem dois artefatos de planejamento que se sobrepunham:

- **SPEC-NNN** (via `/spec`) continha *o quê/por quê* **e também** "Design técnico" (db/backend/frontend), "Plano de testes" e "Agentes envolvidos".
- **PLAN-\<slug\>** (via `/plan`/`project-planner`) continha Tech Stack, File Structure, Task Breakdown e atribuição de agentes.

Havia redundância (o "como" aparecia nos dois) e identidades inconsistentes (SPEC numerada `SPEC-NNN`; PLAN por slug). No SDD canônico a separação é limpa: *spec = o quê/por quê*, *plan = como*.

## Decisão

Adotamos uma fronteira explícita, documentada nos templates e no `AGENT_FLOW.md`:

- **SPEC = contrato (o destino):** problema, objetivo, **critérios de aceite verificáveis**, escopo, segurança, plano de testes e um **esboço técnico de alto nível**. Não detalha tarefas.
- **PLAN = execução (o caminho):** quebra de tarefas, dependências, ordem e estrutura de arquivos. Linka-se à SPEC (`SPEC relacionada`) e **não duplica** os critérios de aceite.

O `project-planner` e o `orchestrator` passam a tratar a SPEC como o gate (fonte de verdade) e o PLAN como o detalhamento ligado a ela.

## Alternativas consideradas

| Alternativa | Prós | Contras | Por que não |
|---|---|---|---|
| Fundir tudo num só artefato numerado | Menos arquivos | Mistura contrato e execução; documento gigante | Perde a clareza spec-driven |
| Numerar o PLAN (`PLAN-NNN`) | Identidade simétrica à SPEC | Mais cerimônia; slug é mais fácil de achar | Ganho pequeno para o atrito |
| **Fronteira explícita SPEC×PLAN (escolhida)** | Papéis claros; menos duplicação; baixo atrito | Exige disciplina de não copiar tarefas para a SPEC | Melhor custo/benefício |

## Consequências

**Positivas**
- Fim da duplicação "design na SPEC e no PLAN".
- O validador `spec_drift.py` consegue checar conformidade da SPEC (critérios, rastreabilidade) sem ambiguidade.

**Negativas / trade-offs**
- O PLAN segue identificado por slug (não numerado) — assimetria consciente com a SPEC.

**Riscos e mitigação**
- Risco: voltar a copiar a quebra de tarefas para dentro da SPEC → mitigação: nota explícita nos templates e no `AGENT_FLOW.md` ("a SPEC descreve o destino; o PLAN, o caminho").

## Relacionados

- SPECs: —
- Código: `templates/00_Meta/Feature-Spec-Template.md`, `templates/00_Meta/AGENT_FLOW.md`, `.claude/agents/project-planner.md`, `.claude/commands/plan.md`
- Relaciona: [[ADR-001-templates-stack-neutros]]
