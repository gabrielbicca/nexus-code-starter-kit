---
description: Cria uma nova feature spec numerada (SPEC-NNN) em docs/02_Specs/ a partir do template, com numeração automática. Spec-driven — a documentação vem antes do código. Use ao iniciar qualquer feature nova.
---

# /spec — Nova Feature Spec (spec-driven)

$ARGUMENTS

---

## 🔴 Regras

1. **Documentação, não código.** Este command só cria/atualiza a SPEC. Não implemente nada aqui.
2. **Numeração automática.** Descubra o próximo `NNN` livre antes de criar.
3. **Use o template.** A SPEC nasce de `docs/00_Meta/Feature-Spec-Template.md`.
4. **Registre no índice.** Atualize a tabela de Specs em `docs/README.md`.

---

## Passos

1. **Calcular o próximo número**
   - Liste `docs/02_Specs/SPEC-*.md`, pegue o maior `NNN` e some 1. Se não houver nenhuma, comece em `001`.
   - Formato: 3 dígitos com zero à esquerda (`001`, `012`, `100`).

2. **Gerar o slug**
   - A partir de `$ARGUMENTS`: minúsculas, hífens, sem acentos, máx ~40 chars.
   - Ex.: "carrinho de compras" → `carrinho-compras`.

3. **Criar `docs/02_Specs/SPEC-NNN-<slug>.md`**
   - Copie o conteúdo de `docs/00_Meta/Feature-Spec-Template.md`.
   - Cabeçalho: `# SPEC-NNN — <título>` (título derivado de `$ARGUMENTS`).
   - Preencha `Status: rascunho`, `Data: <hoje>` e a seção **1. Problema / Contexto** com um resumo de `$ARGUMENTS`.
   - Mantenha as demais seções como placeholders do template para o time preencher.
   - Se o template não existir, crie a SPEC com a estrutura mínima: Problema, Objetivo, Escopo, Design técnico (db/backend/frontend), Segurança/RLS, Plano de testes, Agentes, Rastreabilidade.

4. **Atualizar o índice `docs/README.md`**
   - Adicione uma linha na tabela **## Specs**: `| SPEC-NNN | rascunho | <título> |` (remova a linha placeholder `_(adicione aqui)_` se ainda existir).

5. **Socratic gate (se necessário)**
   - Se `$ARGUMENTS` estiver vago, faça 1-3 perguntas de esclarecimento ANTES de escrever a SPEC.

---

## Saída

```
[OK] SPEC criada: docs/02_Specs/SPEC-NNN-<slug>.md

Próximos passos:
- Preencher objetivo, escopo e design técnico
- Preencher o Plano de testes: toda funcionalidade mapeada em teste (regra do kit)
- Se houver decisão arquitetural → /adr
- Implementar seguindo a ordem do docs/00_Meta/AGENT_FLOW.md
- Antes de concluir: Gate de qualidade — testes implementados + review do @security-auditor (obrigatórios)
```

---

## Uso

```
/spec autenticação de usuários com OTP
/spec catálogo de produtos com busca e filtros
/spec exportar relatório financeiro em PDF
```
