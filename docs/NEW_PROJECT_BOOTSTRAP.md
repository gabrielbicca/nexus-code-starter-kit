# 🚀 NEW PROJECT BOOTSTRAP — Guia Temporário

> Guia de referência para **iniciar novos projetos do zero** seguindo o padrão compartilhado de documentação, agentes, banco e deploy.
> Este arquivo é **temporário** — use como checklist durante o bootstrap e arquive/remova quando o projeto estiver estabilizado.
>
> **Como usar este template:** copie este arquivo para o novo projeto, substitua os placeholders `<...>` pelos valores reais e execute o checklist de ponta a ponta.

---

## 🎯 Objetivo

Garantir que **todo novo projeto** nasça com:

1. A mesma estrutura de pastas (vault + repo)
2. O mesmo fluxo documentação-primeiro (Obsidian como cérebro externo)
3. Os mesmos agentes/skills/commands do Claude Code
4. As mesmas convenções de banco, RLS, migrations e commit
5. O mesmo protocolo obrigatório (`@orchestrator` antes de qualquer feature)

---

## 📁 Estrutura Obrigatória

### 1. Vault do Obsidian (`<NOME_DA_VAULT>/`)

```
📄 README.md              → MOC (Mapa de Conteúdo) — dashboard central do projeto
📁 00_Meta/               → Templates, convenções, AGENT_FLOW.md, .env.local.example
📁 01_Architecture/       → ADRs e diagramas
📁 02_Specs/              → Feature specs (.md) + guias (Deploy-Guide, Project-Scope)
   📁 Migrations/         → Docs .md das migrations (SEM .sql — fonte no repo)
📁 03_Sprint_Logs/        → Diários de sprint e retrospectivas
📁 04_Assets/             → Imagens, diagramas exportados
```

### 2. Repo Git (`<nome-do-projeto>/`)

```
📄 CLAUDE.md              → Contexto técnico (única fonte — não duplicar no vault)
📄 README.md              → README público do GitHub
📁 supabase/migrations/   → Arquivos .sql oficiais (fonte de verdade) — ou equivalente do stack
📁 supabase/functions/    → Edge Functions — ou equivalente
📁 .claude/agents/        → Subagentes Claude Code invocáveis
📁 .claude/commands/      → Slash commands
📁 .claude/skills/        → Skills (cápsulas de conhecimento)
📁 .claude/scripts/       → checklist.py + validators
📁 src/                   → Código da aplicação
📁 tests/                 → Testes unit + integration
```

---

## ⚙️ Protocolo Obrigatório em Todo Projeto

### Regra 0 — `@orchestrator` antes de qualquer feature nova

Para **qualquer feature nova** (SPEC nova, nova tabela, nova rota/página, refatoração multi-camada), o Claude **deve invocar `@orchestrator` ANTES de começar**. Sem exceções. Bug fix trivial (typo, 1 arquivo, estilo) pode pular.

### Regra 1 — Documentação PRIMEIRO, código DEPOIS

1. Ler a doc relevante no vault
2. Criar/atualizar a **SPEC** em `02_Specs/`
3. Criar/atualizar **ADR** se houver decisão arquitetural
4. Criar doc da **migration** em `02_Specs/Migrations/` se houver migration
5. Só então implementar

### Regra 2 — Ordem obrigatória para feature nova

```
0. Invocar @orchestrator
1. Documentação (Obsidian)     → SPEC + ADR + Migration doc
2. Migration SQL               → aplicar no banco
3. Types + Schema + Service    → código backend
4. Testes de integração        → validar RLS e lógica
5. Frontend                    → página + componentes + actions + i18n
6. Atualizar vault             → checkboxes, status, MOC
7. Atualizar CLAUDE.md         → regras, tabelas, migrations
8. Commit + Push               → AUTOMÁTICO (padrão `feat: descrição (SPEC-NNN)`)
```

---

## 🗄️ Convenções de Banco (padrão para todos os projetos)

- Tabelas e colunas em **inglês** (snake_case)
- **UUID** como PK sempre: `id UUID PRIMARY KEY DEFAULT gen_random_uuid()` — nunca `SERIAL`/`INTEGER`
- **`created_at` / `updated_at` / `created_by` / `updated_by` / `is_active`** em todas as tabelas
- **RLS habilitado** em toda tabela nova
- **Migrations numeradas**: `001_`, `002_`, … em `supabase/migrations/` (ou equivalente do stack)
- **Referência .md** obrigatória para cada migration em `02_Specs/Migrations/`
- **Nunca** concatenar SQL dinamicamente

### Template de migration

```sql
-- Migration: 00N_descricao_curta.sql
-- Descrição: O que esta migration faz
-- Data: YYYY-MM-DD
-- Depende de: migration anterior relevante
```

### Template de policy RLS (tabela com tenant_id)

```sql
CREATE POLICY tabela_select ON nome_tabela
FOR SELECT
USING (
  is_super_admin()
  OR tenant_id = current_tenant_id()
);
```

> Sempre usar funções helper (`is_super_admin()`, `current_tenant_id()`, `my_permission()`) — **nunca** `auth.jwt() ->> 'claim'` direto.

---

