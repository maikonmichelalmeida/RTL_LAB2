param(
    [Parameter(Position = 0)]
    [string]$Mensagem = "Atualiza projeto RTL_LAB2"
)

$ErrorActionPreference = "Stop"

Set-Location $PSScriptRoot

Write-Host ""
Write-Host "Projeto local:"
Write-Host (Get-Location)
Write-Host ""

$alteracoes = git status --porcelain

if (-not $alteracoes) {
    Write-Host "Nenhuma alteracao para enviar."
    exit 0
}

Write-Host "Alteracoes encontradas:"
git status --short
Write-Host ""

Write-Host "Registrando arquivos novos, alterados e removidos..."
git add -A

Write-Host "Criando commit: $Mensagem"
git commit -m $Mensagem

Write-Host "Enviando para o repositorio remoto..."
git push origin main

Write-Host ""
Write-Host "Projeto enviado com sucesso."