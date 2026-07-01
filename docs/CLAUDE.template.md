# CLAUDE.md

> Arquivo de contexto para o Claude Code.
> Leia este arquivo COMPLETO antes de qualquer ação no projeto.
>
> **Como usar este template:** copie este arquivo para a raiz do novo projeto como `CLAUDE.md` e substitua os placeholders `<...>` pelos valores reais do projeto. Mantenha a estrutura, as regras e as proibições — elas são padrão e não devem ser removidas.

---

## 🧠 Base de Conhecimento — Fonte de Verdade

Este projeto é **spec-driven**: a documentação é o **cérebro do desenvolvimento** — nenhuma implementação começa sem a spec correspondente existir antes. Esta base de conhecimento é a fonte de verdade e o contexto que sustenta cada decisão técnica do projeto. Trate-a como um **documento vivo** — ela precisa estar sempre atualizada, nunca desatualizada. Toda alteração em schema, RLS, regras de negócio, arquitetura ou infraestrutura **deve** ser refletida aqui imediatamente.

A base de conhecimento vive em `docs/`, versionada junto com o código.

| Item | Valor |
|---|---|
| Pasta | `docs/` |

> Antes de tomar qualquer decisão técnica, consulte `docs/`. Antes de concluir qualquer implementação, atualize `docs/`.

---

## 📥 Contexto Expandido — Arquivos Importáveis

Para manter este `CLAUDE.md` leve, o conteúdo volumoso é extraído para `.claude/context/` e carregado **sob demanda** via import `@`. Leia o arquivo correspondente apenas quando trabalhar no tópico:

- `@.claude/context/migrations.md` — Tabela-resumo das migrations + padrão de cabeçalho
- `@.claude/context/specs-adrs-pages.md` — Índice de SPECs, ADRs, tabelas, páginas, edge functions, deploy
- `@.claude/context/business-rules.md` — Regras de negócio detalhadas do projeto
- `@.claude/context/github-project.md` — Gotchas do GitHub Project, Issue Forms, campos, fluxo de cards
- `@.claude/context/ui-patterns.md` — Paginação, Toast, Combobox, DatePicker, ConfirmDialog, Loading, Features
- `@.claude/context/agents-skills.md` — Agentes, slash commands, skills, validation scripts

> Estes arquivos **complementam** a base de conhecimento detalhada em `docs/` — são resumos/índices de acesso rápido, não substituem as SPECs/ADRs/migrations. Ao concluir uma feature, atualize o(s) arquivo(s) de contexto afetado(s): também são documento vivo.

---

## ⚙️ Protocolo Obrigatório — Antes de Qualquer Trabalho

Esta seção não é opcional. É o fluxo de trabalho padrão para toda sessão.

### 0. PRIMEIRO PASSO — Invocar `@orchestrator` para toda feature nova

> **REGRA DE OURO:** Para **qualquer implementação de feature nova** (não bug fix trivial), o Claude **deve invocar `@orchestrator` ANTES de começar**. Sem exceções. Isso garante que toda feature passe por planejamento multi-domínio (database, backend, frontend, segurança, testes) em vez de cair direto em código.

**O que conta como "feature nova":**

- Nova SPEC (qualquer SPEC-NNN nova)
- Nova tabela, migration ou função no banco
- Nova página, rota ou componente significativo
- Nova integração externa (API, edge function)
- Refatoração que toca múltiplos arquivos/camadas
- Qualquer mudança que afete duas ou mais das camadas: database / backend / frontend / infra / testes

**O que NÃO conta (bug fix trivial — pode pular o orchestrator):**

- Correção de typo, label, mensagem de toast
- Bug fix isolado em 1 arquivo, sem mudança de schema/contrato
- Ajuste de estilo (cores, padding, espaçamento)
- Atualização de doc/comentário/i18n
- Fix de teste quebrado por mudança trivial

**Como invocar:**

```
Use o tool Agent com subagent_type="orchestrator" e passe:
- A descrição da feature
- A SPEC relacionada (ou a necessidade de criar uma)
- Constraints conhecidas
```

O orchestrator vai:

