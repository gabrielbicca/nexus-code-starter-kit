# Contribuindo com o Nexus Code Starter Kit

Obrigado pelo interesse em contribuir. Este kit existe para acelerar a configuração do Claude Code em projetos novos ou existentes — toda contribuição que mantenha esse foco é bem-vinda.

---

## O que aceitamos

- **Novos agentes** em `.claude/agents/` — desde que cubram um domínio bem definido (não sobreposto a agentes existentes) e sigam o padrão de frontmatter.
- **Skills novas** em `.claude/skills/<nome>/SKILL.md` — pacotes auto-contidos com frontmatter (`name`, `description`).
- **Slash commands** em `.claude/commands/` — para fluxos repetitivos.
- **Correções** em docs, tabelas do `orchestrator.md`, ou no `bin/cli.js`.
- **Workflows de CI** ou validações que aumentem a robustez do kit.

## O que NÃO aceitamos

- **Conteúdo que dependa de plugins externos do Claude Code.** O kit precisa ser auto-contido — quem instala via `npx nexus-code-starter-kit` recebe um produto consistente.
- **Agentes excessivamente verbosos** sem necessidade (referência: mediana ~225 linhas, teto ~600).
- **Mudanças no comportamento da CLI** sem atualização do `--help` correspondente.

---

## Antes de abrir um PR

1. **Rode o drift guard:** `npm test`
   - Garante que `orchestrator.md` e `README.md` estão em sincronia com o filesystem.
2. **Rode o syntax check:** `node -c bin/cli.js`
3. **Rode o pack dry-run:** `npm publish --dry-run`
   - Para conferir que nenhum artefato indesejado vazaria para o npm.
4. **Atualize o CHANGELOG.md** na seção apropriada (1 entrada por PR, no formato Keep a Changelog).

---

## Convenções

- **Frontmatter dos agentes:** `name`, `description`, `tools` (lista CSV) — obrigatórios.
- **Frontmatter das skills:** `name`, `description` — obrigatórios.
- **Triggers no `description`:** evite termos genéricos (`workflow`, `node`, `trigger`) — prefixe com o domínio (ex.: `n8n workflow`).
- **Tabelas no `orchestrator.md`:** todo agente em `.claude/agents/*.md` precisa aparecer em "Available Agents" E em "Agent Boundary Enforcement". O drift guard valida isso automaticamente.
- **Commits:** estilo livre, mas prefira `feat:`/`fix:`/`chore:` quando for óbvio.

---

## Releases

Mantenedor (`@gabrielbicca`) faz os releases. Fluxo:

```bash
# 1. CHANGELOG + bump em package.json
# 2. Commit + tag anotada
git tag -a v1.x.y -m "v1.x.y — descrição"
# 3. Push da branch e da tag (CI publica via NPM_TOKEN secret)
git push origin main && git push origin v1.x.y
```

Em caso de dúvida sobre versionamento (patch / minor / major), seguimos SemVer:

- **patch** — só correções de bugs, sem mudança visível para o usuário do kit
- **minor** — adições não-breaking (novo agente, nova skill, nova flag do CLI)
- **major** — quebra de compatibilidade (renomear/remover agente, mudar fluxo do CLI)

---

## Dúvidas?

Abra uma issue antes de investir tempo num PR grande — vale a pena alinhar primeiro.
