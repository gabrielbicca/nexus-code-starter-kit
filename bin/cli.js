#!/usr/bin/env node

// ============================================================
//  NEXUS CODE STARTER KIT — CLI
//  Uso: npx nexus-code-starter-kit
//  Repo: https://github.com/gabrielbicca/nexus-code-starter-kit
// ============================================================

const fs   = require("fs");
const path = require("path");
const readline = require("readline");

const KIT_DIR     = path.resolve(__dirname, "..");
const KIT_PKG     = require(path.join(KIT_DIR, "package.json"));
const KIT_VERSION = KIT_PKG.version;

// ---------- helpers ----------
const cyan    = (s) => `\x1b[36m${s}\x1b[0m`;
const yellow  = (s) => `\x1b[33m${s}\x1b[0m`;
const green   = (s) => `\x1b[32m${s}\x1b[0m`;
const magenta = (s) => `\x1b[35m${s}\x1b[0m`;
const gray    = (s) => `\x1b[90m${s}\x1b[0m`;
const bold    = (s) => `\x1b[1m${s}\x1b[0m`;

const header = (txt) => {
  console.log(`\n${cyan("============================================")}`);
  console.log(cyan(`  ${txt}`));
  console.log(`${cyan("============================================")}\n`);
};

const ok    = (s) => console.log(green(`  ✓ ${s}`));
const aviso = (s) => console.log(magenta(`  ! ${s}`));
const info  = (s) => console.log(gray(`  → ${s}`));

// ---------- argv parsing ----------
const argv = process.argv.slice(2);

if (argv.includes("--version") || argv.includes("-v")) {
  console.log(KIT_VERSION);
  process.exit(0);
}

if (argv.includes("--help") || argv.includes("-h")) {
  console.log(`
nexus-code-starter-kit v${KIT_VERSION}

Uso:
  npx nexus-code-starter-kit [opções]

Opções:
  -h, --help       Mostra esta ajuda
  -v, --version    Mostra a versão do kit

Fluxo interativo:
  1. Escolha o diretório do projeto.
  2. Se .claude/ já existe, oferece três opções:
       merge        → só adiciona arquivos novos (preserva existentes)
       sobrescrever → atualiza TODOS os agentes/skills/commands
       cancelar
  3. Opcionalmente gera CLAUDE.md (não toca se já existir).
  4. Cria a base de conhecimento em docs/ (núcleo spec-driven; preserva arquivos existentes).
  5. Grava .claude/.kit-version com a versão instalada.

Repo: https://github.com/gabrielbicca/nexus-code-starter-kit
`);
  process.exit(0);
}

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

const ask = (question, def = "") =>
  new Promise((resolve) => {
    const prompt = def ? `${question} ${gray(`[${def}]`)}: ` : `${question}: `;
    rl.question(prompt, (ans) => {
      resolve(ans.trim() || def);
    });
  });

const askSN = async (question, def = "S") => {
  const opts = def === "S" ? gray("[S/n]") : gray("[s/N]");
  const ans = await ask(`${question} ${opts}`);
  return (ans.toUpperCase() || def.toUpperCase()) === "S";
};

// ---------- copy directory recursively ----------
// Files/dirs that look like local-machine artifacts — never copy to target.
const SKIP_NAMES = new Set([
  "settings.local.json",
  ".kit-version",
  ".npmignore",
  "__pycache__",
  ".DS_Store",
  "Thumbs.db",
]);
const SKIP_EXTENSIONS = [".pyc", ".pyo", ".pyd"];

function shouldSkip(name) {
  if (SKIP_NAMES.has(name)) return true;
  return SKIP_EXTENSIONS.some((ext) => name.endsWith(ext));
}

function copyDir(src, dest, overwrite = false) {
  let written = 0;
  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    if (shouldSkip(entry.name)) continue;
    const srcPath  = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      if (!fs.existsSync(destPath)) fs.mkdirSync(destPath, { recursive: true });
      written += copyDir(srcPath, destPath, overwrite);
    } else {
      const exists = fs.existsSync(destPath);
      if (overwrite || !exists) {
        fs.mkdirSync(path.dirname(destPath), { recursive: true });
        fs.copyFileSync(srcPath, destPath);
        written++;
      }
    }
  }
  return written;
}

