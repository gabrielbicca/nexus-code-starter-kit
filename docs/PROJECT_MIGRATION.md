# 🔄 PROJECT MIGRATION — Guia Temporário

> Guia de referência para **migrar um projeto já existente** para o fluxo de trabalho padrão com Claude Code (vault + agentes + skills + CLAUDE.md).
> Este arquivo é **temporário** — use como checklist durante a migração e arquive/remova quando o projeto estiver totalmente onboarded.
>
> **Quando usar este guia:** você já tem um projeto com código-fonte escrito (pode ser legacy, MVP, ou qualquer estágio) e quer passar a trabalhar nele dentro do fluxo padrão documentação-primeiro + agentes Claude Code.
>
> **Quando NÃO usar:** projetos que estão sendo criados do zero — use `NEW_PROJECT_BOOTSTRAP.template.md` para isso.
>
> **Como usar este template:** copie este arquivo para a raiz do projeto que será migrado e execute o checklist de ponta a ponta.

---

## 🎯 Objetivo

Pegar um projeto que **já tem código rodando** e:

1. Introduzir a vault do Obsidian como cérebro externo (sem perder histórico)
2. Copiar os agentes/skills/commands padrão para `.claude/`
3. Gerar o `CLAUDE.md` refletindo o estado **atual** do projeto (não o ideal)
4. Fazer engenharia reversa de ADRs/SPECs/migrations a partir do código existente
5. Estabelecer o protocolo obrigatório (`@orchestrator`, documentação-primeiro) a partir da **próxima** feature — sem reescrever o que já existe

> **Princípio-chave:** migração é documentação do passado + disciplina para o futuro. Não é reescrever o projeto.

---

## 🗺️ Fases da Migração

A migração é dividida em **5 fases sequenciais**. Cada fase termina com um marco verificável.

```
Fase 1 — Discovery       → Entender o que já existe
Fase 2 — Scaffold        → Criar vault + .claude/ + CLAUDE.md inicial
Fase 3 — Reverse-Doc     → Documentar estado atual (ADRs + SPECs retroativas)
Fase 4 — Validation      → Rodar checklist.py, testes, lint
Fase 5 — Adoption        → Primeira feature nova no fluxo padrão
```

---

## 📋 Fase 1 — Discovery (entender o que já existe)

> **Nunca mexa em nada nesta fase.** Só leia, mapeie, pergunte.

### 1.1 Mapeamento do repo

- [ ] Abrir o repo e rodar `ls` / árvore de diretórios
- [ ] Identificar o **stack real** (ler `package.json`, `requirements.txt`, `Cargo.toml`, etc.)
- [ ] Identificar o **banco de dados** e onde estão as migrations (se existirem)
- [ ] Identificar o **sistema de auth** em uso
- [ ] Identificar a **estrutura de pastas do código** (`src/`, `app/`, `lib/`, etc.)
- [ ] Identificar **onde estão os testes** (ou se não existem)
- [ ] Identificar **pipelines de CI/CD** existentes (`.github/workflows/`, etc.)
- [ ] Identificar **arquivos de configuração de deploy** (Dockerfile, docker-compose, coolify, vercel.json, etc.)
- [ ] Identificar **READMEs, docs inline, comentários TODO/FIXME** relevantes

### 1.2 Inventário de convenções atuais

Antes de escrever o `CLAUDE.md`, é preciso saber o que o projeto **realmente faz hoje** — não o que deveria fazer. Responda para si:

- [ ] Tabelas/colunas estão em inglês ou português? snake_case ou camelCase?
- [ ] PKs são UUID, serial, ou misto?
- [ ] RLS está ligado em todas as tabelas, em algumas, ou em nenhuma?
- [ ] As migrations são numeradas sequencialmente? Qual é a próxima?
- [ ] Existe multi-tenancy? Como é implementado (coluna `tenant_id`? schema separado? nada?)
- [ ] Existe i18n? Qual biblioteca?
- [ ] Existe design system / component library próprio?
- [ ] Paginação — é server-side ou client-side?
- [ ] Loading states — tem padrão definido ou é ad-hoc?
- [ ] Versionamento — segue SemVer?

> **Registre cada resposta.** Elas viram seções do `CLAUDE.md` ou entradas na tabela de dívidas técnicas.

### 1.3 Identificar dívidas técnicas e divergências do padrão

Liste tudo que **difere do padrão** (PKs serial, RLS ausente, listagem sem paginação, SQL concatenado, etc.). Isso NÃO precisa ser corrigido agora — só precisa ser **documentado** como dívida conhecida. O plano de regularização vem depois, como SPECs numeradas.

Exemplo de dívidas comuns:

