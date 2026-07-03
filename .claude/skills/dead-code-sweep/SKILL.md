---
name: dead-code-sweep
description: Varredura completa do repositório em busca de débito técnico e código morto — componentes nunca renderizados, funções/exports nunca chamados, imports órfãos, variáveis nunca lidas e código comentado sem contexto ("código zumbi"). Define o protocolo canônico, o ferramental por ecossistema e o formato do relatório (Diagnóstico Global + Plano de Refatoração em checklist). Use periodicamente (fim de sprint, pré-release), antes de refatorações grandes, ou quando o @clean-code-auditor for invocado.
allowed-tools: Read, Grep, Glob, Bash
---

# Dead Code Sweep — Varredura de Débito Técnico

> Código morto custa leitura, esconde bugs e mente sobre o sistema. Esta skill define **como** varrer e **como** reportar.

---

## O protocolo canônico

Faça uma varredura completa em **todos** os diretórios e arquivos do projeto para identificar débito técnico, código morto e inconsistências, focando estritamente em:

1. **Componentes, classes ou módulos** criados, mas que nunca são instanciados ou renderizados em nenhum lugar do sistema.
2. **Funções e métodos** declarados (inclusive os **exportados**), mas que nunca são chamados ou importados por nenhum outro arquivo da aplicação.
3. **Importações órfãs** — bibliotecas, pacotes ou módulos locais importados mas não utilizados no arquivo onde foram declarados.
4. **Variáveis** (globais, locais ou de estado) que nunca sofrem mutação ou cujos valores nunca são lidos.
5. **Código zumbi** — blocos de código comentados que não possuem explicação de contexto.

---

## Ferramental por ecossistema (rode o que existir)

| Ecossistema | Detector | O que pega |
|---|---|---|
| JS/TS | `npx knip` | exports, arquivos e dependências não usados (o mais completo) |
| JS/TS | `npx ts-prune` | exports TS nunca importados |
| JS/TS | `npx depcheck` | dependências do package.json não usadas |
| JS/TS | ESLint `no-unused-vars` | variáveis/imports não usados por arquivo |
| Python | `vulture .` | funções, classes e variáveis mortas |
| Python | `ruff check --select F401,F841` | imports órfãos e variáveis não lidas |
| .NET/C# | `dotnet build` + analyzers (CA1801, IDE0051, IDE0060) | membros privados/parâmetros não usados |
| Qualquer | Grep cruzado | fallback: procure o símbolo em todo o repo — zero ocorrências além da declaração = candidato |

> Sem ferramenta disponível? Grep cruzado resolve: `Grep "<símbolo>"` no repo inteiro; declaração sem nenhum uso é candidato.

---

## Cuidado com falsos positivos (obrigatório)

Antes de reportar um candidato como morto, cheque **uso dinâmico**:

- Imports construídos por string / lazy loading / `import()` dinâmico
- Reflexão, injeção de dependência, service locators
- Convenções de framework (rotas por arquivo no Next.js, handlers registrados por nome, hooks de CMS, migrations)
- Entry points públicos de biblioteca (o consumidor está fora do repo)
- Testes, fixtures e seeds que referenciam por string

**Classifique cada achado**: `confirmado` (cross-check feito, nenhum uso dinâmico plausível) ou `suspeito` (pode ter uso dinâmico — vira tarefa de verificação, não de remoção).

---

## Formato do relatório (sempre este, em pt-BR)

### Passo 1 — Diagnóstico Global

Liste os problemas **agrupados por diretório/arquivo**. Para cada item: o arquivo, a função/variável/componente afetado, a categoria (1–5), a confiança (`confirmado`/`suspeito`) e a **ação sugerida**.

```markdown
## Diagnóstico Global

### src/components/
| Arquivo | Símbolo | Categoria | Confiança | Ação sugerida |
|---|---|---|---|---|
| LegacyBanner.tsx | `LegacyBanner` | 1 — componente nunca renderizado | confirmado | Remover arquivo |
| UserCard.tsx | `formatBadge()` | 2 — função exportada nunca importada | suspeito | Verificar uso dinâmico e remover |
```

### Passo 2 — Plano de Refatoração

Um **backlog priorizado** em checklist Markdown, com tarefas e subtarefas, ordenado por prioridade (risco × ganho). Remoções `confirmado` de risco zero primeiro; itens `suspeito` entram como tarefa de verificação.

```markdown
## Plano de Refatoração

### Prioridade 1 — remoções seguras (confirmado, risco zero)
- [ ] Remover componentes nunca renderizados
  - [ ] `src/components/LegacyBanner.tsx`
- [ ] Limpar imports órfãos (rodar fix automático do lint)

### Prioridade 2 — verificação antes de remover (suspeito)
- [ ] Confirmar se `formatBadge()` tem uso dinâmico; se não, remover

### Prioridade 3 — código zumbi e variáveis mortas
- [ ] Apagar blocos comentados sem contexto em `src/services/`
```

---

## Regras do kit

1. **A varredura é read-only** — o relatório não apaga nada. A execução do backlog segue o fluxo normal do kit (refactor multi-arquivo → `@orchestrator`), com o **Gate de qualidade** (testes + review de segurança + verificação com evidência).
2. **Cadência**: rode periodicamente — fim de sprint ou pré-release — não só quando doer. O `/status` lembra quando a varredura está atrasada.
3. **Evidência**: cada achado aponta a evidência (saída do detector ou resultado do grep). Achado sem evidência não entra no relatório.
