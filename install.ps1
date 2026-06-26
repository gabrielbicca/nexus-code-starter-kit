# ============================================================
#  CLAUDE CODE STARTER KIT — INSTALADOR
#
#  Como usar (one-liner):
#  irm https://raw.githubusercontent.com/gabrielbicca/nexus-code-starter-kit/main/install.ps1 | iex
#
#  Ou localmente:
#  .\install.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$REPO_OWNER = "gabrielbicca"
$REPO_NAME  = "nexus-code-starter-kit"
$REPO_BRANCH = "main"

# ---------- Funções auxiliares ----------
function Write-Header {
    param([string]$texto)
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  $texto" -ForegroundColor Cyan
    Write-Host "============================================`n" -ForegroundColor Cyan
}
function Write-OK    { param([string]$t) Write-Host "  ✓ $t" -ForegroundColor Green }
function Write-Aviso { param([string]$t) Write-Host "  ! $t" -ForegroundColor Magenta }
function Write-Info  { param([string]$t) Write-Host "  → $t" -ForegroundColor Gray }

function PerguntarSN {
    param([string]$pergunta, [string]$padrao = "S")
    $opcoes = if ($padrao -eq "S") { "[S/n]" } else { "[s/N]" }
    $resposta = Read-Host "$pergunta $opcoes"
    if ([string]::IsNullOrWhiteSpace($resposta)) { $resposta = $padrao }
    return $resposta.ToUpper() -eq "S"
}

function Perguntar {
    param([string]$pergunta, [string]$padrao = "")
    if ($padrao) {
        $r = Read-Host "$pergunta [$padrao]"
        if ([string]::IsNullOrWhiteSpace($r)) { return $padrao }
        return $r
    }
    do { $r = Read-Host $pergunta } while ([string]::IsNullOrWhiteSpace($r))
    return $r
}

# ============================================================
Clear-Host
Write-Header "🚀 CLAUDE CODE STARTER KIT"
Write-Host "  Instala agentes, skills e commands do Claude Code"
Write-Host "  no projeto que você escolher."
Write-Host ""

# ---------- Detectar se está rodando via pipe (irm | iex) ----------
$via_pipe = $null -eq $PSScriptRoot -or $PSScriptRoot -eq ""
$KIT_LOCAL = if ($via_pipe) { "" } else { $PSScriptRoot }

# ---------- Destino ----------
Write-Host "  Onde instalar o kit?" -ForegroundColor Yellow
Write-Host "  (Pressione Enter para a pasta atual: $(Get-Location))"
Write-Host ""
$destino = Read-Host "  Caminho do projeto"
if ([string]::IsNullOrWhiteSpace($destino)) { $destino = (Get-Location).Path }

if (-not (Test-Path $destino)) {
    if (PerguntarSN "  Pasta não existe. Criar?") {
        New-Item -ItemType Directory -Path $destino -Force | Out-Null
    } else {
        exit 0
    }
}

$destino_claude = Join-Path $destino ".claude"
$ja_tem_claude  = Test-Path $destino_claude

if ($ja_tem_claude) {
    Write-Aviso ".claude/ já existe neste projeto."
    if (-not (PerguntarSN "  Atualizar (novos arquivos serão adicionados, existentes preservados)?")) {
        Write-Host "  Cancelado." -ForegroundColor Red
        exit 0
    }
}

Write-Host ""

