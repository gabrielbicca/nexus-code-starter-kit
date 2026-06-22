# Migration-NNN — <título curto>

| Campo | Valor |
|---|---|
| Arquivo SQL | `<supabase/migrations/NNN_descricao.sql>` |
| Data | `<YYYY-MM-DD>` |
| Depende de | `<Migration-NNN anterior ou —>` |
| SPEC relacionada | `<SPEC-NNN>` |

> A **fonte de verdade do SQL** é o arquivo `.sql` no repo. Este `.md` documenta o **porquê** e o **o quê** — não duplica o SQL inteiro.

---

## O que esta migration faz

<Descrição em 1-3 frases.>

## Mudanças de schema

- Tabelas criadas/alteradas: <lista>
- Colunas relevantes: <lista>
- Índices: <lista>

## RLS / Policies

- [ ] RLS habilitado nas tabelas novas
- Policies (resumo SELECT/INSERT/UPDATE/DELETE): <descrição>

## Rollback

<Como reverter (migration inversa ou passos manuais). Se não houver rollback seguro, declarar explicitamente.>

## Verificação pós-aplicação

- [ ] Aplica sem erro em ambiente limpo
- [ ] Isolamento multi-tenant testado (se aplicável)
- [ ] `super_admin` não é bloqueado por RLS