1. Quebrar a feature em domínios (database, backend, frontend, security, tests)
2. Decidir quais especialistas chamar (`@database-architect`, `@backend-specialist`, etc.) e em qual ordem
3. Identificar dependências e riscos
4. Propor um plano que passa pelo Socratic Gate antes de executar

**Em caso de dúvida** se algo é "feature nova" ou "bug fix trivial": **sempre invocar o orchestrator**. O custo de planejar demais é baixo; o custo de pular o planejamento é alto (decisões arquiteturais erradas, retrabalho, débito).

> Esta regra é **explícita e obrigatória**. Não improvise — siga.

---

### 1. ANTES de qualquer alteração ou implementação

OBRIGATÓRIO — sem exceções. A documentação vem PRIMEIRO, o código vem DEPOIS.

1. **Ler a documentação relevante em `docs/`** para o que será trabalhado
2. **Criar a documentação em `docs/` ANTES de implementar:**
   - Criar/atualizar a **SPEC** correspondente em `02_Specs/`
   - Criar/atualizar o **ADR** se houver decisão arquitetural em `01_Architecture/`
   - Criar o **doc da migration** em `02_Specs/Migrations/` se houver migration
3. **Identificar TODOS os arquivos e módulos** que se conectam à parte afetada
4. **Ler os arquivos relacionados** no código para entender o estado atual
5. Só então propor ou implementar qualquer mudança

> **A documentação é pré-requisito, não pós-requisito.** Nunca implemente sem antes ter documentado o que será feito em `docs/`. Isso garante rastreabilidade, alinhamento e evita decisões no escuro.

**Nunca assuma como algo funciona.** Leia primeiro. A documentação existe para evitar que decisões sejam tomadas no escuro — use-a sempre.

**Arquivos que se conectam importam tanto quanto o arquivo principal.** Antes de mexer em qualquer módulo, identifique suas dependências: quem chama esse módulo? Quem ele chama? O que quebra se ele mudar?

### 2. DEPOIS de qualquer alteração ou nova feature

1. **Atualizar a documentação** em `docs/` — marcar checkboxes, atualizar status das specs
2. **Atualizar o `docs/README.md`** (índice) se a mudança afetou estrutura ou status
3. **Atualizar este CLAUDE.md** se a mudança alterou regras, convenções ou arquitetura

> Código sem documentação atualizada é código incompleto. A implementação só está concluída quando `docs/` reflete o estado atual.

### 3. Ordem obrigatória para toda feature nova

```
0. Invocar @orchestrator (regra 0 acima) → gera plano multi-domínio
1. Documentação (docs/)                   → SPEC + ADR + Migration doc
2. Migration SQL                          → aplicar no banco
3. Types + Schema + Service               → código backend
4. Testes de integração                   → validar RLS e lógica
5. Frontend                               → página + componentes + actions + i18n
6. Atualizar docs/                        → checkboxes, status, índice
7. Atualizar CLAUDE.md                    → regras, tabelas, migrations
```

---

## 🧭 Visão Geral do Projeto

| Item | Valor |
|---|---|
| Produto | `<DESCRIÇÃO_CURTA_DO_PRODUTO>` |
| Repositório | `<NOME_DO_REPO>` |
| Banco | `<PROVIDER_E_HOST_DO_BANCO>` |
| API URL | `<URL_DA_API>` |

---

## 🧱 Stack

| Camada | Tecnologia |
|---|---|
| Frontend | `<FRAMEWORK_FRONTEND>` |
| Backend | `<BACKEND_OU_BAAS>` |
| Banco | `<BANCO_DE_DADOS>` |
| Auth | `<PROVEDOR_DE_AUTH>` |
| Infra | `<HOSPEDAGEM_E_ORQUESTRAÇÃO>` |
| Agente | Claude Code (subagentes em `.claude/agents/`) |
| Docs | Base de conhecimento em `docs/` (no repo) |

---

## 🗄️ Banco de Dados — Convenções

### Regras obrigatórias

