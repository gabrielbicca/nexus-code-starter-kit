# ============================================================
#  SETUP — OBSIDIAN MCP PARA CLAUDE CODE
#  Configura a integração entre Claude Code e Obsidian.
#  Suporta dois modos: Local REST API e Filesystem direto.
# ============================================================

$ErrorActionPreference = "Stop"

# ---------- Funções auxiliares ----------
function Write-Header {
    param([string]$texto)
    Write-Host "`n============================================" -ForegroundColor Cyan
    Write-Host "  $texto" -ForegroundColor Cyan
    Write-Host "============================================`n" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$num, [string]$texto)
    Write-Host "[$num] $texto" -ForegroundColor Yellow
}

function Write-OK {
    param([string]$texto)
    Write-Host "  ✓ $texto" -ForegroundColor Green
}

function Write-Aviso {
    param([string]$texto)
    Write-Host "  ! $texto" -ForegroundColor Magenta
}

function Write-Info {
    param([string]$texto)
    Write-Host "  → $texto" -ForegroundColor Gray
}

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
        $resposta = Read-Host "$pergunta [$padrao]"
        if ([string]::IsNullOrWhiteSpace($resposta)) { return $padrao }
        return $resposta
    }
    do {
        $resposta = Read-Host $pergunta
    } while ([string]::IsNullOrWhiteSpace($resposta))
    return $resposta
}

function Testar-Porta {
    param([int]$porta)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $conn = $tcp.BeginConnect("127.0.0.1", $porta, $null, $null)
        $ok = $conn.AsyncWaitHandle.WaitOne(1000, $false)
        $tcp.Close()
        return $ok
    } catch {
        return $false
    }
}

function Obter-ObsidianApiKey {
    # Tenta ler a API key do Obsidian nos locais padrão
    $locais = @(
        "$env:APPDATA\obsidian\obsidian.json",
        "$env:USERPROFILE\.obsidian\obsidian.json"
    )
    foreach ($local in $locais) {
        if (Test-Path $local) {
            try {
                $cfg = Get-Content $local -Raw | ConvertFrom-Json
                if ($cfg.localRestApiKey) { return $cfg.localRestApiKey }
            } catch {}
        }
    }
    return ""
}

# ---------- Determinar pasta raiz deste kit ----------
$KIT_RAIZ = $PSScriptRoot
if ([string]::IsNullOrEmpty($KIT_RAIZ)) {
    $KIT_RAIZ = Split-Path -Parent $MyInvocation.MyCommand.Path
}

# ============================================================
#  INÍCIO
# ============================================================
Clear-Host
Write-Header "📓 SETUP — OBSIDIAN MCP PARA CLAUDE CODE"
Write-Host "  Este script configura a integração do Obsidian como"
Write-Host "  'cérebro externo' do seu projeto no Claude Code."
Write-Host ""

# ============================================================
#  EXPLICAR OS DOIS MODOS
# ============================================================
Write-Host "  Existem dois modos de integração:" -ForegroundColor White
Write-Host ""
Write-Host "  Modo A — Local REST API (recomendado)" -ForegroundColor Green
Write-Host "    + Claude acessa Obsidian com recursos completos" -ForegroundColor Gray
Write-Host "    + Suporte a links internos, busca no grafo, metadados" -ForegroundColor Gray
Write-Host "    - Obsidian precisa estar ABERTO enquanto você usa o Claude Code" -ForegroundColor Gray
Write-Host ""
Write-Host "  Modo B — Filesystem (alternativo)" -ForegroundColor Yellow
Write-Host "    + Obsidian NÃO precisa estar aberto" -ForegroundColor Gray
Write-Host "    + Funciona em automações, CI, terminal sem GUI" -ForegroundColor Gray
Write-Host "    - Apenas leitura/escrita básica de arquivos .md" -ForegroundColor Gray
Write-Host ""
Write-Host "  ► Este script configura os DOIS modos e detecta automaticamente" -ForegroundColor Cyan
Write-Host "    qual usar dependendo se o Obsidian está ou não aberto." -ForegroundColor Cyan
Write-Host ""

