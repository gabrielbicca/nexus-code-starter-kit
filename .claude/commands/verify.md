---
description: Roda a verificação do projeto (qualidade + coerência spec-driven). Use durante o desenvolvimento (rápido) ou antes de um release (completo). Inclui sempre a checagem spec-drift.
---

# /verify — Verificação do projeto

$ARGUMENTS

---

## O que este command faz

Roda os validadores do kit e te entrega um relatório claro. Há dois níveis:

| Nível | Quando usar | Comando |
|---|---|---|
| **Rápido** | Durante o desenvolvimento, a cada feature | `python .claude/scripts/checklist.py .` |
| **Completo** | Antes de um release / deploy | `python .claude/scripts/verify_all.py .` |
| **Só spec-driven** | Conferir coerência da documentação | `python .claude/scripts/spec_drift.py .` |

> A verificação **spec-driven** (`spec_drift.py`) roda nos dois níveis: ela checa que specs ↔ migrations ↔ índice ↔ código continuam coerentes.

---

## Passos

1. **Escolha o nível** a partir de `$ARGUMENTS`:
   - vazio ou `rápido`/`quick` → `checklist.py`
   - `completo`/`full`/`release` → `verify_all.py`
   - `spec`/`drift` → `spec_drift.py`

2. **Detecte o servidor (opcional).** Se o usuário passar uma URL (ex.: `http://localhost:3000`) ou pedir performance/E2E, adicione `--url <URL>` ao `verify_all.py`. Sem URL, as checagens de performance e E2E são puladas automaticamente — o resto roda normal.

3. **Execute** o script escolhido com o Bash tool, no diretório do projeto:
   ```bash
   python .claude/scripts/checklist.py .
   # ou
   python .claude/scripts/verify_all.py . --url http://localhost:3000
   # ou
   python .claude/scripts/spec_drift.py .
   ```

4. **Resuma o resultado** para o usuário: o que passou, o que falhou e os próximos passos. Se houver checks pulados por "script ausente", diga isso explicitamente (não foram executados).

5. **Se houver falhas spec-driven**, oriente: criar a SPEC faltante (`/spec`), documentar a migration, marcar os critérios de aceite, ou preencher a rastreabilidade na SPEC.

6. **Se a falha for do Gate de qualidade** (regra do kit): a SPEC foi marcada `concluída` sem testes ou sem review de segurança. Oriente a rodar `@test-engineer` (implementar os testes que mapeiam toda funcionalidade da SPEC) e `@security-auditor` (review), e só então marcar os checkboxes do Gate.

---

## Uso

```
/verify
/verify completo
/verify completo http://localhost:3000
/verify spec
```