## 🧱 Stack Padrão (ajustar conforme necessidade do projeto)

| Camada | Tecnologia padrão |
|---|---|
| Frontend | Next.js 15 (App Router) + Shadcn/UI + Tailwind CSS |
| Backend | Supabase (Postgres + Auth + RLS + Storage) |
| Edge Functions | Supabase Edge Functions (Deno/TypeScript) |
| Auth | Supabase Auth (JWT padrão — sem custom hook) |
| Infra | Supabase Self-Hosted em VPS + Coolify |
| Agente | Claude Code (`.claude/agents/`) |
| Docs | Obsidian vault (cérebro externo, MCP via SSE) |
| i18n | next-intl cookie-based (default `en`) |

---

## 🤖 Ferramental Claude Code — Copiar do projeto-base

Ao iniciar um novo projeto, **copiar de um projeto-base já estabelecido** os seguintes diretórios:

```
.claude/agents/     → Subagentes (orchestrator, frontend, backend, db, etc.)
.claude/commands/   → Slash commands (/orchestrate, /create, /plan, etc.)
.claude/skills/     → Skills de conhecimento (linguagens, frameworks, processo)
.claude/scripts/    → checklist.py e validators
```

Esses ativos são **biblioteca reutilizável** — não reinventar em cada projeto.

---

## 📝 Templates Mínimos no Vault

Ao criar o vault de um novo projeto, garantir os templates em `00_Meta/`:

- `ADR-Template.md` — para decisões arquiteturais
- `Feature-Spec-Template.md` — para especificar features
- `Migration-Template.md` — para documentar migrations
- `AGENT_FLOW.md` — referência rápida de quando usar cada agente
- `.env.local.example` — variáveis de ambiente (sem valores reais)

---

## ✅ Checklist de Bootstrap (projeto novo)

### Vault Obsidian

- [ ] Criar pasta `<NOME_DA_VAULT>/` no diretório de vaults
- [ ] Criar `README.md` (MOC) copiando e adaptando do projeto-base
- [ ] Criar subpastas: `00_Meta/`, `01_Architecture/`, `02_Specs/`, `02_Specs/Migrations/`, `03_Sprint_Logs/`, `04_Assets/`
- [ ] Adicionar templates em `00_Meta/`
- [ ] Criar `Project-Scope.md` em `02_Specs/` com escopo inicial
- [ ] Configurar MCP SSE do Obsidian em uma **porta dedicada** para o projeto (não reusar portas de outros projetos)

### Repo Git

- [ ] Inicializar repo (`git init` + primeiro commit)
- [ ] Criar `CLAUDE.md` na raiz (usar `CLAUDE.template.md` e preencher placeholders)
- [ ] Copiar `.claude/` do projeto-base (agents, commands, skills, scripts)
- [ ] Criar `supabase/migrations/` vazio (ou equivalente do stack)
- [ ] Criar `.env.local.example` + garantir `.env.local` no `.gitignore`
- [ ] Rodar `.claude/scripts/checklist.py` para validar setup inicial

### Primeiro ADR e SPEC

- [ ] Criar `ADR-001-Core-Stack.md` documentando as escolhas do projeto
- [ ] Criar `ADR-002-Multi-Tenancy-RLS.md` (se multi-tenant)
- [ ] Criar `SPEC-001-Banco-Migrations-RLS.md` para bootstrap do banco
- [ ] Criar primeira migration `001_bootstrap.sql` + `Migration-001-Bootstrap.md`

### CI/CD

- [ ] GitHub Actions: Lint + Type Check + Unit Tests + Integration Tests + Security Audit
- [ ] Configurar pipeline de deploy automático da `main`
- [ ] Adicionar `Deploy-Guide.md` em `02_Specs/`

### Validação final do bootstrap

- [ ] `npm run type-check` passa
- [ ] `npm run lint` passa
- [ ] `npm test` passa (mesmo com 0 testes)
- [ ] `checklist.py` 6/6 PASSED
- [ ] Vault abre no Obsidian sem links quebrados
- [ ] `CLAUDE.md` lido pelo Claude Code sem erros

---

## 🚫 Proibições Universais (todos os projetos)

- Nunca remover RLS de tabelas existentes
- Nunca usar `SERIAL`/`INTEGER` como PK — só `UUID`
- Nunca concatenar SQL dinamicamente
- Nunca commitar `.env.local` ou chaves secretas
- Nunca implementar sem documentar antes no vault
- Nunca criar listagem sem paginação server-side (`.range()` + `count: 'exact'`)
- Nunca usar `confirm()` ou `<input type="date">` nativos — usar componentes do design system
- Nunca pular o `@orchestrator` em feature nova

---

## 🔁 Quando este arquivo deve ser removido

Este `NEW_PROJECT_BOOTSTRAP.md` é **temporário**. Remova quando:

1. O projeto tem vault estruturado com MOC funcional
2. O projeto tem `CLAUDE.md` completo com suas próprias regras
3. Pelo menos 1 SPEC foi implementada seguindo o fluxo completo
4. O time está familiarizado com o protocolo

A partir daí, o `CLAUDE.md` + o MOC do vault já carregam todo o contexto — este guia vira redundante.