if (-not (PerguntarSN "  Continuar com a configuração?")) {
    Write-Host "  Cancelado." -ForegroundColor Red
    exit 0
}

# ---------- Passo 1: Vault ----------
Write-Host ""
Write-Step "1/5" "Localizar a vault do Obsidian"
Write-Host ""

# Tentar detectar vaults automaticamente
$vaults_encontradas = @()
$obsidian_cfg = "$env:APPDATA\obsidian\obsidian.json"
if (Test-Path $obsidian_cfg) {
    try {
        $cfg = Get-Content $obsidian_cfg -Raw | ConvertFrom-Json
        if ($cfg.vaults) {
            $cfg.vaults.PSObject.Properties | ForEach-Object {
                $vault = $_.Value
                if ($vault.path -and (Test-Path $vault.path)) {
                    $vaults_encontradas += $vault.path
                }
            }
        }
    } catch {}
}

if ($vaults_encontradas.Count -gt 0) {
    Write-Info "Vaults detectadas no Obsidian:"
    for ($i = 0; $i -lt $vaults_encontradas.Count; $i++) {
        Write-Host "     [$($i+1)] $($vaults_encontradas[$i])" -ForegroundColor White
    }
    Write-Host "     [0] Informar outro caminho" -ForegroundColor White
    Write-Host ""
    $escolha = Read-Host "  Escolha (número)"

    if ($escolha -eq "0" -or [string]::IsNullOrWhiteSpace($escolha)) {
        $caminho_vault = Perguntar "  Caminho da vault"
    } elseif ([int]::TryParse($escolha, [ref]$null)) {
        $idx = [int]$escolha - 1
        if ($idx -ge 0 -and $idx -lt $vaults_encontradas.Count) {
            $caminho_vault = $vaults_encontradas[$idx]
        } else {
            $caminho_vault = Perguntar "  Caminho da vault"
        }
    } else {
        $caminho_vault = Perguntar "  Caminho da vault"
    }
} else {
    Write-Info "Obsidian não encontrado ou nenhuma vault ativa."
    $caminho_vault = Perguntar "  Informe o caminho completo da sua vault"
}

if (-not (Test-Path $caminho_vault)) {
    Write-Aviso "Pasta não encontrada. Criando..."
    New-Item -ItemType Directory -Path $caminho_vault -Force | Out-Null
}
Write-OK "Vault: $caminho_vault"

# ---------- Passo 2: Detectar modo disponível ----------
Write-Host ""
Write-Step "2/5" "Detectando modo disponível"
Write-Host ""

$porta_rest_api = 27123
$obsidian_rodando = Testar-Porta $porta_rest_api
$api_key = Obter-ObsidianApiKey

if ($obsidian_rodando) {
    Write-OK "Obsidian está aberto e o plugin Local REST API está ativo (porta $porta_rest_api)"
    $modo_atual = "REST_API"
} else {
    Write-Aviso "Obsidian não está rodando ou o plugin Local REST API não está ativo"
    Write-Info "Modo Filesystem será usado como padrão"
    $modo_atual = "FILESYSTEM"
}

# ---------- Passo 3: Configurar o projeto ----------
Write-Host ""
Write-Step "3/5" "Qual projeto configurar?"
Write-Host ""
Write-Host "  Informe a pasta do projeto onde a integração será aplicada."
Write-Host "  (Pressione Enter para a pasta atual: $(Get-Location))"
Write-Host ""

$caminho_projeto = Read-Host "  Caminho do projeto"
if ([string]::IsNullOrWhiteSpace($caminho_projeto)) {
    $caminho_projeto = (Get-Location).Path
}

if (-not (Test-Path $caminho_projeto)) {
    Write-Host "  ERRO: Pasta não encontrada: $caminho_projeto" -ForegroundColor Red
    exit 1
}

