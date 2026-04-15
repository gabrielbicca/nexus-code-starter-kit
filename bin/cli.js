#!/usr/bin/env node

// ============================================================
//  NEXUS CODE STARTER KIT — CLI
//  Uso: npx nexus-code-starter-kit
//  Repo: https://github.com/gabrielbicca/nexus-code-starter-kit
// ============================================================

const fs   = require("fs");
const path = require("path");
const readline = require("readline");

const KIT_DIR = path.resolve(__dirname, "..");

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

// ---------- copiar pasta recursivamente (não sobrescreve) ----------
function copyDir(src, dest, overwrite = false) {
  let added = 0;
  const entries = fs.readdirSync(src, { withFileTypes: true });
  for (const entry of entries) {
    const srcPath  = path.join(src, entry.name);
    const destPath = path.join(dest, entry.name);
    if (entry.isDirectory()) {
      if (!fs.existsSync(destPath)) fs.mkdirSync(destPath, { recursive: true });
      added += copyDir(srcPath, destPath, overwrite);
    } else {
      if (overwrite || !fs.existsSync(destPath)) {
        fs.mkdirSync(path.dirname(destPath), { recursive: true });
        fs.copyFileSync(srcPath, destPath);
        added++;
      }
    }
  }
  return added;
}

function countDir(dir, ext) {
  if (!fs.existsSync(dir)) return 0;
  return fs.readdirSync(dir).filter((f) => !ext || f.endsWith(ext)).length;
}

// ============================================================
async function main() {
  const args = process.argv.slice(2);
  const modoObsidian = args.includes("--obsidian");

  process.stdout.write("\x1Bc"); // clear
  header("🚀 CLAUDE CODE STARTER KIT");
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

  if (jaTem) {
    aviso(".claude/ já existe neste projeto.");
    const ok2 = await askSN("  Atualizar? (novos arquivos adicionados, existentes preservados)");
    if (!ok2) { console.log("  Cancelado."); rl.close(); return; }
  }

  console.log();

  // ---------- copiar .claude ----------
  const origemClaude = path.join(KIT_DIR, ".claude");

  if (!fs.existsSync(origemClaude)) {
    console.error(`\n  ERRO: pasta .claude não encontrada em ${origemClaude}`);
    rl.close(); process.exit(1);
  }

  if (!fs.existsSync(destClaude)) fs.mkdirSync(destClaude, { recursive: true });

  const added = copyDir(origemClaude, destClaude, false);
  const nAgents   = countDir(path.join(destClaude, "agents"));
  const nSkills   = countDir(path.join(destClaude, "skills"));
  const nCommands = countDir(path.join(destClaude, "commands"));

  ok(jaTem ? `.claude/ atualizado (${added} novos arquivos)` : ".claude/ instalado");
  info(`${nAgents} agentes  |  ${nSkills} skills  |  ${nCommands} commands`);

  // ---------- CLAUDE.md ----------
  console.log();
  const claudeMdPath = path.join(destino, "CLAUDE.md");

  if (!fs.existsSync(claudeMdPath)) {
    const gerar = await askSN("  Gerar CLAUDE.md para este projeto?");
    if (gerar) {
      const nome  = await ask("  Nome do projeto", path.basename(destino));
      const desc  = await ask("  Descrição em uma linha");
      const stack = await ask("  Stack principal", "Next.js + Supabase");
      const porta = await ask("  Porta do servidor de desenvolvimento", "3000");
      const data  = new Date().toISOString().slice(0, 10);

      const md = `# CLAUDE.md — ${nome}

> Gerado em ${data} via Claude Code Starter Kit.
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

  // ---------- Obsidian ----------
  if (modoObsidian) {
    console.log();
    aviso("Modo --obsidian: configure manualmente o .mcp.json com o caminho da sua vault.");
    info("Consulte: setup_obsidian.ps1 no repositório para o passo a passo.");
  }

  // ---------- resumo ----------
  console.log();
  header("✅ KIT INSTALADO!");
  console.log(`  ${bold("Projeto:")} ${destino}\n`);
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
