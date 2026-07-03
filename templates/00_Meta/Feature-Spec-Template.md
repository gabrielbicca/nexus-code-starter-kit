# SPEC-NNN — <título da feature>

| Campo | Valor |
|---|---|
| Status | `<rascunho / em-progresso / concluída / arquivada>` |
| Autor | `<nome>` |
| Data | `<YYYY-MM-DD>` |
| ADRs relacionados | `<ADR-NNN ou —>` |
| Plano de execução | `<PLAN-slug ou —>` |
| Migrations | `<Migration-NNN ou —>` |

> **Spec-driven:** esta SPEC é escrita **antes** da implementação. Nenhum código nasce sem a SPEC correspondente. Atualize o `Status` e marque os checkboxes conforme avança.
>
> **SPEC × PLAN (não confundir):**
> - A **SPEC** (este arquivo) é o **contrato**: *o quê* e *por quê*, critérios de aceite, escopo, segurança e plano de testes.
> - O **PLAN** (`PLAN-<slug>.md`, criado via `/plan`) é a **execução**: a quebra detalhada de tarefas, dependências e ordem. A SPEC descreve o destino; o PLAN, o caminho.

---

## 1. Problema / Contexto

<Que necessidade esta feature atende? Para quem? Por que agora? Escreva o suficiente para alguém entender sem contexto prévio.>

## 2. Objetivo

<Resultado esperado em 1-2 frases.>

### Critérios de aceite

> Cada critério é **verificável** e, idealmente, tem um teste que o cobre (ver seção 6). Uma SPEC só vira `concluída` quando **todos** estiverem marcados.

- [ ] <critério verificável>
- [ ] <critério verificável>

## 3. Escopo

**Dentro**
- <o que será feito>

**Fora (explicitamente)**
- <o que NÃO será feito nesta SPEC>

## 4. Esboço técnico (alto nível)

> Visão geral suficiente para decidir e estimar. **O detalhamento (tarefas, arquivos, ordem) vai no PLAN**, não aqui — evite duplicar.

### Dados / Banco
- Entidades/tabelas afetadas e relações principais.
- Migration prevista: `<Migration-NNN>` (documentar em `02_Specs/Migrations/`).

### Backend
- Serviços / endpoints / ações afetados. Validação de entrada. Paginação em listagens.

### Frontend
- Páginas/rotas/componentes principais; estados de carregamento; i18n se aplicável.

## 5. Segurança / Autorização

- Quem pode ler/escrever o quê (autorização por perfil/papel).
- Dados sensíveis e tratamento (PII, segredos, logs).

<details>
<summary><strong>Opcional — Postgres/Supabase com RLS</strong> (remova se o projeto não usa RLS)</summary>

- Policies necessárias por operação (SELECT/INSERT/UPDATE/DELETE).
- Habilitar RLS em toda tabela nova.
- Usar os helpers do projeto (ex.: `is_super_admin()`, `current_tenant_id()`) — nunca ler `auth.jwt()` direto.
- Garantir isolamento multi-tenant e que o `super_admin` não seja bloqueado.

</details>

## 6. Plano de testes (obrigatório)

> **Regra do kit:** todo desenvolvimento novo tem testes implementados na camada de testes — **toda funcionalidade/critério de aceite da seção 2 precisa estar mapeado em pelo menos um teste**. Ligue cada item a um critério da seção 2. A SPEC **não** pode virar `concluída` com itens pendentes aqui (o `spec_drift.py` acusa erro).

- [ ] Unit: <o quê> — cobre critério(s) <n>
- [ ] Integração: <o quê> (ex.: autorização / isolamento de dados) — cobre critério(s) <n>
- [ ] E2E (fluxo crítico): <o quê> — cobre critério(s) <n>

## 7. Gate de qualidade (obrigatório — regra do kit)

> Estes itens são **bloqueantes**: o validador `spec_drift.py` acusa **erro** se a SPEC for marcada `concluída` sem eles marcados. Marque somente quando de fato executados.

- [ ] **Testes implementados** — todas as funcionalidades desta SPEC estão mapeadas em testes na camada de testes (via `@test-engineer` e, para E2E, `@qa-automation-engineer`)
- [ ] **Review de segurança executado** — `@security-auditor` revisou a implementação e os apontamentos foram tratados
- [ ] **Verificação executada com evidência** — `/verify` (ou a suíte de testes) rodou **após** a implementação e a **saída real** (testes passando, drift limpo) foi registrada nesta SPEC ou no PR — "deve funcionar" não é evidência

## 8. Agentes envolvidos

<ex.: `@database-architect` (schema), `@backend-specialist` (services), `@frontend-specialist` (UI)>

> Obrigatórios em **todo** desenvolvimento novo (regra do kit): `@test-engineer` (testes) e `@security-auditor` (review de segurança).

## 9. Rastreabilidade

> Preencha **Arquivos de código** assim que a implementação começar — é o elo SPEC↔código que o validador `spec_drift.py` espera ver numa SPEC `em-progresso`/`concluída`.

| Artefato | Referência |
|---|---|
| Plano de execução | `02_Specs/PLAN-<slug>.md` |
| ADRs | `01_Architecture/ADR-NNN-*.md` |
| Migrations | `02_Specs/Migrations/Migration-NNN-*.md` |
| Arquivos de código | `<caminhos principais — preencher durante a implementação>` |

## 10. Notas / decisões em aberto

- <questões a resolver, suposições assumidas>
