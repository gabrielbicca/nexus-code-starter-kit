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

# ---------- CLAUDE.md ----------
Write-Host ""
$claude_md_path = Join-Path $destino "CLAUDE.md"
if (-not (Test-Path $claude_md_path)) {
    if (PerguntarSN "  Gerar CLAUDE.md para este projeto?") {
        $nome    = Perguntar "  Nome do projeto" (Split-Path $destino -Leaf)
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

## ⚙️ Protocolo Obrigatório

Para qualquer **feature nova**, invoque ``@orchestrator`` antes de começar.
Para bug fixes simples, pode pular.

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
Write-Host "  2. Para qualquer feature nova, diga:" -ForegroundColor White
Write-Host "     @orchestrator quero criar [descreva aqui]" -ForegroundColor Gray
Write-Host ""
