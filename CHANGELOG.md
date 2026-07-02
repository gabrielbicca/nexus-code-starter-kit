# Changelog

Todas as mudanças notáveis do projeto são documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/).

---

## [1.10.0] — 2026-07-02

> Tema: **Gate de qualidade obrigatório** — todo desenvolvimento novo passa a exigir, como regra do kit: (1) testes implementados na camada de testes com **toda funcionalidade mapeada em teste** e (2) **review do `@security-auditor`**. A regra é verificável, não só por convenção.

### Adicionado
- **Seção "Gate de qualidade (obrigatório — regra do kit)"** no `Feature-Spec-Template.md` — dois checkboxes bloqueantes por SPEC: *testes implementados* (todas as funcionalidades mapeadas em testes) e *review de segurança executado*. Seções seguintes renumeradas (Agentes → 8, Rastreabilidade → 9, Notas → 10).
- **Regras 7 e 8 no `spec_drift.py`** — SPEC `concluída` com item pendente no **Plano de testes** ou com o **Gate de qualidade** aberto agora é **erro** (exit 1), pegando também pre-commit e CI quando o gate spec-driven está instalado. SPECs antigas sem as seções geram aviso (não derrubam o build).
- **CHECKPOINT 3 (Quality Gate) no `@orchestrator`** — `test-engineer` e `security-auditor` passam a ser presença obrigatória em toda orquestração de desenvolvimento novo; encerrar sem os dois = orquestração falha. Step 2/3, Best Practices e Checkpoint Summary atualizados no mesmo sentido (o security review deixa de ser "if applicable").
- **Bloco "Gate de qualidade — regra obrigatória do kit"** no `AGENT_FLOW.md` — o caminho feliz spec-driven ganha os passos explícitos `@test-engineer` (5) e `@security-auditor` (6) antes do `/verify`.

### Alterado
- **`Feature-Spec-Template.md` — "Plano de testes" agora é "(obrigatório)"** — toda funcionalidade/critério de aceite precisa estar mapeado em pelo menos um teste; cada item indica qual critério cobre.
- **`bin/cli.js` (CLAUDE.md gerado)** — o Protocolo Obrigatório ganhou os passos 5 (`@test-engineer`) e 6 (`@security-auditor`) + nota do Gate; Proibições Absolutas ganharam "nunca concluir sem testes" e "nunca concluir sem review de segurança".
- **`docs/CLAUDE.template.md`** — "Ordem obrigatória para toda feature nova" ganhou os passos de testes (6) e review de segurança (7), ambos marcados como obrigatórios, + duas proibições novas.
- **Commands `/create` e `/enhance`** — ganharam a etapa "Quality Gate (MANDATORY)" antes do preview; `/spec` orienta o gate nos próximos passos; `/verify` explica como agir quando a falha é do Gate.
- **`README.md` e `APRESENTACAO.md`** — documentam o Gate de qualidade como regra verificável do kit.

---

## [1.9.0] — 2026-07-01

> Tema: **mapeamento de funcionalidades sempre por módulo e roteado para o contexto certo** — corrige dois vícios observados em uso real: o kit gerava um único arquivo compilado de funcionalidades e despejava o mapeamento no `CLAUDE.md`, poluindo-o.

### Adicionado
- **Convenção "Mapeamento & Documentação — Segregação por Módulo"** no `docs/CLAUDE.template.md` (lida toda sessão): **Regra 1** — todo mapeamento (funcionalidades, entidades/tabelas, fluxos, permissões, regras) é segregado por módulo, **um arquivo `.md` por módulo** em `docs/02_Specs/Modules/Module-<nome>.md`, **nunca** um único arquivo compilado; **Regra 2** — resumos/índices vão para `.claude/context/*.md` (import `@`), **não** para o `CLAUDE.md`, que permanece enxuto. Duas proibições novas cobrem os dois pontos.
- **Nova subpasta padrão `docs/02_Specs/Modules/`** documentada na estrutura de `docs/` do `CLAUDE.template.md`, do `NEW_PROJECT_BOOTSTRAP.md` e do `PROJECT_MIGRATION.md`.

