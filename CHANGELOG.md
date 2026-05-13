# Changelog

Todas as mudanças notáveis do projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

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