Write-OK "Projeto: $caminho_projeto"

# ---------- Passo 4: Gerar configuração MCP ----------
Write-Host ""
Write-Step "4/5" "Gerando configuração MCP"
Write-Host ""

# Verificar se npm/npx estão disponíveis
$tem_npx = $null -ne (Get-Command npx -ErrorAction SilentlyContinue)
$tem_node = $null -ne (Get-Command node -ErrorAction SilentlyContinue)

if (-not $tem_node) {
    Write-Aviso "Node.js não encontrado. Instale em https://nodejs.org para usar MCPs."
}

# Configuração para o settings.local.json do projeto
$claude_settings_path = Join-Path $caminho_projeto ".claude\settings.local.json"
$claude_settings = @{
    permissions = @{
        allow = @(
            "mcp__obsidian__view",
            "mcp__obsidian__get_workspace_files",
            "mcp__obsidian__create",
            "mcp__obsidian__str_replace"
        )
    }
    enableAllProjectMcpServers = $true
    enabledMcpjsonServers = @("obsidian")
}

# Mesclar com settings existentes
if (Test-Path $claude_settings_path) {
    try {
        $existente = Get-Content $claude_settings_path -Raw | ConvertFrom-Json
        # Mesclar permissions
        if ($existente.permissions -and $existente.permissions.allow) {
            $combined = ($existente.permissions.allow + $claude_settings.permissions.allow) | Select-Object -Unique
            $claude_settings.permissions.allow = $combined
        }
        if ($existente.permissions -and $existente.permissions.deny) {
            $claude_settings.permissions.deny = $existente.permissions.deny
        }
    } catch {
        Write-Aviso "Não foi possível ler settings existente. Um novo será criado."
    }
}

$claude_settings | ConvertTo-Json -Depth 10 | Out-File $claude_settings_path -Encoding UTF8
Write-OK "settings.local.json atualizado"

# Gerar .mcp.json na raiz do projeto
$mcp_config_path = Join-Path $caminho_projeto ".mcp.json"

# O mcp.json suporta ambos os servidores
$mcp_json = @{
    mcpServers = @{
        obsidian = @{
            command = "npx"
            args = @("-y", "@modelcontextprotocol/server-obsidian", $caminho_vault)
            env = @{}
            description = "Obsidian MCP - Modo Filesystem (sem precisar do app aberto)"
            notes = "Para usar o modo REST API, garanta que o Obsidian está aberto com o plugin Local REST API ativo na porta $porta_rest_api"
        }
    }
}

# Se a REST API está disponível e temos a key, adicionar como servidor primário
if ($obsidian_rodando -and $api_key) {
    $mcp_json.mcpServers["obsidian-rest"] = @{
        command = "npx"
        args = @("-y", "mcp-obsidian")
        env = @{
            OBSIDIAN_API_KEY = $api_key
            OBSIDIAN_HOST = "http://localhost"
            OBSIDIAN_PORT = "$porta_rest_api"
        }
        description = "Obsidian MCP - Modo REST API (requer Obsidian aberto)"
    }
    Write-OK "Servidor REST API configurado com API key detectada"
} elseif ($obsidian_rodando) {
    Write-Aviso "Obsidian está aberto mas a API key não foi encontrada automaticamente."
    if (PerguntarSN "  Informe a API key manualmente?") {
        $api_key_manual = Perguntar "  API key (encontre em: Obsidian > Configurações > Local REST API)"
        if (-not [string]::IsNullOrWhiteSpace($api_key_manual)) {
            $mcp_json.mcpServers["obsidian-rest"] = @{
                command = "npx"
                args = @("-y", "mcp-obsidian")
                env = @{
                    OBSIDIAN_API_KEY = $api_key_manual
                    OBSIDIAN_HOST = "http://localhost"
                    OBSIDIAN_PORT = "$porta_rest_api"
                }
                description = "Obsidian MCP - Modo REST API (requer Obsidian aberto)"
            }
            Write-OK "Servidor REST API configurado"
        }
    }
}