- **`.NET` fiado ao `backend-specialist`** — o agente ganhou triggers `.NET / C# / ASP.NET Core / dotnet / EF Core / Dapper` na `description` (antes só Node.js/Python, podia nem ser selecionado em projeto .NET), uma seção **".NET / C# Ecosystem"** que roteia explicitamente para as skills `dotnet-backend-standards`, `dotnet-orm-efcore`, `dotnet-orm-dapper` e `dotnet-project-scaffold` + o command `/dotnet-new`, linha de .NET no quadro de seleção de framework e no Quality Control Loop (`dotnet build`/`dotnet test`). O `orchestrator` passa a listar `.NET/ASP.NET Core` no domínio do `backend-specialist`.

### Alterado
- **Padrão de scaffold `wafx` → `ntier`** — o nome do padrão N-Tier foi genericizado (removida a marca WAFX) em `dotnet-project-scaffold`, `/dotnet-new` e `backend-specialist`. O contrato do command passa a ser `--pattern clean|ntier`; a estrutura e as convenções N-Tier permanecem idênticas.
- **`PROJECT_MIGRATION.md` — Fase 3.2 reescrita** — deixa de mandar criar um único `SPEC-001-Current-State-Snapshot.md` e passa a exigir **um `Module-<nome>.md` por módulo**, com nota de roteamento de contexto (resumo em `.claude/context/`, detalhe em `docs/02_Specs/Modules/`, nada no `CLAUDE.md`). Checklist-resumo e Proibições da migração atualizados no mesmo sentido; Fase 2.1 cria a subpasta `Modules/`.
- **`AGENT_FLOW.md`** — tabela "quem é quem" ganhou a linha **`Module-<nome>.md`** (mapeamento por módulo) + nota reforçando "um arquivo por módulo, resumo no context, não no CLAUDE.md".
- **`.claude/context/business-rules.md`** — nota reforça "uma seção por módulo" e explicita que o detalhe vive em `docs/02_Specs/Modules/` enquanto o resumo fica no arquivo de contexto (não no `CLAUDE.md`).

---

## [1.8.0] — 2026-06-30