function countDir(dir, ext) {
  if (!fs.existsSync(dir)) return 0;
  return fs.readdirSync(dir).filter((f) => !ext || f.endsWith(ext)).length;
}

// ---------- version helpers ----------
function readInstalledVersion(destClaude) {
  const f = path.join(destClaude, ".kit-version");
  if (!fs.existsSync(f)) return null;
  try {
    const v = fs.readFileSync(f, "utf8").trim();
    return /^\d+\.\d+\.\d+/.test(v) ? v : null;
  } catch {
    return null;
  }
}

function compareVersions(a, b) {
  const pa = a.split(".").map((n) => parseInt(n, 10) || 0);
  const pb = b.split(".").map((n) => parseInt(n, 10) || 0);
  for (let i = 0; i < 3; i++) {
    if (pa[i] > pb[i]) return 1;
    if (pa[i] < pb[i]) return -1;
  }
  return 0;
}

function writeKitVersion(destClaude) {
  fs.writeFileSync(path.join(destClaude, ".kit-version"), KIT_VERSION + "\n", "utf8");
}

// ---------- Knowledge-base block for generated CLAUDE.md ----------
function blocoBaseConhecimento() {
  return `
---

## 🧠 Base de Conhecimento — Fonte de Verdade

A documentação em \`docs/\` é a **base de conhecimento** do projeto: a fonte de
verdade que sustenta cada decisão técnica. Trate-a como um documento vivo —
consulte antes de decidir e atualize após qualquer implementação.

### Estrutura de \`docs/\`

\`\`\`
📄 README.md              → Índice central (mapa da documentação)
📁 00_Meta/               → Templates e convenções
📁 01_Architecture/       → ADRs e diagramas
📁 02_Specs/              → Feature specs e guias
📁 02_Specs/Migrations/   → Docs (.md) das migrations
📁 03_Sprint_Logs/        → Diários de sprint
📁 04_Assets/             → Imagens e diagramas exportados
\`\`\`

> **Regra:** Antes de qualquer decisão técnica → consulte \`docs/\`.
> Antes de concluir qualquer implementação → atualize \`docs/\`.
`;
}

// ---------- knowledge-base skeleton (docs/) ----------
const DOCS_SUBDIRS = [
  "00_Meta",
  "01_Architecture",
  "02_Specs",
  path.join("02_Specs", "Migrations"),
  "03_Sprint_Logs",
  "04_Assets",
];

// Pasta-fonte dos templates do kit, copiada para docs/00_Meta do projeto.
const TEMPLATES_META_DIR = path.join(KIT_DIR, "templates", "00_Meta");

function docsReadmeIndex(nome) {
  return `# Base de Conhecimento — ${nome}

> Índice central (MOC) da documentação do projeto. Mantenha-o sempre atualizado.

Esta pasta é a **fonte de verdade** do projeto: consulte antes de decidir,
atualize após implementar.

## Estrutura

| Pasta | Conteúdo |
|---|---|
| \`00_Meta/\` | Templates, convenções, \`.env.local.example\` |
| \`01_Architecture/\` | ADRs (decisões arquiteturais) e diagramas |
| \`02_Specs/\` | Feature specs e guias |
| \`02_Specs/Migrations/\` | Docs (.md) das migrations — SEM \`.sql\` (fonte no repo) |
| \`03_Sprint_Logs/\` | Diários de sprint |
| \`04_Assets/\` | Imagens e diagramas exportados |

## Como criar artefatos

- Nova feature → \`/spec <descrição>\` (usa \`00_Meta/Feature-Spec-Template.md\`)
- Decisão arquitetural → \`/adr <decisão>\` (usa \`00_Meta/ADR-Template.md\`)
- Migration → documente em \`02_Specs/Migrations/\` a partir do \`Migration-Template.md\`

## Specs

| Spec | Status | O que implementou |
|---|---|---|
| _(adicione aqui)_ | | |

## ADRs

| ADR | Decisão |
|---|---|
| _(adicione aqui)_ | |
`;
}

