# Changelog

Todas as mudanças notáveis do projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [1.6.0] — 2026-06-22

### Alterado
- **Documentação desacoplada do Obsidian** — o kit deixa de referenciar o Obsidian e adota um padrão genérico de documentação **spec-driven** dentro do próprio repositório, em `docs/`. A base de conhecimento (specs, ADRs, sprint logs) é versionada junto com o código e abre em qualquer editor de markdown. Conclui o desacoplamento iniciado em 1.3.0.
- `bin/cli.js` — removidas as perguntas "Usar Obsidian como cérebro externo?" e o caminho da vault. O `CLAUDE.md` gerado agora **sempre** inclui o bloco **Base de Conhecimento** apontando para `docs/`. `--help` atualizado.
- `install.ps1` — paridade com o CLI Node: o `CLAUDE.md` gerado inclui o bloco de base de conhecimento e o instalador cria `docs/`.
- `docs/CLAUDE.template.md`, `docs/NEW_PROJECT_BOOTSTRAP.md`, `docs/PROJECT_MIGRATION.md` — "vault do Obsidian / cérebro externo" substituído por "base de conhecimento em `docs/`"; a estrutura de pastas, antes uma vault externa, passa a viver dentro do repo; ênfase no fluxo spec-driven.
- `README.md` — Obsidian removido dos pré-requisitos; nova seção "Base de conhecimento (`docs/`)"; `docs/` e `CLAUDE.md` listados em "O que é instalado".
- **Agentes spec-aware (enforcement)** — `orchestrator` e `project-planner` agora **leem** as SPECs/ADRs existentes e **exigem uma SPEC** em `docs/02_Specs/` antes de implementar (o gate deixa de ser o `PLAN.md` efêmero). O plano do `project-planner` passa a viver em `docs/02_Specs/PLAN-<slug>.md` ligado à SPEC, em vez da raiz do projeto — resolvendo a contradição interna do próprio agente. Commands `/orchestrate` e `/plan` e a skill `plan-writing` alinhados. Caminho de ADR unificado para `docs/01_Architecture/ADR-NNN` (a skill `architecture` usava `docs/architecture/adr-00X`).

### Adicionado
- **Estrutura `docs/` criada na instalação** — `bin/cli.js` e `install.ps1` criam, de forma **não-opcional** e idempotente, o esqueleto da base de conhecimento (`00_Meta/`, `01_Architecture/`, `02_Specs/Migrations/`, `03_Sprint_Logs/`, `04_Assets/` + `README.md` índice). Como a documentação é o núcleo do framework spec-driven, deixa de ser um passo opcional. Arquivos existentes são sempre preservados.
- **Templates de documentação** em `templates/00_Meta/` (`Feature-Spec-Template.md`, `ADR-Template.md`, `Migration-Template.md`, `AGENT_FLOW.md`, `.env.local.example`), copiados para `docs/00_Meta/` na instalação. Fecha o gap dos "templates-fantasma" — o protocolo referenciava templates que não existiam no kit.
- **Commands `/spec` e `/adr`** — criam `SPEC-NNN` / `ADR-NNN` com **numeração automática** a partir dos templates, em `docs/02_Specs/` e `docs/01_Architecture/`, e atualizam o índice. README passa a anunciar 13 commands.
- **Validador spec-driven** (`.claude/scripts/spec_drift.py`, plugado no `checklist.py` como check P6) — valida migration↔doc, referências a SPEC/ADR existentes e índice atualizado; tolerante a stacks variados (não falha em projeto sem `docs/`).
- **Drift guard estendido** (`scripts/check-drift.js`) — o CI do kit passa a falhar se os templates de `templates/00_Meta/` sumirem. `templates/` adicionado ao campo `files` do `package.json`.
- **Contexto Expandido / `.claude/context/`** — padrão "CLAUDE.md leve + contexto importável sob demanda": stubs genéricos em `.claude/context/` (`migrations`, `specs-adrs-pages`, `business-rules`, `github-project`, `ui-patterns`, `agents-skills`), instalados via `.claude/`, e nova seção "📥 Contexto Expandido — Arquivos Importáveis" no `CLAUDE.template.md` com os `@imports`. Complementam (não duplicam) a base de conhecimento em `docs/`.

---

## [1.5.0] — 2026-05-13

### Adicionado
- **Caminho de atualização** — CLI agora detecta `.claude/` existente e oferece prompt 3-way: **Merge** (só adiciona arquivos novos, preserva existentes — padrão antigo), **Sobrescrever** (atualiza TODOS os agentes/skills/commands — útil pra puxar fixes do orchestrator), **Cancelar**.
- **Marcador de versão** — `.claude/.kit-version` é gravado no projeto-alvo após install/update. CLI e `install.ps1` ambos escrevem. Quando o CLI roda num projeto desatualizado, mostra a versão instalada vs. disponível.
- **Flags `--help` / `--version`** no `bin/cli.js`.
- **`CONTRIBUTING.md`** — guia de contribuição (o que aceitamos, convenções, fluxo de release).
- **`docs/CREATING_SKILLS.md`** — tutorial sobre criar skills (movido de `.claude/skills/doc.md`, que quebrava o padrão "skill = pasta").

### Alterado
- `README.md` — nova seção "Atualizando um projeto existente" documentando o fluxo merge/sobrescrever; link pra `CONTRIBUTING.md` e `docs/CREATING_SKILLS.md`.
- `install.ps1` — também grava `.kit-version` (paridade com o CLI Node).

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
