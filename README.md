# nexus-code-starter-kit

> Kit de agentes, skills e commands para o [Claude Code](https://claude.ai/download).
> Instala em segundos a estrutura padrão em projetos novos ou existentes.

---

## Instalação

```bash
npx nexus-code-starter-kit
```

Ou, via PowerShell (Windows):

```powershell
irm https://raw.githubusercontent.com/gabrielbicca/nexus-code-starter-kit/main/install.ps1 | iex
```

---

## O que é instalado

```
.claude/
├── agents/      → 21 agentes especializados (@orchestrator, @backend-specialist, ...)
├── commands/    → 11 slash commands (/plan, /debug, /deploy, ...)
├── skills/      → 38 cápsulas de conhecimento técnico
└── scripts/     → Scripts de verificação e automação
```

---

## Agentes disponíveis

| Agente | Especialidade |
|--------|--------------|
| `@orchestrator` | Coordena múltiplos agentes em features complexas |
| `@backend-specialist` | APIs, endpoints, lógica de servidor |
| `@frontend-specialist` | UI, componentes, Next.js, React, Tailwind |
| `@database-architect` | Schema, migrations, Supabase, RLS, queries |
| `@debugger` | Root cause analysis, bugs, crashes |
| `@devops-engineer` | Deploy, CI/CD, Docker, GitHub Actions |
| `@security-auditor` | Vulnerabilidades, OWASP, RLS, auth |
| `@test-engineer` | Testes unitários e integração, TDD |
| `@qa-automation-engineer` | E2E com Playwright e Cypress |
| `@performance-optimizer` | Bundle size, Core Web Vitals, queries lentas |
| `@explorer-agent` | Mapeamento de codebases desconhecidos |
| `@code-archaeologist` | Código legado, refatoração segura |
| `@project-planner` | Breakdown de tarefas complexas |
| `@product-manager` | PRDs, user stories, requisitos |
| `@product-owner` | MVP, backlog, trade-offs de escopo |
| `@documentation-writer` | READMEs, guias, API reference |
| `@seo-specialist` | Meta tags, structured data, GEO |
| `@mobile-developer` | React Native, Expo, Flutter |
| `@game-developer` | Unity, Godot, Phaser, Three.js |
| `@penetration-tester` | Pentest e segurança ofensiva |
| `@n8n-specialist` | Workflows n8n (automations, webhooks, chatbots, ETL) |

---

## Como usar após instalar

Abra o projeto no Claude Code:

```bash
claude /caminho/do/projeto
```

Para qualquer feature nova, invoque o orchestrator:

```
@orchestrator quero criar [descreva a feature]
```

---

## Atualizando um projeto existente

Rode o instalador de novo no mesmo diretório:

```bash
npx nexus-code-starter-kit
```

O CLI detecta `.claude/` e mostra três opções:

- **Merge** — só adiciona arquivos novos (preserva os existentes — modo seguro padrão).
- **Sobrescrever** — substitui TODOS os agentes, skills e commands pela versão atual do kit. Use quando quiser receber fixes (ex.: correções do `orchestrator.md`).
- **Cancelar** — sai sem mexer em nada.

A versão instalada fica gravada em `.claude/.kit-version`. Quando você roda o CLI numa versão antiga, ele avisa qual versão está e qual está disponível.

Outras flags úteis:

```bash
npx nexus-code-starter-kit --version    # versão do kit
npx nexus-code-starter-kit --help       # ajuda completa
```

---

## Documentação

| Arquivo | Conteúdo |
|---------|----------|
| [`docs/CLAUDE.template.md`](docs/CLAUDE.template.md) | Template do CLAUDE.md do projeto |
| [`docs/NEW_PROJECT_BOOTSTRAP.md`](docs/NEW_PROJECT_BOOTSTRAP.md) | Guia detalhado para projetos novos |
| [`docs/PROJECT_MIGRATION.md`](docs/PROJECT_MIGRATION.md) | Guia detalhado para migração |
| [`docs/CREATING_SKILLS.md`](docs/CREATING_SKILLS.md) | Como criar suas próprias skills |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Guia de contribuição |

---

## Pré-requisitos

- [Node.js](https://nodejs.org) 18+
- [Claude Code](https://claude.ai/download)
- [Obsidian](https://obsidian.md) *(opcional, para documentação)*

---

## Licença

MIT