- **Nomes de tabelas e colunas em inglês** (snake_case)
- **`created_at` e `updated_at`** em todas as tabelas: `DEFAULT now()`
- **RLS habilitado** em todas as tabelas: `ALTER TABLE x ENABLE ROW LEVEL SECURITY`
- **Migrations numeradas sequencialmente**: `001_`, `002_`, ... (próxima disponível: `<NNN>_`)
- **Caminho das migrations**: `supabase/migrations/` (ou equivalente do projeto)
- **Referência .md de cada migration**: `docs/02_Specs/Migrations/Migration-NNN-*.md`
- **Nunca usar** `SERIAL` ou `INTEGER` como PK — somente `UUID`
- **Nunca concatenar** SQL dinamicamente — sempre parametrizar queries

### Template de migration

```sql
-- Migration: 00N_descricao_curta.sql
-- Descrição: O que esta migration faz
-- Data: YYYY-MM-DD
-- Depende de: migration anterior relevante (se houver)

-- 1. Criar tabela
CREATE TABLE IF NOT EXISTS nome_tabela (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  -- campos...
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Habilitar RLS
ALTER TABLE nome_tabela ENABLE ROW LEVEL SECURITY;

-- 3. Policies (ver seção RLS abaixo)
-- ...
```

---

## 🔐 RLS — Padrão Obrigatório

Toda tabela nova precisa ter RLS habilitado e policies que respeitem o modelo multi-tenant (se aplicável).

### Template de policy (tabela com `tenant_id`)

```sql
-- SELECT
CREATE POLICY nome_tabela_select ON nome_tabela
FOR SELECT
USING (
  is_super_admin()
  OR tenant_id = current_tenant_id()
);

-- INSERT / UPDATE / DELETE — mesmo padrão, ajustando para WITH CHECK quando aplicável
```

> Sempre usar funções helper (`is_super_admin()`, `current_tenant_id()`, `my_permission()`, etc.) — **nunca** ler `auth.jwt() ->> 'claim'` direto nas policies.

---

## 🤖 Agentes — Subagentes Claude Code

Os agentes especialistas vivem em `.claude/agents/<nome>.md` e são **invocáveis** pelo Claude Code via `Agent(subagent_type="<nome>")`. Cada agente tem frontmatter (`name`, `description`, `tools`) e um system prompt no body. A `description` é action-oriented — o Claude principal lê isso para decidir quando delegar.

### Como usar nas SPECs

Use `@nome-do-agente` como label nas SPECs para indicar quem revisou ou implementou cada parte. Ao trabalhar numa SPEC, o Claude pode efetivamente delegar ao subagente correspondente.

### Agentes padrão

#### Implementadores (com Edit/Write)

| Agente | Domínio |
|---|---|
| `@backend-specialist` | API / Services / Server actions / Webhooks |
| `@frontend-specialist` | UI/UX / React / Tailwind / Design system |
| `@database-architect` | Schema / RLS / Migrations / SQL |
| `@devops-engineer` | CI/CD / Docker / Deploy |
| `@test-engineer` | Testes unit/integração / TDD |
| `@qa-automation-engineer` | Testes E2E / Playwright / Cypress |
| `@documentation-writer` | READMEs, manuais, API docs (sob pedido explícito) |
| `@product-manager` | PRDs, user stories, acceptance criteria |
| `@product-owner` | MVP scope, backlog, trade-offs |
| `@mobile-developer` | iOS/Android/React Native |
| `@seo-specialist` | Meta tags, structured data |

#### Analistas (read-only — reportam achados)

| Agente | Domínio |
|---|---|
| `@security-auditor` | Auditoria de segurança, OWASP, RLS, supply chain |
| `@debugger` | Root-cause analysis, runtime errors |
| `@performance-optimizer` | Bundle, queries lentas, Web Vitals |
| `@project-planner` | Discovery, breakdown, planejamento de specs |
| `@code-archaeologist` | Legacy code, refactor planning |
| `@explorer-agent` | Mapeamento de codebase, "onde está X?" |
| `@penetration-tester` | Offensive security autorizada |

#### Coordenador

| Agente | Domínio |
|---|---|
| `@orchestrator` | Coordenação multi-domínio, features full-stack |

---

## 📋 Slash Commands