$mcp_json | ConvertTo-Json -Depth 10 | Out-File $mcp_config_path -Encoding UTF8
Write-OK ".mcp.json criado em: $mcp_config_path"

# ---------- Passo 5: Criar estrutura da vault ----------
Write-Host ""
Write-Step "5/5" "Criar estrutura básica da vault"
Write-Host ""

if (PerguntarSN "  Criar estrutura de pastas padrão na vault?") {
    $pastas_vault = @(
        "00_Meta",
        "01_Architecture",
        "02_Specs",
        "02_Specs\Migrations",
        "03_Sprint_Logs",
        "04_Assets"
    )

    foreach ($pasta in $pastas_vault) {
        $caminho = Join-Path $caminho_vault $pasta
        if (-not (Test-Path $caminho)) {
            New-Item -ItemType Directory -Path $caminho -Force | Out-Null
        }
    }
    Write-OK "Estrutura da vault criada"

    # Criar README.md (MOC) se não existir
    $readme_vault = Join-Path $caminho_vault "README.md"
    if (-not (Test-Path $readme_vault)) {
        $nome_projeto = Split-Path $caminho_projeto -Leaf
        $readme_content = @"
# 📋 $nome_projeto — Central de Documentação

> Vault do Obsidian — Cérebro externo do projeto.
> Atualizada pelo Claude Code automaticamente.

---

## 🗂️ Estrutura

| Pasta | Conteúdo |
|-------|----------|
| ``00_Meta/`` | Templates, convenções, configs |
| ``01_Architecture/`` | ADRs, diagramas de arquitetura |
| ``02_Specs/`` | Feature specs, guias, migrations docs |
| ``03_Sprint_Logs/`` | Diários de sprint e retrospectivas |
| ``04_Assets/`` | Imagens, diagramas exportados |

---

## 🔗 Links rápidos

- [[00_Meta/AGENT_FLOW]] — Fluxo de trabalho com agentes
- [[01_Architecture/ADR-001]] — Primeira decisão de arquitetura
- [[02_Specs/Project-Scope]] — Escopo do projeto

---

*Última atualização: $(Get-Date -Format 'yyyy-MM-dd')*
"@
        $readme_content | Out-File $readme_vault -Encoding UTF8
        Write-OK "README.md da vault criado"
    }
}

# ---------- Instrução para instalar o plugin ----------
Write-Host ""
Write-Header "✅ CONFIGURAÇÃO CONCLUÍDA!"
Write-Host ""
Write-Host "  Modo atual: $(if($modo_atual -eq 'REST_API'){'REST API (Obsidian aberto)'}else{'Filesystem (independente)'})" -ForegroundColor White
Write-Host "  Vault: $caminho_vault" -ForegroundColor White
Write-Host "  Config MCP: $mcp_config_path" -ForegroundColor White
Write-Host ""

if ($modo_atual -eq "FILESYSTEM" -and -not $obsidian_rodando) {
    Write-Host "  ─────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  Para ativar o modo REST API (mais completo):" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1. Abra o Obsidian" -ForegroundColor White
    Write-Host "  2. Vá em: Configurações > Plugins da comunidade > Procurar" -ForegroundColor White
    Write-Host "  3. Busque: 'Local REST API'" -ForegroundColor White
    Write-Host "  4. Instale e ative o plugin" -ForegroundColor White
    Write-Host "  5. Execute este script novamente com o Obsidian aberto" -ForegroundColor White
    Write-Host ""
}

Write-Host "  Próximo passo — Abra o Claude Code no projeto:" -ForegroundColor Yellow
Write-Host "  claude $caminho_projeto" -ForegroundColor Gray
Write-Host ""
Write-Host "  O Claude agora pode consultar e atualizar a vault!" -ForegroundColor Cyan
Write-Host ""
