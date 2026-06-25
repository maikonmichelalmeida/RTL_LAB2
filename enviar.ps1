param(
    [Parameter(Position = 0)]
    [string]$Mensagem = "Atualiza projeto RTL_LAB2",

    [switch]$ValidarSomente
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments

    if ($LASTEXITCODE -ne 0) {
        throw "Falha ao executar: git $($Arguments -join ' ')"
    }
}

Write-Host ""
Write-Host "Projeto local:"
Write-Host (Get-Location)
Write-Host ""

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git nao foi encontrado no PATH."
}

$raizGit = (& git rev-parse --show-toplevel 2>$null)

if ($LASTEXITCODE -ne 0) {
    throw "Esta pasta nao pertence a um repositorio Git."
}

$raizGit = [IO.Path]::GetFullPath($raizGit.Trim())
$raizScript = [IO.Path]::GetFullPath($PSScriptRoot)

if ($raizGit -ne $raizScript) {
    throw "O script deve ficar na raiz do repositorio. Raiz detectada: $raizGit"
}

$remoto = "origin"
$remotos = @(& git remote)

if ($LASTEXITCODE -ne 0 -or $remotos -notcontains $remoto) {
    throw "O remoto '$remoto' nao esta configurado."
}

$branch = (& git branch --show-current).Trim()

if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($branch)) {
    throw "Nao foi possivel determinar a branch atual."
}

$repositoriosAninhados = @(
    Get-ChildItem -Path $PSScriptRoot -Directory -Force -Recurse -Filter ".git" |
        Where-Object { $_.FullName -ne (Join-Path $PSScriptRoot ".git") }
)

if ($repositoriosAninhados.Count -gt 0) {
    Write-Host "Repositorios Git aninhados encontrados:" -ForegroundColor Yellow
    $repositoriosAninhados.FullName | ForEach-Object { Write-Host "  $_" }
    throw "Remova ou mova os diretorios .git internos antes de enviar."
}

$limiteGitHub = 100MB
$arquivosGrandes = @(
    Get-ChildItem -Path $PSScriptRoot -File -Force -Recurse |
        Where-Object {
            $_.FullName -notlike "$PSScriptRoot\.git\*" -and
            $_.Length -ge $limiteGitHub
        }
)

if ($arquivosGrandes.Count -gt 0) {
    Write-Host "Arquivos com 100 MB ou mais encontrados:" -ForegroundColor Yellow
    $arquivosGrandes | ForEach-Object {
        Write-Host ("  {0:N2} MB  {1}" -f ($_.Length / 1MB), $_.FullName)
    }
    throw "O GitHub recusa arquivos individuais com 100 MB ou mais."
}

$alteracoes = @(& git status --porcelain)

if ($LASTEXITCODE -ne 0) {
    throw "Nao foi possivel consultar o estado do repositorio."
}

if ($alteracoes.Count -eq 0) {
    Write-Host "Nenhuma alteracao para enviar."
    exit 0
}

Write-Host "Alteracoes encontradas:"
Invoke-Git -Arguments @("status", "--short")
Write-Host ""

if ($ValidarSomente) {
    Write-Host "Validacao concluida. Nenhum commit ou push foi executado."
    exit 0
}

Write-Host "Registrando arquivos novos, alterados e removidos..."
Invoke-Git -Arguments @("add", "-A")

$alteracoesPreparadas = @(& git diff --cached --name-only)

if ($LASTEXITCODE -ne 0) {
    throw "Nao foi possivel consultar os arquivos preparados."
}

if ($alteracoesPreparadas.Count -eq 0) {
    Write-Host "Nenhuma alteracao versionavel ficou preparada para commit."
    exit 0
}

Write-Host "Criando commit na branch '$branch': $Mensagem"
Invoke-Git -Arguments @("commit", "-m", $Mensagem)

Write-Host "Enviando para '$remoto/$branch'..."
Invoke-Git -Arguments @("push", "-u", $remoto, $branch)

Write-Host ""
Write-Host "Projeto enviado com sucesso."