function criarEsqueletoDocs(docsPath, nome) {
  fs.mkdirSync(docsPath, { recursive: true });
  for (const sub of DOCS_SUBDIRS) {
    const p = path.join(docsPath, sub);
    if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
  }

  // 00_Meta recebe os templates reais do kit (idempotente — preserva existentes)
  if (fs.existsSync(TEMPLATES_META_DIR)) {
    copyDir(TEMPLATES_META_DIR, path.join(docsPath, "00_Meta"), false);
  }

  // .gitkeep só nas pastas que podem nascer vazias (00_Meta já tem os templates)
  for (const sub of DOCS_SUBDIRS) {
    if (sub === "00_Meta") continue;
    const keep = path.join(docsPath, sub, ".gitkeep");
    if (!fs.existsSync(keep)) fs.writeFileSync(keep, "", "utf8");
  }

  const readmePath = path.join(docsPath, "README.md");
  if (!fs.existsSync(readmePath)) fs.writeFileSync(readmePath, docsReadmeIndex(nome), "utf8");
}

// ============================================================
async function main() {
  process.stdout.write("\x1Bc"); // clear
  header(`🚀 NEXUS CODE STARTER KIT v${KIT_VERSION}`);
  console.log("  Instala agentes, skills e commands do Claude Code");
  console.log("  no projeto que você escolher.\n");

  // ---------- destino ----------
  console.log(yellow("  Onde instalar o kit?"));
  console.log(gray(`  (Enter para a pasta atual: ${process.cwd()})\n`));

  let destino = await ask("  Caminho do projeto");
  if (!destino) destino = process.cwd();
  destino = path.resolve(destino);

  if (!fs.existsSync(destino)) {
    const criar = await askSN("  Pasta não existe. Criar?");
    if (!criar) { console.log("  Cancelado."); rl.close(); return; }
    fs.mkdirSync(destino, { recursive: true });
  }

  const destClaude = path.join(destino, ".claude");
  const jaTem      = fs.existsSync(destClaude);

  // ---------- decidir modo: install fresh / merge / overwrite ----------
  let overwrite = false;

  if (jaTem) {
    const installedVersion = readInstalledVersion(destClaude);

    if (installedVersion) {
      const cmp = compareVersions(KIT_VERSION, installedVersion);
      if (cmp > 0) {
        aviso(`Versão instalada: v${installedVersion}. Disponível: v${KIT_VERSION}.`);
      } else if (cmp === 0) {
        info(`.claude/ está em v${installedVersion} (já é a atual).`);
      } else {
        aviso(`Versão instalada (v${installedVersion}) é mais nova que o kit (v${KIT_VERSION}).`);
      }
    } else {
      aviso(".claude/ existe sem marcador de versão (provavelmente instalado em <1.5.0).");
    }

    console.log();
    console.log(`  ${bold("[m]")} Merge        — só adiciona arquivos novos, preserva existentes`);
    console.log(`  ${bold("[s]")} Sobrescrever — atualiza TODOS os agentes/skills/commands`);
    console.log(`  ${bold("[c]")} Cancelar`);
    console.log();
    const choice = (await ask("  Escolha", "m")).toLowerCase();

    if (choice === "c") {
      console.log("  Cancelado."); rl.close(); return;
    }
    if (!["m", "s"].includes(choice)) {
      console.log("  Opção inválida. Cancelado."); rl.close(); return;
    }

    if (choice === "s") {
      console.log();
      const confirmar = await askSN("  Confirma sobrescrever TODOS os arquivos do kit?", "N");
      if (!confirmar) { console.log("  Cancelado."); rl.close(); return; }
      overwrite = true;
    }
  }

  console.log();

  // ---------- copy .claude ----------
  const origemClaude = path.join(KIT_DIR, ".claude");

  if (!fs.existsSync(origemClaude)) {
    console.error(`\n  ERRO: pasta .claude não encontrada em ${origemClaude}`);
    rl.close(); process.exit(1);
  }

  if (!fs.existsSync(destClaude)) fs.mkdirSync(destClaude, { recursive: true });

  const written   = copyDir(origemClaude, destClaude, overwrite);
  const nAgents   = countDir(path.join(destClaude, "agents"));
  const nSkills   = countDir(path.join(destClaude, "skills"));
  const nCommands = countDir(path.join(destClaude, "commands"));

  if (!jaTem) {
    ok(".claude/ instalado");
  } else if (overwrite) {
    ok(`.claude/ sobrescrito (${written} arquivos atualizados)`);
  } else {
    ok(`.claude/ atualizado (${written} novos arquivos adicionados)`);
  }
  info(`${nAgents} agentes  |  ${nSkills} skills  |  ${nCommands} commands`);

  // ---------- gravar marcador de versão ----------
  writeKitVersion(destClaude);
  info(`marcador gravado em .claude/.kit-version (v${KIT_VERSION})`);

  // ---------- CLAUDE.md ----------
  console.log();
  const claudeMdPath = path.join(destino, "CLAUDE.md");
  let nomeProjeto = path.basename(destino);

  if (!fs.existsSync(claudeMdPath)) {
    const gerar = await askSN("  Gerar CLAUDE.md para este projeto?");
    if (gerar) {
      const nome  = await ask("  Nome do projeto", nomeProjeto);
      nomeProjeto = nome;
      const desc  = await ask("  Descrição em uma linha");
      const stack = await ask("  Stack principal", "Next.js + Supabase");
      const porta = await ask("  Porta do servidor de desenvolvimento", "3000");
      const data  = new Date().toISOString().slice(0, 10);

      const md = `# CLAUDE.md — ${nome}

> Gerado em ${data} via Nexus Code Starter Kit v${KIT_VERSION}.
> **Leia este arquivo completo antes de qualquer ação no projeto.**

---

## 📌 Visão Geral

| Campo | Valor |
|---|---|
| Projeto | ${nome} |
| Descrição | ${desc || "(preencher)"} |
| Stack | ${stack} |
| Porta dev | ${porta} |
| Criado em | ${data} |
${blocoBaseConhecimento()}
---

## ⚙️ Protocolo Obrigatório

Para qualquer **feature nova**, invoque \`@orchestrator\` antes de começar.
Para bug fixes simples (typo, estilo, ajuste isolado), pode pular.

---

## 🏗️ Arquitetura

- **Frontend:** (preencher)
- **Backend:** (preencher)
- **Banco de dados:** (preencher)
- **Deploy:** (preencher)
- **Auth:** (preencher)

---

## 🚫 Proibições Absolutas

- **NUNCA** alterar schema do banco sem migration documentada
- **NUNCA** commitar credenciais ou secrets
- **NUNCA** modificar dados de produção sem aprovação explícita

---

*Atualize este arquivo sempre que houver mudanças de arquitetura ou convenções.*
`;
      fs.writeFileSync(claudeMdPath, md, "utf8");
      ok("CLAUDE.md gerado");
    }
  } else {
    info("CLAUDE.md já existe — preservado.");
  }

  // ---------- base de conhecimento (docs/) — núcleo spec-driven, sempre criado ----------
  console.log();
  const docsPath = path.join(destino, "docs");
  const docsJaExiste = fs.existsSync(docsPath);

  criarEsqueletoDocs(docsPath, nomeProjeto);
  if (docsJaExiste) {
    info("docs/ já existe — estrutura garantida (arquivos existentes preservados).");
  } else {
    ok("docs/ criado (base de conhecimento — núcleo spec-driven do projeto)");
    info("00_Meta, 01_Architecture, 02_Specs/Migrations, 03_Sprint_Logs, 04_Assets");
  }

  // ---------- summary ----------
  console.log();
  header("✅ KIT INSTALADO!");
  console.log(`  ${bold("Projeto:")} ${destino}`);
  console.log(`  ${bold("Versão:")}  v${KIT_VERSION}\n`);
  console.log(yellow("  Próximos passos:\n"));
  console.log(`  ${bold("1.")} Abra o projeto no Claude Code:`);
  console.log(gray(`     claude "${destino}"\n`));
  console.log(`  ${bold("2.")} Para qualquer feature nova, diga ao Claude:`);
  console.log(gray(`     @orchestrator quero criar [descreva aqui]\n`));
  console.log(cyan("  Boa codagem! 🚀\n"));

  rl.close();
}

main().catch((err) => {
  console.error("\n  Erro inesperado:", err.message);
  process.exit(1);
});