Os slash commands vivem em `.claude/commands/<nome>.md` (formato Claude Code nativo). Cada arquivo tem `description:` no frontmatter e usa `$ARGUMENTS` para receber argumentos. Invoque digitando `/<nome> <args>` no chat.

| Comando | Quando usar |
|---|---|
| `/spec` | Criar a SPEC de uma feature nova (spec-driven — documentar antes de codar) |
| `/adr` | Registrar uma decisão arquitetural (ADR-NNN) |
| `/orchestrate` | Feature complexa multi-domínio (padrão para projetos full-stack) |
| `/create` | Feature simples, 1 domínio |
| `/plan` | Requisitos vagos, incerteza técnica |
| `/enhance` | Melhoria em código existente |
| `/debug` | Bug com comportamento inesperado |
| `/test` | Gerar ou rodar testes |
| `/deploy` | Preparar e executar deploy |
| `/brainstorm` | Brainstorm de ideias antes de definir escopo |
| `/preview` | Subir preview local automático |
| `/status` | Status atual do projeto/sessão |
| `/ui-ux-pro-max` | Workflow especializado de UI/UX |

---

## 🧩 Skills

Os skills vivem em `.claude/skills/<nome>/SKILL.md` (formato Claude Code nativo). Cada skill é uma cápsula de conhecimento carregada sob demanda quando relevante. Skills com scripts auxiliares têm subpasta `scripts/`.

Categorias principais: linguagens (`python-patterns`, `nodejs-best-practices`, `rust-pro`), frameworks (`nextjs-react-expert`, `tailwind-patterns`), domínios (`api-patterns`, `database-design`, `frontend-design`, `mobile-design`, `game-development`), processo (`tdd-workflow`, `clean-code`, `code-review-checklist`, `systematic-debugging`), validadores com scripts (`vulnerability-scanner`, `lint-and-validate`, `webapp-testing`, `performance-profiling`, `seo-fundamentals`).

---

## 🧪 Validation Scripts

`.claude/scripts/checklist.py` orquestra os scripts de validação dos skills em ordem de prioridade (security → lint → schema → tests → UX → SEO). Rodar antes de commit/PR:

```bash
PYTHONIOENCODING=utf-8 python .claude/scripts/checklist.py .
```

---

## 📁 Documentação (`docs/`)

A base de conhecimento segue esta estrutura padrão dentro de `docs/`:

```
README.md              → Índice (mapa de conteúdo) — atualizar sempre
00_Meta/               → Templates, .env.local.example
00_Meta/AGENT_FLOW.md  → Referência rápida dos agentes/workflows do projeto
01_Architecture/       → ADRs (decisões arquiteturais)
02_Specs/              → Feature specs (.md), guias
02_Specs/Migrations/   → Docs (.md) das migrations — SEM .sql (a fonte de verdade dos SQL é o repo)
02_Specs/Modules/      → Mapeamento por módulo (.md) — UM arquivo por módulo, nunca um único compilado
03_Sprint_Logs/        → Diários de sprint
04_Assets/             → Imagens, diagramas exportados
```

### Specs implementadas

| Spec | Status | O que implementou |
|---|---|---|
| `<SPEC-NNN>` | `<rascunho/em-progresso/concluída>` | `<descrição>` |

### ADRs registrados

| ADR | Decisão |
|---|---|
| `<ADR-NNN>` | `<decisão>` |

---

## 🧩 Mapeamento & Documentação — Segregação por Módulo

Estas regras valem para **qualquer mapeamento** do projeto — funcionalidades, entidades/tabelas, fluxos, permissões, regras de negócio ou snapshot do estado atual. Segui-las é obrigatório ao gerar ou atualizar documentação de mapeamento.

### Regra 1 — Um arquivo por módulo (nunca um único arquivo compilado)

- O mapeamento é **segregado por módulo/domínio**: **um** arquivo `.md` por módulo em `docs/02_Specs/Modules/` (padrão de nome: `Module-<nome>.md`).
- Cada arquivo cobre as funcionalidades, entidades e regras **daquele** módulo — e só dele.
- **Nunca** gere um único arquivo "compilado" com todos os módulos juntos (ex.: um `Funcionalidades.md` ou `Current-State-Snapshot.md` monolítico). Se o projeto tem 8 módulos, o mapeamento são 8 arquivos, não 1.
- O `docs/README.md` (índice) lista **um link por módulo**.