# ---------- Obter os arquivos: GitHub ou local ----------
if ($via_pipe -or -not (Test-Path (Join-Path $KIT_LOCAL ".claude"))) {
    # Modo remoto: baixar do GitHub
    Write-Info "Baixando kit do GitHub ($REPO_OWNER/$REPO_NAME)..."

    $zip_url = "https://github.com/$REPO_OWNER/$REPO_NAME/archive/refs/heads/$REPO_BRANCH.zip"
    $tmp_zip = Join-Path $env:TEMP "claude-starter-kit.zip"
    $tmp_dir = Join-Path $env:TEMP "claude-starter-kit-extract"

    # Limpar extração anterior
    if (Test-Path $tmp_dir) { Remove-Item $tmp_dir -Recurse -Force }

    try {
        # Download com progress
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($zip_url, $tmp_zip)
        Write-OK "Download concluído"
    } catch {
        Write-Host ""
        Write-Host "  ERRO: Não foi possível baixar o kit." -ForegroundColor Red
        Write-Host "  Verifique sua conexão e se o repositório existe:" -ForegroundColor Red
        Write-Host "  https://github.com/$REPO_OWNER/$REPO_NAME" -ForegroundColor Yellow
        exit 1
    }

    # Extrair
    Expand-Archive -Path $tmp_zip -DestinationPath $tmp_dir -Force
    $kit_extraido = Get-ChildItem $tmp_dir -Directory | Select-Object -First 1
    $origem_claude = Join-Path $kit_extraido.FullName ".claude"

    if (-not (Test-Path $origem_claude)) {
        Write-Host "  ERRO: Estrutura .claude não encontrada no repositório." -ForegroundColor Red
        exit 1
    }
} else {
    # Modo local: usar a pasta do script
    $origem_claude = Join-Path $KIT_LOCAL ".claude"
    Write-Info "Usando kit local: $KIT_LOCAL"
}

# ---------- Copiar .claude/ ----------
Write-Host ""
Write-Info "Instalando estrutura .claude/..."

if ($ja_tem_claude) {
    # Modo não-destrutivo: só adiciona o que não existe
    $itens = Get-ChildItem $origem_claude -Recurse
    $adicionados = 0
    foreach ($item in $itens) {
        $rel  = $item.FullName.Substring($origem_claude.Length)
        $dest = Join-Path $destino_claude $rel
        if (-not (Test-Path $dest)) {
            if ($item.PSIsContainer) {
                New-Item -ItemType Directory -Path $dest -Force | Out-Null
            } else {
                $parent = Split-Path $dest -Parent
                if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
                Copy-Item $item.FullName $dest
                $adicionados++
            }
        }
    }
    Write-OK ".claude/ atualizado ($adicionados novos arquivos adicionados)"
} else {
    Copy-Item -Path $origem_claude -Destination $destino_claude -Recurse -Force
    Write-OK ".claude/ instalado"
}

# Contar
$n_agents   = (Get-ChildItem "$destino_claude\agents" -Filter "*.md" -ErrorAction SilentlyContinue).Count
$n_skills   = (Get-ChildItem "$destino_claude\skills" -Directory -ErrorAction SilentlyContinue).Count
$n_commands = (Get-ChildItem "$destino_claude\commands" -Filter "*.md" -ErrorAction SilentlyContinue).Count
Write-Info "$n_agents agentes  |  $n_skills skills  |  $n_commands commands"

# ---------- Gravar marcador de versão ----------
$kit_version = $null
try {
    if ($via_pipe) {
        $pkg_json_path = Join-Path $kit_extraido.FullName "package.json"
    } else {
        $pkg_json_path = Join-Path $KIT_LOCAL "package.json"
    }
    if (Test-Path $pkg_json_path) {
        $kit_version = (Get-Content $pkg_json_path -Raw | ConvertFrom-Json).version
    }
} catch { $kit_version = $null }

if ($kit_version) {
    Set-Content -Path (Join-Path $destino_claude ".kit-version") -Value $kit_version -Encoding UTF8 -NoNewline
    Write-Info "marcador gravado em .claude/.kit-version (v$kit_version)"
}

