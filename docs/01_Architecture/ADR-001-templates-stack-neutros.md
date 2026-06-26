# ADR-001 — Templates spec-driven stack-neutros por padrão

| Campo | Valor |
|---|---|
| Status | Aceita |
| Data | 2026-06-26 |
| Decisores | gabrielbicca |
| SPEC relacionada | — |

> Um ADR registra **uma decisão arquitetural e o porquê dela**. ADRs são imutáveis: para mudar de ideia, crie um novo ADR que substitui este.

---

## Contexto

O kit se anuncia como "tolerante a stacks variados" (o `spec_drift.py` não falha em projeto sem `docs/` nem assume um banco específico). Na prática, porém, os artefatos carregavam um viés contraditório:

- `Feature-Spec-Template.md` cravava helpers Supabase/RLS (`is_super_admin()`, `current_tenant_id()`, `.range()`) e multi-tenancy como se fossem universais.
- `Migration-Template.md` assumia RLS/policies em toda migration.
- `orchestrator.md` declarava ownership de banco por **Prisma/Drizzle** — outra stack.
- O CLAUDE.md gerado sugeria `Next.js + Supabase`.

Resultado: um projeto que não usa Postgres/Supabase recebia um template de SPEC que **mentia** sobre o seu próprio contexto, e o kit dava sinais internos conflitantes (Supabase vs Prisma).

## Decisão

Os templates spec-driven são **stack-neutros por padrão**. O conteúdo específico de Postgres/Supabase + RLS vira uma **seção opcional e claramente marcada** (bloco colapsável "Opcional — Postgres/Supabase com RLS") dentro de `Feature-Spec-Template.md` e `Migration-Template.md`. O ownership de banco no `orchestrator.md` é generalizado (`migrations/`, `supabase/migrations/`, `*.sql`, além de Prisma/Drizzle).

## Alternativas consideradas

| Alternativa | Prós | Contras | Por que não |
|---|---|---|---|
| Assumir Supabase como stack oficial | Templates mais ricos out-of-the-box | Exclui a maioria dos projetos; contradiz o discurso "qualquer stack" | Fecharia o público-alvo do kit |
| Template Supabase separado (arquivo à parte) | Separação limpa | `/spec` teria de escolher template; mais atrito e fricção de descoberta | Complexidade desnecessária para o ganho |
| **Neutro + bloco opcional (escolhida)** | Serve a todos; preserva a orientação Supabase para quem usa | Exige o usuário remover o bloco se não aplicável | Trade-off aceitável |

## Consequências

**Positivas**
- O kit passa a servir honestamente qualquer stack.
- Quem usa Supabase ainda recebe a orientação de RLS, agora explicitamente opcional.

**Negativas / trade-offs**
- Projetos Supabase precisam manter (ou remover) o bloco opcional conscientemente.

**Riscos e mitigação**
- Risco: o bloco opcional ser ignorado e RLS esquecido em projeto Supabase → mitigação: o bloco é destacado e o `@security-auditor`/`@database-architect` continuam cobrando RLS quando a stack é Supabase.

## Relacionados

- SPECs: —
- Código: `templates/00_Meta/Feature-Spec-Template.md`, `templates/00_Meta/Migration-Template.md`, `.claude/agents/orchestrator.md`
- Substitui/relaciona: [[ADR-002-spec-contrato-plan-execucao]]