### Regra 2 — Conteúdo volumoso vai para `.claude/context/`, não para o `CLAUDE.md`

- Resumos, índices e mapeamentos de acesso rápido vivem nos arquivos de `.claude/context/` (importados sob demanda via `@`) — **não** cole esse conteúdo dentro do `CLAUDE.md`. O `CLAUDE.md` é índice, não depósito; mantenha-o enxuto.
- Roteie cada tipo para o arquivo de contexto certo:
  - índice de SPECs/ADRs/tabelas/páginas/edge functions → `@.claude/context/specs-adrs-pages.md`
  - regras de negócio por módulo → `@.claude/context/business-rules.md`
  - resumo das migrations → `@.claude/context/migrations.md`
- Ao criar um mapeamento novo, **registre a referência no arquivo de contexto correspondente** (e adicione o `@import` no CLAUDE.md apenas se for um arquivo de contexto novo). O detalhe fica em `docs/02_Specs/Modules/`; o contexto guarda o índice que aponta para lá.

---

## 🖥️ Páginas do Dashboard

| Rota | Página | Perfis com acesso |
|---|---|---|
| `<rota>` | `<nome>` | `<perfis>` |

---

## 🔌 Edge Functions

| Função | Path | Descrição |
|---|---|---|
| `<nome>` | `<path>` | `<descrição>` |

---

## 🚀 Deploy e Versionamento

Documentação completa em `docs/02_Specs/Deploy-Guide.md`.

| Item | Valor |
|---|---|
| Hospedagem | `<HOSPEDAGEM>` |
| Branch produção | `main` |
| Deploy | `<gatilho_de_deploy>` |
| Versionamento | Semantic Versioning (`npm version patch/minor/major`) |
| Migrations | Aplicar no banco ANTES do deploy do código |

### CI (GitHub Actions)

| Job | O que roda | Requer banco? |
|---|---|---|
| Lint & Type Check | `type-check` + `lint` | Não |
| Unit Tests | `npm test` | Não |
| Security Audit | `npm audit --audit-level=high` | Não |
| Integration Tests | `npm run test:integration` | Sim (skip se variável de ambiente do banco não estiver configurada) |

### Checklist rápido de deploy

1. `npm run type-check` + `npm run lint` + `npm test` + `npm run test:integration`
2. Aplicar migrations no banco de produção (se houver)
3. `npm version minor` (ou patch/major)
4. `git push && git push --tags`
5. Pipeline de deploy dispara automaticamente

---

## ⚙️ Variáveis de Ambiente

```bash
# Preencher com as variáveis reais do projeto.
# Manter um .env.local.example no repo, com chaves e valores fake/placeholder.
```

> `.env.local` nunca deve ser commitado. Está no `.gitignore`.

---

## ✅ Checklist antes de qualquer implementação

- [ ] Ler a Spec correspondente em `02_Specs/`
- [ ] Verificar o ADR relacionado em `01_Architecture/`
- [ ] **Criar documentação em `docs/` ANTES de implementar** (SPEC + ADR + Migration doc)
- [ ] Confirmar número da próxima migration
- [ ] Incluir referências a `@security-auditor`, `@test-engineer` e `@qa-automation-engineer`
- [ ] Nomear tabelas/colunas em inglês
- [ ] Habilitar RLS na tabela nova
- [ ] Testar isolamento multi-tenant após implementar (se aplicável)
- [ ] Verificar que `super_admin` não é bloqueado por RLS
- [ ] Atualizar `docs/` (`docs/README.md` + Spec correspondente) ao concluir
- [ ] Cadastrar features na tabela `features` (code_read, code_write, code_delete) — se o projeto usa sistema de permissões
- [ ] Implementar paginação server-side em toda listagem (`.range()` + `count: 'exact'`)

---

## 📄 Paginação Server-Side — Obrigatória

Toda listagem de dados no frontend **deve** usar paginação server-side. Nunca carregar todos os registros de uma vez.

