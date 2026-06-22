#!/usr/bin/env node

// ============================================================
//  Drift Guard — valida consistência entre filesystem e docs
//  Roda via: npm test  e  prepublishOnly
// ============================================================

const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const AGENTS_DIR = path.join(ROOT, ".claude", "agents");
const SKILLS_DIR = path.join(ROOT, ".claude", "skills");
const ORCHESTRATOR_FILE = path.join(AGENTS_DIR, "orchestrator.md");
const README_FILE = path.join(ROOT, "README.md");

const red    = (s) => `\x1b[31m${s}\x1b[0m`;
const green  = (s) => `\x1b[32m${s}\x1b[0m`;
const yellow = (s) => `\x1b[33m${s}\x1b[0m`;
const gray   = (s) => `\x1b[90m${s}\x1b[0m`;

let errors = 0;

function fail(msg) {
  console.error(red(`  ✗ ${msg}`));
  errors++;
}

function ok(msg) {
  console.log(green(`  ✓ ${msg}`));
}

function info(msg) {
  console.log(gray(`  → ${msg}`));
}

// ---------- 1. Agents on disk ----------
const allAgentFiles = fs
  .readdirSync(AGENTS_DIR)
  .filter((f) => f.endsWith(".md"))
  .map((f) => f.replace(/\.md$/, ""))
  .sort();

// Para verificar referências em orchestrator.md, ignoramos o próprio orchestrator
const agentFiles = allAgentFiles.filter((a) => a !== "orchestrator");

const skillDirs = fs
  .readdirSync(SKILLS_DIR, { withFileTypes: true })
  .filter((e) => e.isDirectory())
  .map((e) => e.name)
  .sort();

info(`agents on disk: ${allAgentFiles.length} (incluindo orchestrator)`);
info(`skills on disk: ${skillDirs.length}`);

// ---------- 2. Agents referenced in orchestrator.md tables ----------
const orchestrator = fs.readFileSync(ORCHESTRATOR_FILE, "utf8");

// Capture every `agent-name` inside table cells (pipe-delimited rows)
const tableAgents = new Set();
const cellPattern = /\|\s*`([a-z][a-z0-9-]*)`\s*\|/g;
let m;
while ((m = cellPattern.exec(orchestrator)) !== null) {
  tableAgents.add(m[1]);
}

const phantom = [...tableAgents]
  .filter((a) => !agentFiles.includes(a) && a !== "orchestrator")
  .sort();
const missing = agentFiles.filter((a) => !tableAgents.has(a)).sort();

if (phantom.length) {
  fail(
    `orchestrator.md cita agentes que NÃO existem em .claude/agents/: ${phantom.join(", ")}`
  );
}
if (missing.length) {
  fail(
    `orchestrator.md NÃO cita estes agentes (existem em disco): ${missing.join(", ")}`
  );
}
if (!phantom.length && !missing.length) {
  ok(`orchestrator.md em sincronia com ${agentFiles.length} agentes`);
}

// ---------- 3. README counts ----------
const readme = fs.readFileSync(README_FILE, "utf8");

// Esperado: "→ 21 agentes especializados" e "→ 38 cápsulas"
const agentCountMatch = readme.match(/(\d+)\s+agentes especializados/);
const skillCountMatch = readme.match(/(\d+)\s+cápsulas/);

if (!agentCountMatch) {
  fail("README.md não tem a string 'NN agentes especializados' (não foi possível validar contagem)");
} else {
  const n = parseInt(agentCountMatch[1], 10);
  if (n !== allAgentFiles.length) {
    fail(
      `README.md anuncia ${n} agentes, mas existem ${allAgentFiles.length} em .claude/agents/`
    );
  } else {
    ok(`README.md anuncia contagem correta de agentes (${n})`);
  }
}

if (!skillCountMatch) {
  fail("README.md não tem a string 'NN cápsulas' (não foi possível validar contagem)");
} else {
  const n = parseInt(skillCountMatch[1], 10);
  if (n !== skillDirs.length) {
    fail(
      `README.md anuncia ${n} skills, mas existem ${skillDirs.length} em .claude/skills/`
    );
  } else {
    ok(`README.md anuncia contagem correta de skills (${n})`);
  }
}

// ---------- 4. README agent table coverage ----------
// Verifica que cada agente em .claude/agents/ aparece pelo menos uma vez no README
const readmeAgents = new Set();
const readmePattern = /`@([a-z][a-z0-9-]*)`/g;
while ((m = readmePattern.exec(readme)) !== null) {
  readmeAgents.add(m[1]);
}
const missingFromReadme = allAgentFiles.filter((a) => !readmeAgents.has(a)).sort();
if (missingFromReadme.length) {
  fail(`README.md não menciona estes agentes: ${missingFromReadme.join(", ")}`);
} else {
  ok(`README.md menciona todos os ${allAgentFiles.length} agentes`);
}

// ---------- 5. Templates de docs (spec-driven) ----------
// Os protocolos (CLAUDE.template.md, bootstrap, migration) mandam usar estes
// templates em docs/00_Meta/. O instalador os copia de templates/00_Meta/.
// Se sumirem, vira "template-fantasma": protocolo referencia o que não existe.
const TEMPLATES_META = path.join(ROOT, "templates", "00_Meta");
const EXPECTED_TEMPLATES = [
  "ADR-Template.md",
  "Feature-Spec-Template.md",
  "Migration-Template.md",
  "AGENT_FLOW.md",
  ".env.local.example",
];
if (!fs.existsSync(TEMPLATES_META)) {
  fail("templates/00_Meta/ não existe — o protocolo referencia templates que não seriam instalados");
} else {
  const present = new Set(fs.readdirSync(TEMPLATES_META));
  const missingTpl = EXPECTED_TEMPLATES.filter((t) => !present.has(t));
  if (missingTpl.length) {
    fail(`templates ausentes em templates/00_Meta/: ${missingTpl.join(", ")}`);
  } else {
    ok(`templates/00_Meta/ tem os ${EXPECTED_TEMPLATES.length} templates esperados`);
  }
}

// ---------- 6. Resultado ----------
console.log();
if (errors > 0) {
  console.error(red(`✗ Drift detectado: ${errors} problema(s).`));
  console.error(yellow("  Atualize orchestrator.md e/ou README.md antes de publicar."));
  process.exit(1);
} else {
  console.log(green("✓ Sem drift. Documentação e filesystem em sincronia."));
}
