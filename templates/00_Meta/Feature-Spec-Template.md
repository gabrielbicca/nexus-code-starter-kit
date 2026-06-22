# SPEC-NNN — <título da feature>

| Campo | Valor |
|---|---|
| Status | `<rascunho / em-progresso / concluída / arquivada>` |
| Autor | `<nome>` |
| Data | `<YYYY-MM-DD>` |
| ADRs relacionados | `<ADR-NNN ou —>` |
| Migrations | `<Migration-NNN ou —>` |

> **Spec-driven:** esta SPEC é escrita **antes** da implementação. Nenhum código nasce sem a SPEC correspondente. Atualize o status e os checkboxes conforme avança.

---

## 1. Problema / Contexto

<Que necessidade esta feature atende? Para quem? Por que agora? Escreva o suficiente para alguém entender sem contexto prévio.>

## 2. Objetivo

<Resultado esperado em 1-2 frases.>

### Critérios de aceite

- [ ] <critério verificável>
- [ ] <critério verificável>

## 3. Escopo

**Dentro**
- <o que será feito>

**Fora (explicitamente)**
- <o que NÃO será feito nesta SPEC>

## 4. Design técnico

### Banco de dados
- Tabelas/colunas em inglês (snake_case), PK `UUID`, `created_at`/`updated_at` com `DEFAULT now()`, RLS habilitado.
- Migration: `<Migration-NNN>` (documentar em `02_Specs/Migrations/`).

### Backend
- Services / server actions / endpoints afetados.
- Validação de entrada; paginação server-side (`.range()` + `count: 'exact'`) em listagens.

### Frontend
- Páginas/rotas/componentes, `loading.tsx`, i18n.

## 5. Segurança / RLS

- Policies necessárias (usar helpers `is_super_admin()`, `current_tenant_id()` — nunca ler `auth.jwt()` direto).
- Dados sensíveis e autorização por perfil.

## 6. Plano de testes

- [ ] Unit: <o quê>
- [ ] Integração (RLS / isolamento multi-tenant): <o quê>
- [ ] E2E (fluxo crítico): <o quê>

## 7. Agentes envolvidos

<ex.: `@database-architect` (schema), `@backend-specialist` (services), `@frontend-specialist` (UI), `@security-auditor` (review), `@test-engineer` (testes)>

## 8. Rastreabilidade

| Artefato | Referência |
|---|---|
| ADRs | `01_Architecture/ADR-NNN-*.md` |
| Migrations | `02_Specs/Migrations/Migration-NNN-*.md` |
| Arquivos de código | `<caminhos principais>` |

## 9. Notas / decisões em aberto

- <questões a resolver, suposições assumidas>
