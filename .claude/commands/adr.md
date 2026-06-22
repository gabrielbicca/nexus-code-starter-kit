---
description: Cria um novo Architecture Decision Record numerado (ADR-NNN) em docs/01_Architecture/ a partir do template, com numeração automática. Registra uma decisão arquitetural e o porquê dela.
---

# /adr — Architecture Decision Record

$ARGUMENTS

---

## 🔴 Regras

1. **Registra decisão, não implementa.**
2. **Numeração automática** — próximo `NNN` livre em `docs/01_Architecture/`.
3. **Use o template** `docs/00_Meta/ADR-Template.md`.
4. **ADRs são imutáveis.** Para reverter uma decisão, crie um novo ADR que substitui o anterior (marque o antigo como `Substituída por ADR-NNN`).

---

## Passos

1. **Próximo número** — maior `ADR-NNN` em `docs/01_Architecture/` + 1 (senão `001`), 3 dígitos.
2. **Slug** a partir de `$ARGUMENTS` (minúsculas, hífens, sem acentos, máx ~40 chars).
3. **Criar `docs/01_Architecture/ADR-NNN-<slug>.md`** a partir de `docs/00_Meta/ADR-Template.md`:
   - Cabeçalho `# ADR-NNN — <título>`, `Status: Proposta`, `Data: <hoje>`.
   - Preencha **Contexto** e **Decisão** a partir de `$ARGUMENTS`; deixe alternativas/consequências como placeholders.
   - Se o template não existir, use a estrutura mínima: Contexto, Decisão, Alternativas consideradas, Consequências, Relacionados.
4. **Atualizar o índice `docs/README.md`** — tabela **## ADRs**: `| ADR-NNN | <decisão> |` (remova o placeholder se ainda existir).

---

## Saída

```
[OK] ADR criado: docs/01_Architecture/ADR-NNN-<slug>.md
```

---

## Uso

```
/adr usar Postgres em vez de MongoDB
/adr autenticação via JWT padrão sem custom hook
/adr multi-tenancy por tenant_id + RLS
```
