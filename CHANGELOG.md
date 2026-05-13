# Changelog

Todas as mudanças notáveis do projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [1.4.0] — 2026-05-13

### Alterado
- `@n8n-specialist` — `description` reformulada para evitar falsos disparos: triggers genéricos (`workflow`, `node`, `trigger`, `expression`, `credential`, `automation`) substituídos pelas variantes prefixadas (`n8n workflow`, `n8n node`, etc.).
- `@n8n-specialist` — adicionado `WebFetch` ao `tools` do frontmatter. O agente prega "always check the specific provider's current docs" mas não tinha como acessar a web.
- `@n8n-specialist` — Phase 1 do "Workflow Design Process": `"→ Any unclear → ASK USER"` reescrito como `"return clarifying questions to the caller before building"`, com convenção `[ASSUMPTION: ...]` para quando o caller mandar prosseguir mesmo assim. Semântica funcional em contexto sub-agente.

### Removido
- `@n8n-specialist` — nota final órfã que prometia "loads relevant skills for detailed guidance" sem listar nenhuma skill (o kit não tem skills relacionadas a n8n).

---

## [1.3.0] — 2026-05-13

### Removido
- **Setup do MCP do Obsidian** — `setup_obsidian.ps1` deletado; tabela `MCP REST API` / `MCP Filesystem` removida do bloco que o CLI injeta no `CLAUDE.md`; geração automática de `.mcp.json` removida do CLI; seção "Configurar Obsidian MCP" removida do README; menções a `MCP via SSE` / "Configurar MCP SSE do Obsidian" removidas de `docs/CLAUDE.template.md`, `docs/NEW_PROJECT_BOOTSTRAP.md`, `docs/PROJECT_MIGRATION.md`.
- **Motivação:** desacoplar o kit da escolha de mecanismo MCP. A vault do Obsidian segue como cérebro externo do projeto (estrutura de pastas + protocolo de uso), mas o **como** acessá-la (REST API, Filesystem, outro MCP, sem MCP) fica a critério de cada projeto.

---

## [1.2.0] — 2026-05-13

### Adicionado
- **Drift guard** (`scripts/check-drift.js`) — valida que `orchestrator.md` e `README.md` estão em sincronia com os arquivos reais em `.claude/agents/` e `.claude/skills/`. Previne a categoria de bug corrigida em 1.1.0 (`api-designer` fantasma, agentes ausentes das tabelas).
- **GitHub Actions** — `.github/workflows/ci.yml` roda drift guard + syntax check + `npm publish --dry-run` em PRs e push pra `main`. `.github/workflows/publish.yml` publica no npm automaticamente em tag push `v*` (requer secret `NPM_TOKEN`).
- **`.npmignore` explícito** — raiz + `.claude/.npmignore` (per-directory). Previne vazamento de `settings.local.json` e outros artefatos para o registro npm.
- **Scripts npm** — `npm test` (drift guard) e `prepublishOnly` (syntax check + drift guard) garantem que publish quebrado não vai pro registro.

---

## [1.1.0] — 2026-05-13

### Adicionado
- Novo agente `@n8n-specialist` — especialista em workflows n8n (automations, webhooks, chatbots, ETL, integrações). Cobre node selection, expressions, credentials, sub-workflows, error handling, idempotência, queue mode e versionamento de workflows.
- `orchestrator.md` atualizado com o novo agente na tabela de agentes disponíveis e nas regras de boundaries.

### Corrigido
- `orchestrator.md`: removida referência ao agente inexistente `api-designer` das tabelas "Available Agents" e "Agent Boundary Enforcement".
- `orchestrator.md`: adicionados agentes que estavam ausentes das tabelas — `code-archaeologist`, `product-manager`, `product-owner`, `qa-automation-engineer`.
- `README.md`: contagem de agentes atualizada (20 → 21) e de skills (30+ → 38); `@n8n-specialist` incluído na tabela de agentes.
- `package.json`: `install.ps1` e `setup_obsidian.ps1` adicionados ao campo `files` para que sejam distribuídos via `npm`/`npx`.

---

## [1.0.0] — 2026-04-15

### Adicionado
- 20 agentes especializados: `@orchestrator`, `@backend-specialist`, `@frontend-specialist`, `@database-architect`, `@debugger`, `@devops-engineer`, `@security-auditor`, `@test-engineer`, `@qa-automation-engineer`, `@performance-optimizer`, `@explorer-agent`, `@code-archaeologist`, `@project-planner`, `@product-manager`, `@product-owner`, `@documentation-writer`, `@seo-specialist`, `@mobile-developer`, `@game-developer`, `@penetration-tester`
- 30+ skills de conhecimento técnico (Next.js, Supabase, TDD, API patterns, etc.)
- 11 slash commands: `/plan`, `/debug`, `/deploy`, `/create`, `/test`, `/enhance`, `/orchestrate`, `/preview`, `/status`, `/brainstorm`, `/ui-ux-pro-max`
- CLI interativo via `npx nexus-code-starter-kit`
- Instalador PowerShell via `irm | iex` para Windows
- Script de configuração do Obsidian MCP com suporte a dois modos (REST API e Filesystem)
- Templates de documentação: `CLAUDE.md`, bootstrap de projeto novo, guia de migração
