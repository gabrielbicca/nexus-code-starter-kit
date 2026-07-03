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
├── agents/      → 22 agentes especializados (@orchestrator, @backend-specialist, ...)
├── commands/    → 15 slash commands (/spec, /adr, /plan, /verify, /dotnet-new, /deploy, ...)
├── skills/      → 43 cápsulas de conhecimento técnico
├── scripts/     → Scripts de verificação e automação
└── context/     → Blocos de contexto importáveis (@imports do CLAUDE.md)

docs/            → Base de conhecimento spec-driven (specs, ADRs, sprint logs)
CLAUDE.md        → Contexto técnico do projeto (opcional, gerado sob demanda)
```

---

## Base de conhecimento (`docs/`)

O kit é **spec-driven**: a documentação é o cérebro do desenvolvimento. Por isso o instalador **sempre** cria a estrutura `docs/` na raiz do projeto — a fonte de verdade, versionada junto com o código:

```
docs/
├── README.md          → Índice (mapa da documentação)
├── 00_Meta/           → Templates (Feature-Spec, ADR, Migration, AGENT_FLOW)
├── 01_Architecture/   → ADRs e diagramas
├── 02_Specs/          → Feature specs e guias
│   └── Migrations/    → Docs (.md) das migrations
├── 03_Sprint_Logs/    → Diários de sprint
└── 04_Assets/         → Imagens e diagramas exportados
```

A criação é idempotente: se `docs/` já existir, os arquivos existentes são preservados (só os faltantes são adicionados).

O `00_Meta/` já vem com os templates prontos. Use os commands **`/spec`** e **`/adr`** para criar `SPEC-NNN` e `ADR-NNN` numerados (numeração automática) a partir deles, e o validador `spec_drift.py` para checar a coerência entre specs, migrations e código.

---

## Validação spec-driven (verificável, não só por convenção)

O kit não só **pede** specs — ele **verifica** que o projeto continua coerente. O validador `spec_drift.py` checa:

- **Referencial** — toda migration `.sql` tem doc; referências `SPEC-NNN`/`ADR-NNN` no código existem; o índice `docs/README.md` está atualizado.
- **Conformidade** — toda migration documentada cita uma `SPEC`; uma SPEC `concluída` tem **todos** os critérios de aceite marcados; SPECs ativas têm a rastreabilidade de código preenchida.
- **Gate de qualidade (regra do kit)** — todo desenvolvimento novo **tem testes implementados na camada de testes** (toda funcionalidade mapeada em teste, via `@test-engineer`), **passa pelo review do `@security-auditor`** e **fecha com a verificação executada e a evidência registrada** (a saída real do `/verify` — "deve funcionar" não é evidência). SPEC `concluída` com o Plano de testes pendente ou o Gate de qualidade aberto é **erro** (exit 1).

Três formas de rodar (use o command **`/verify`** para o caminho fácil):

```bash
python .claude/scripts/checklist.py .      # rápido, durante o dev (inclui spec-drift)
python .claude/scripts/verify_all.py .     # completo (--url é opcional: sem ele, pula performance/E2E)
python .claude/scripts/spec_drift.py .     # só a coerência spec-driven
```

Na instalação, o CLI oferece instalar o **gate spec-driven na automação**: um hook `pre-commit` e um workflow do **GitHub Actions** (`.github/workflows/spec-check.yml`) que rodam o `spec_drift.py` automaticamente. É opcional e não-destrutivo (preserva hooks/workflows existentes).

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
| `@clean-code-auditor` | Varredura periódica de débito técnico e código morto + backlog de refatoração |
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

### Convivência com outros plugins (ex.: Superpowers)

O kit convive com plugins externos, mas **o fluxo principal é sempre o do Nexus** (`/spec → /plan → @orchestrator → /verify`, com o Gate de qualidade). Plugins como o Superpowers entram só como **apoio pontual** — TDD, code review, refatoração e debugging — sem criar specs/planos paralelos nem substituir o fluxo. Essa regra vai escrita no `CLAUDE.md` gerado e no `AGENT_FLOW.md` instalados no projeto.

> Os melhores padrões do Superpowers já foram **absorvidos nativamente** pelo kit: verificação com evidência antes de concluir, review por tarefa no `@orchestrator`, antipadrões de teste (nunca testar o mock, espera por condição em E2E), git worktrees para trabalho paralelo e checklist de fechamento de branch.

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

---

## Licença

MIT