# ---------- CLAUDE.md ----------
Write-Host ""
$claude_md_path = Join-Path $destino "CLAUDE.md"
$nome_projeto = Split-Path $destino -Leaf
if (-not (Test-Path $claude_md_path)) {
    if (PerguntarSN "  Gerar CLAUDE.md para este projeto?") {
        $nome    = Perguntar "  Nome do projeto" $nome_projeto
        $nome_projeto = $nome
        $desc    = Perguntar "  Descrição em uma linha"
        $stack   = Perguntar "  Stack principal" "Next.js + Supabase"
        $data_hoje = (Get-Date).ToString("yyyy-MM-dd")

        $claude_md = @"
# CLAUDE.md — $nome

> Gerado em $data_hoje via Claude Code Starter Kit.
> **Leia este arquivo completo antes de qualquer ação no projeto.**

---

## 📌 Visão Geral

| Campo | Valor |
|---|---|
| Projeto | $nome |
| Descrição | $desc |
| Stack | $stack |
| Criado em | $data_hoje |

---

## 🧠 Base de Conhecimento — Fonte de Verdade

Este projeto é **spec-driven**: a documentação em ``docs/`` é o cérebro do desenvolvimento e a fonte de verdade. Consulte antes de decidir; atualize após implementar.

- ``docs/README.md`` — Índice (mapa da documentação)
- ``docs/00_Meta/`` — Templates e convenções
- ``docs/01_Architecture/`` — ADRs e diagramas
- ``docs/02_Specs/`` — Feature specs e guias (e ``Migrations/``)
- ``docs/03_Sprint_Logs/`` — Diários de sprint
- ``docs/04_Assets/`` — Imagens e diagramas exportados

---

## ⚙️ Protocolo Obrigatório (spec-driven)

> **A documentação vem antes do código.** Nenhuma feature nova nasce sem uma SPEC.

Para qualquer **feature nova**, siga o fluxo (detalhado em ``docs/00_Meta/AGENT_FLOW.md``):

1. ``/spec <descrição>`` → cria a **SPEC** (o quê / por quê + critérios de aceite)
2. ``/plan <descrição>`` → cria o **PLAN** (a quebra de tarefas, linkada à SPEC)
3. ``/adr <decisão>`` → registra decisões arquiteturais (quando houver)
4. ``@orchestrator`` → implementa seguindo a SPEC/PLAN (ele **exige** a SPEC antes de codar)
5. ``/verify`` → valida tudo (inclui a checagem spec-driven) antes de concluir

Bug fixes simples (typo, estilo, ajuste isolado) podem pular a SPEC e o ``@orchestrator``.

---

## 🏗️ Arquitetura

- **Frontend:** (preencher)
- **Backend:** (preencher)
- **Banco de dados:** (preencher)
- **Deploy:** (preencher)
- **Auth:** (preencher)

---

## 🚫 Proibições Absolutas

- **NUNCA** alterar schema sem migration documentada
- **NUNCA** commitar credenciais ou secrets
- **NUNCA** modificar produção sem aprovação explícita

---

*Atualize este arquivo sempre que houver mudanças de arquitetura ou convenções.*
"@
        $claude_md | Out-File -FilePath $claude_md_path -Encoding UTF8
        Write-OK "CLAUDE.md gerado"
    }
}

# ---------- Base de conhecimento (docs/) — núcleo spec-driven, sempre criado ----------
Write-Host ""
$docs_path = Join-Path $destino "docs"
$docs_ja_existe = Test-Path $docs_path
$docs_subdirs = @("00_Meta", "01_Architecture", "02_Specs", "02_Specs\Migrations", "03_Sprint_Logs", "04_Assets")
foreach ($sub in $docs_subdirs) {
    $p = Join-Path $docs_path $sub
    if (-not (Test-Path $p)) { New-Item -ItemType Directory -Path $p -Force | Out-Null }
    # .gitkeep só nas pastas que podem nascer vazias (00_Meta recebe os templates)
    if ($sub -ne "00_Meta") {
        $keep = Join-Path $p ".gitkeep"
        if (-not (Test-Path $keep)) { New-Item -ItemType File -Path $keep | Out-Null }
    }
}

# Copiar os templates do kit para docs/00_Meta (idempotente — preserva existentes)
$kit_root = Split-Path $origem_claude -Parent
$templates_meta = Join-Path $kit_root "templates\00_Meta"
if (Test-Path $templates_meta) {
    $meta_dest = Join-Path $docs_path "00_Meta"
    Get-ChildItem $templates_meta -File -Force | ForEach-Object {
        $dest = Join-Path $meta_dest $_.Name
        if (-not (Test-Path $dest)) { Copy-Item $_.FullName $dest }
    }
}