### Padrão obrigatório

- Usar `.range(from, to)` do Supabase (ou equivalente) para paginar no banco
- Parâmetros de paginação via `searchParams`: `?page=1&pageSize=20`
- Componente de paginação (anterior/próximo + indicador de página)
- Page size padrão: **20 itens** por página
- Retornar `count` total para calcular número de páginas

### Exemplo de service com paginação

```typescript
export async function getPaginated(supabase: Client, tenantId: string, page = 1, pageSize = 20) {
  const from = (page - 1) * pageSize
  const to = from + pageSize - 1

  const { data, error, count } = await supabase
    .from('tabela')
    .select('*', { count: 'exact' })
    .eq('tenant_id', tenantId)
    .order('created_at', { ascending: false })
    .range(from, to)

  if (error) throw new Error(error.message)
  return { data, total: count ?? 0, page, pageSize }
}
```

### Tabelas que DEVEM ter paginação

Todas as listagens do dashboard. Regra geral: se exibe lista de registros, pagina no servidor. Sem exceções.

---

## ⏳ Loading States — Padrão Obrigatório

Toda página do dashboard **deve** ter feedback visual durante carregamento.

### 3 camadas de loading

| Camada | Componente | Quando |
|---|---|---|
| **NavProgress** | Barra animada no topo | Ao clicar em link do sidebar |
| **loading.tsx** | Skeleton screen por rota | Enquanto server component carrega |
| **isPending** | Texto "Saving..." nos botões | Durante server actions |

### Regra

> Toda nova página **deve** ter um `loading.tsx` no diretório da rota. Usar skeletons compartilhados do design system.

---

## 🔁 Boas Práticas de Desenvolvimento

- **Sempre reaproveitar código existente.** Antes de criar algo novo, verificar se já existe um componente, função ou módulo que resolve o problema — reutilizar e adaptar quando possível.
- **Extrair componentes reutilizáveis.** Quando uma lógica ou UI se repete (ou tem potencial de repetição), isolar em um componente, hook ou utilitário próprio.
- **DRY (Don't Repeat Yourself).** Duplicação de código é débito técnico. Se a mesma lógica aparece em dois lugares, extrair para um local compartilhado.
- **Composição sobre repetição.** Preferir componentes compostos e funções genéricas que aceitem props/parâmetros, em vez de copiar e colar variações.
- **Separação de responsabilidades.** Cada componente/módulo deve ter uma única responsabilidade clara. Componentes de UI não devem conter lógica de negócio; lógica de acesso a dados deve ficar em services/hooks dedicados.
- **Nomear de forma descritiva.** Componentes, funções e variáveis devem ter nomes que expliquem o que fazem — evitar abreviações ambíguas.

---

## 🚫 Proibições

- **Nunca** remover RLS de tabelas existentes
- **Nunca** usar `SERIAL`/`INTEGER` como PK — só `UUID`
- **Nunca** concatenar SQL dinamicamente (SQL injection)
- **Nunca** commitar `.env.local` ou chaves secretas
- **Nunca** implementar sem documentar antes em `docs/`
- **Nunca** referenciar agentes sem o prefixo `@` (ex: usar `@database-architect`, não apenas `database-architect`)
- **Nunca** criar listagem sem paginação server-side (usar `.range()` do Supabase ou equivalente)
- **Nunca** implementar nova funcionalidade sem cadastrar as features correspondentes na tabela `features` (se o projeto usa sistema de permissões)
- **Nunca** expor UUIDs, codes ou dados internos em URLs do navegador — usar estado client-side para seleção
- **Nunca** executar exclusão sem confirmação visual do usuário via modal
- **Nunca** pular o `@orchestrator` em feature nova
- **Nunca** gerar mapeamento (funcionalidades/entidades/regras) em um único arquivo compilado — sempre **um arquivo por módulo** em `docs/02_Specs/Modules/`
- **Nunca** despejar mapeamentos/índices volumosos no `CLAUDE.md` — esse conteúdo vai para `.claude/context/*.md` (import `@`), mantendo o `CLAUDE.md` enxuto