| Divergência | Impacto | Plano |
|---|---|---|
| Tabela `X` usa `SERIAL` como PK | Baixo | SPEC futura de migração para UUID |
| RLS desabilitado em `Y` | Alto | SPEC prioritária |
| Listagem `Z` carrega tudo sem paginação | Médio | SPEC de paginação |

---

## 📋 Fase 2 — Scaffold (criar estrutura padrão)

> Criação de arquivos novos. Nenhum arquivo existente é modificado.

### 2.1 Criar vault do Obsidian

- [ ] Criar pasta `<NOME_DA_VAULT>/` no diretório de vaults
- [ ] Criar `README.md` (MOC) apontando para as seções abaixo
- [ ] Criar subpastas:
  - `00_Meta/` — templates, AGENT_FLOW, .env.local.example
  - `01_Architecture/` — para os ADRs retroativos
  - `02_Specs/` — para as SPECs retroativas + guias
  - `02_Specs/Migrations/` — para docs das migrations existentes
  - `03_Sprint_Logs/` — em branco; começará a ser preenchida a partir da primeira sprint pós-migração
  - `04_Assets/` — imagens, diagramas
- [ ] Copiar templates em `00_Meta/`:
  - `ADR-Template.md`
  - `Feature-Spec-Template.md`
  - `Migration-Template.md`
  - `AGENT_FLOW.md`
- [ ] Configurar **MCP SSE do Obsidian** em uma porta dedicada para este projeto (não reusar portas de outros)
- [ ] Criar `02_Specs/Project-Scope.md` descrevendo em 1-2 páginas o escopo atual do projeto (o que ele faz hoje, para quem, principais módulos)

### 2.2 Copiar ferramental Claude Code

> O repo já existe, então estamos **adicionando** `.claude/` sem tocar no resto.

- [ ] Copiar `.claude/agents/` de um projeto-base já estabelecido
- [ ] Copiar `.claude/commands/` de um projeto-base já estabelecido
- [ ] Copiar `.claude/skills/` de um projeto-base já estabelecido
- [ ] Copiar `.claude/scripts/checklist.py` e validators
- [ ] Adicionar `.claude/` ao git (commitar como primeiro commit da migração)

### 2.3 Criar `CLAUDE.md` a partir do template

- [ ] Copiar `CLAUDE.template.md` para a raiz do repo como `CLAUDE.md`
- [ ] Preencher todos os placeholders `<...>` com os valores **reais** descobertos na Fase 1
- [ ] Na seção de convenções de banco, documentar o **estado atual** (ex.: "tabelas antigas usam SERIAL, novas usam UUID — ver SPEC-XXX para plano de migração")
- [ ] Listar as dívidas técnicas conhecidas como notas no CLAUDE.md, apontando para as SPECs de regularização (a criar)
- [ ] Na seção "Specs implementadas", deixar preparado o formato — será preenchido na Fase 3
- [ ] Na seção "Próxima migration disponível", colocar o próximo número livre (ex.: se já existem `001` até `012`, a próxima é `013`)

---

## 📋 Fase 3 — Reverse-Doc (documentar o estado atual)

> Engenharia reversa: para cada coisa relevante que **já existe no código**, crie a doc correspondente no vault.

### 3.1 ADRs retroativos

Para cada **decisão arquitetural importante** que já foi tomada e está viva no código, criar um ADR retroativo. Exemplos:

- [ ] `ADR-001-Core-Stack.md` — por que o stack atual foi escolhido (frontend, backend, banco, auth)
- [ ] `ADR-002-Multi-Tenancy.md` — como o multi-tenancy é implementado (se aplicável)
- [ ] `ADR-003-Auth-Strategy.md` — estratégia de autenticação e sessão
- [ ] `ADR-004-Deploy-Pipeline.md` — como o deploy funciona hoje
- [ ] `ADR-00N-<outras>` — qualquer decisão não trivial que alguém futuro precisaria entender

> Os ADRs retroativos **não precisam ser perfeitos**. Podem ser curtos. O importante é registrar: contexto, decisão, consequências. Marque com status `accepted-retroactive` para deixar claro que foram escritos depois.

### 3.2 SPECs retroativas (opcional mas recomendado)

Não é necessário criar SPEC para cada feature já existente — isso pode ser trabalho de meses. Foque em:

- [ ] `SPEC-001-Current-State-Snapshot.md` — visão geral do que já está implementado, por módulo
- [ ] SPECs para **módulos críticos** que vão receber manutenção em breve
- [ ] SPECs para as **dívidas técnicas identificadas na Fase 1** (uma SPEC por item a regularizar)

> A regra é: só documente retroativamente o que você vai **mexer ou precisar entender em profundidade**. O resto pode ficar no `Project-Scope.md` como descrição geral.