### Adicionado
- **Skills de backend .NET** — três cápsulas em `.claude/skills/` cobrindo o padrão dotnet do kit: `dotnet-backend-standards` (.NET 10 LTS / C# 14, Clean Architecture + DDD, exceções tipadas, FluentValidation, JWT, Scalar/OpenAPI, Serilog, cultura pt-BR e baseline de segurança obrigatório), `dotnet-orm-efcore` (EF Core LTS para escritas — Fluent API via `IEntityTypeConfiguration`, query filters de soft-delete, `AsNoTracking`/`Include` explícito, migrations) e `dotnet-orm-dapper` (Dapper para leituras complexas/relatórios/stored procedures, SQL parametrizado, multi-mapping, transações explícitas). As três se cruzam por referências relativas.
- **Skill `dotnet-project-scaffold`** — referência para gerar a estrutura de um projeto backend .NET novo a partir de dois padrões selecionáveis: `clean` (Clean Architecture + DDD, .NET 10 LTS) e `ntier` (N-Tier em camadas, .NET 8 LTS). Documenta árvore de projetos, passos `dotnet new`/`dotnet add reference`, pacotes mínimos e a regra de usar sempre versões **LTS** do framework e ORMs.
- **Command `/dotnet-new`** — gera o scaffold via `/dotnet-new <nome> [--pattern clean|ntier] [--orm efcore|dapper|both] [--portal <nome>]`. Carrega a skill `dotnet-project-scaffold`, fixa a versão LTS conforme o padrão, mostra o plano antes de gerar e roda `dotnet build` no final. README passa a anunciar **15 commands** e **42 skills**.

### Alterado
- `README.md` — bloco "O que é instalado" atualizado: 14 → **15 slash commands** (inclui `/dotnet-new`) e 38 → **42 cápsulas** de conhecimento técnico.

---

## [1.7.0] — 2026-06-26

> Tema: **spec-driven verificável, mais didático e mais fácil de usar** — sem remover nenhuma validação existente.

### Adicionado
- **Validador spec-drift com checagens de conformidade** (`.claude/scripts/spec_drift.py`) — além da integridade referencial (links), agora valida: toda `Migration-*.md` referencia uma `SPEC`; SPEC `concluída` com critério de aceite pendente vira **erro**; SPEC ativa sem rastreabilidade de código vira aviso; imprime um inventário de SPECs por status. Continua tolerante a stacks (projeto sem `docs/` não falha).
- **Spec-drift no portão principal** — `verify_all.py` ganhou a categoria **Spec-Driven** como **primeira** verificação (a suíte "completa" antes deixava de fora justamente a checagem que dá identidade ao kit).
- **Command `/verify`** — caminho fácil e didático para rodar a verificação (rápida, completa ou só spec-drift). README passa a anunciar **14 commands**.
- **Gate spec-driven na automação do projeto** — templates `templates/hooks/pre-commit` e `templates/github-workflows/spec-check.yml`; o CLI e o `install.ps1` oferecem instalá-los (opcional, não-destrutivo). Fecha o loop: o gate deixa de depender só de o humano lembrar de rodar.
- **Scripts antes inexistentes** — `vulnerability-scanner/scripts/dependency_analyzer.py` e `performance-profiling/scripts/bundle_analyzer.py` (advisory) eram referenciados pelo `verify_all.py` mas não existiam; agora existem e fazem checagens honestas e leves.

### Alterado
- **`verify_all.py`: `--url` virou opcional** — a suíte completa agora roda em projeto backend-only/biblioteca/mobile e na fase de planejamento; sem URL, pula só performance/E2E.
- **Transparência de "script ausente"** — `checklist.py` e `verify_all.py` deixam de contar um script ausente como sucesso silencioso; o relatório final avisa quantas checagens foram puladas por ausência ("não executadas"), evitando o "✨ tudo passou" enganoso.
- **CLAUDE.md gerado ensina o fluxo spec-driven** — o "Protocolo Obrigatório" (CLI e `install.ps1`) agora descreve `/spec → /plan → /adr → @orchestrator → /verify` e linka `docs/00_Meta/AGENT_FLOW.md`, em vez de só "invoque @orchestrator".
- **Templates mais claros e stack-neutros** — `Feature-Spec-Template.md` e `Migration-Template.md` ficam genéricos por padrão, com o bloco Postgres/Supabase+RLS em seção **opcional** (colapsável); a SPEC explica a distinção **SPEC (contrato) × PLAN (execução)** e a rastreabilidade de código. `AGENT_FLOW.md` reescrito como guia didático ("spec-driven em 5 passos" + tabela SPEC×PLAN×ADR×Migration).
- **`orchestrator.md`** — ownership de arquivos de banco generalizado (`migrations/`, `supabase/migrations/`, `*.sql`, além de Prisma/Drizzle), removendo o viés de stack único.
- **`project-planner.md`** — removidas regras cargo-cult de design alheias ao planejamento ("no purple/violet hex", "no standard layouts", "Purple check"); corrigidas as referências ao genérico `PLAN.md` e os exemplos de nome sem o prefixo `PLAN-`; Phase X passa a checar conformidade spec-driven.

### Corrigido
- **Paridade `install.ps1`** — o `docs/README.md` gerado pelo PowerShell agora inclui as tabelas `## Specs`/`## ADRs` e o "Como criar artefatos" (antes só o CLI Node criava; sem elas, `/spec` e `/adr` não tinham onde escrever).
- **Drift guard estendido** (`scripts/check-drift.js`) — passa a validar a contagem de commands no README, a **existência de todo script** referenciado em `checklist.py`/`verify_all.py` (pega "script-fantasma") e a presença dos templates de automação.

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