$docs_readme = Join-Path $docs_path "README.md"
if (-not (Test-Path $docs_readme)) {
    $docs_index = @"
# Base de Conhecimento — $nome_projeto

> Índice central da documentação do projeto. Mantenha-o sempre atualizado.

Esta pasta é a **fonte de verdade** do projeto (spec-driven): consulte antes de decidir, atualize após implementar.

| Pasta | Conteúdo |
|---|---|
| 00_Meta/ | Templates, convenções, .env.local.example |
| 01_Architecture/ | ADRs (decisões arquiteturais) e diagramas |
| 02_Specs/ | Feature specs e guias |
| 02_Specs/Migrations/ | Docs (.md) das migrations |
| 03_Sprint_Logs/ | Diários de sprint |
| 04_Assets/ | Imagens e diagramas exportados |

## Como criar artefatos

- Nova feature → ``/spec <descrição>`` (usa ``00_Meta/Feature-Spec-Template.md``)
- Decisão arquitetural → ``/adr <decisão>`` (usa ``00_Meta/ADR-Template.md``)
- Migration → documente em ``02_Specs/Migrations/`` a partir do ``Migration-Template.md``

## Specs

| Spec | Status | O que implementou |
|---|---|---|
| _(adicione aqui)_ | | |

## ADRs

| ADR | Decisão |
|---|---|
| _(adicione aqui)_ | |
"@
    $docs_index | Out-File -FilePath $docs_readme -Encoding UTF8
}
if ($docs_ja_existe) {
    Write-Info "docs/ já existe — estrutura garantida (arquivos existentes preservados)."
} else {
    Write-OK "docs/ criado (base de conhecimento — núcleo spec-driven do projeto)"
}

# ---------- Automação spec-driven (hook + CI) ----------
Write-Host ""
if (PerguntarSN "  Instalar o gate spec-driven na automação (pre-commit + GitHub Actions)?") {
    # pre-commit hook (só se for repo git)
    $git_dir = Join-Path $destino ".git"
    $tpl_hook = Join-Path $kit_root "templates\hooks\pre-commit"
    if ((Test-Path $git_dir) -and (Test-Path $tpl_hook)) {
        $hooks_dir = Join-Path $git_dir "hooks"
        $hook_dest = Join-Path $hooks_dir "pre-commit"
        if (-not (Test-Path $hook_dest)) {
            if (-not (Test-Path $hooks_dir)) { New-Item -ItemType Directory -Path $hooks_dir -Force | Out-Null }
            Copy-Item $tpl_hook $hook_dest
            Write-Info "hook pre-commit instalado (.git/hooks/pre-commit)"
        } else {
            Write-Info "pre-commit já existe — preservado"
        }
    } elseif (-not (Test-Path $git_dir)) {
        Write-Info "sem repositório git — hook pre-commit pulado (rode 'git init' antes)"
    }

    # GitHub Actions workflow
    $tpl_wf = Join-Path $kit_root "templates\github-workflows\spec-check.yml"
    if (Test-Path $tpl_wf) {
        $wf_dir = Join-Path $destino ".github\workflows"
        $wf_dest = Join-Path $wf_dir "spec-check.yml"
        if (-not (Test-Path $wf_dest)) {
            if (-not (Test-Path $wf_dir)) { New-Item -ItemType Directory -Path $wf_dir -Force | Out-Null }
            Copy-Item $tpl_wf $wf_dest
            Write-Info "workflow CI instalado (.github/workflows/spec-check.yml)"
        } else {
            Write-Info "spec-check.yml já existe — preservado"
        }
    }
} else {
    Write-Info "automação pulada — você pode rodar a verificação manualmente com /verify."
}

# ---------- Limpeza temporária ----------
if ($via_pipe) {
    Remove-Item $tmp_zip -ErrorAction SilentlyContinue
    Remove-Item $tmp_dir -Recurse -ErrorAction SilentlyContinue
}

# ---------- Resumo ----------
Write-Host ""
Write-Header "✅ KIT INSTALADO COM SUCESSO!"
Write-Host "  📁 $destino" -ForegroundColor White
Write-Host ""
Write-Host "  Para começar:" -ForegroundColor Yellow
Write-Host "  1. Abra o Claude Code na pasta do projeto" -ForegroundColor White
Write-Host "     claude $destino" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Para qualquer feature nova, siga o fluxo spec-driven:" -ForegroundColor White
Write-Host "     /spec [descreva]  ->  /plan  ->  @orchestrator  ->  /verify" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Guia do fluxo: docs/00_Meta/AGENT_FLOW.md" -ForegroundColor White
Write-Host ""