### 3.3 Docs das migrations existentes

- [ ] Para cada `.sql` em `supabase/migrations/` (ou equivalente), criar o `.md` correspondente em `02_Specs/Migrations/`
- [ ] Formato: `Migration-NNN-<nome-curto>.md` com descrição, o que foi alterado, dependências
- [ ] Se a migration é antiga e ninguém lembra o contexto, documentar o que dá para inferir do SQL — "arqueologia OK"

### 3.4 Atualizar o MOC do vault

- [ ] Adicionar ao `README.md` (MOC) links para os ADRs, SPECs e Migrations recém-criados
- [ ] Adicionar uma seção "Dívidas técnicas conhecidas" listando as divergências da Fase 1 com link para a SPEC de regularização

---

## 📋 Fase 4 — Validation (garantir que nada quebrou)

> A migração não pode introduzir regressões no código existente.

- [ ] Rodar `npm run type-check` (ou equivalente) — precisa passar
- [ ] Rodar `npm run lint` — precisa passar
- [ ] Rodar `npm test` — precisa passar (ou manter o mesmo estado anterior à migração)
- [ ] Rodar `npm run test:integration` se existir — precisa passar
- [ ] Rodar `.claude/scripts/checklist.py` na raiz do repo — revisar itens que falharem
- [ ] Verificar que a vault abre no Obsidian sem links quebrados
- [ ] Verificar que o Claude Code lê o `CLAUDE.md` sem erros
- [ ] Verificar que `git status` mostra apenas adições (vault + `.claude/` + `CLAUDE.md` + dívidas documentadas) — **nenhum arquivo de código existente deve ter sido modificado**
- [ ] Fazer um commit único com mensagem: `chore: onboarding to Claude Code workflow (vault + agents + CLAUDE.md)`

---

## 📋 Fase 5 — Adoption (primeira feature no fluxo padrão)

> A migração só está completa quando uma feature nova passou pelo fluxo do começo ao fim.

- [ ] Escolher uma feature pequena e bem definida (NÃO começar pela maior dívida técnica)
- [ ] Invocar `@orchestrator` — primeira feature com plano multi-domínio
- [ ] Seguir o fluxo: SPEC → ADR (se aplicável) → Migration doc (se aplicável) → código → testes → atualizar vault → atualizar `CLAUDE.md`
- [ ] Commit seguindo o padrão `feat: descrição (SPEC-NNN)`
- [ ] Revisar com o time o que funcionou e o que precisa ser ajustado no fluxo

> Depois desta feature, a migração está **concluída**. Este arquivo pode ser arquivado/removido.

---

## 🚫 Proibições Durante a Migração

- **Nunca** reescrever código existente "só porque está fora do padrão" durante a migração — isso é trabalho de SPECs futuras, não da migração em si
- **Nunca** remover RLS, migrations ou qualquer coisa que já está em produção
- **Nunca** renomear tabelas/colunas durante a migração — só **documentar** o estado atual
- **Nunca** commitar `.env.local` ou chaves que por acaso estejam no working dir
- **Nunca** pular a Fase 1 (Discovery) — ir direto para código é o erro mais comum
- **Nunca** prometer regularizar todas as dívidas "na próxima sprint" — documente, priorize, e trate como backlog

---

## ✅ Checklist Rápido (resumo)

```
Fase 1 — Discovery
  [ ] Mapeamento do repo e do stack
  [ ] Inventário de convenções atuais
  [ ] Lista de dívidas técnicas

Fase 2 — Scaffold
  [ ] Vault criado com estrutura padrão
  [ ] .claude/ copiado
  [ ] CLAUDE.md preenchido com estado ATUAL

Fase 3 — Reverse-Doc
  [ ] ADRs retroativos (decisões críticas)
  [ ] SPECs retroativas (módulos críticos + dívidas)
  [ ] Docs das migrations existentes
  [ ] MOC atualizado

Fase 4 — Validation
  [ ] Build, lint, testes passando
  [ ] checklist.py revisado
  [ ] Commit único de onboarding

Fase 5 — Adoption
  [ ] Primeira feature via @orchestrator
  [ ] Fluxo completo executado
  [ ] Retro e ajustes
```

---

## 🔁 Quando este arquivo deve ser removido

Este `PROJECT_MIGRATION.md` é **temporário**. Remova quando:

1. O vault está criado e atualizado regularmente
2. O `CLAUDE.md` reflete o estado atual do projeto
3. Pelo menos 1 feature nova passou pelo fluxo padrão (Fase 5 concluída)
4. O time sabe usar `@orchestrator`, SPECs e o protocolo de documentação-primeiro

A partir daí, o `CLAUDE.md` + o MOC do vault já carregam todo o contexto — este guia vira redundante.
