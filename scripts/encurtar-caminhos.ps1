# Encurta caminho de pasta para os arquivos voltarem a abrir no Windows.
#
# O Windows recusa caminho acima de 259 caracteres para a maioria dos programas.
# O documento fica salvo, mas o leitor de PDF e o Word nao alcancam (ver SOL-0021).
# A correcao certa e encurtar a arvore de pastas, nao o nome do arquivo (SOL-0023).
#
# Uso:
#   powershell -File scripts\encurtar-caminhos.ps1 -Raiz "<pasta mae>" -Plano plano.json
#   powershell -File scripts\encurtar-caminhos.ps1 -Raiz "<pasta mae>" -Plano plano.json -Aplicar
#
# Sem -Aplicar ele so simula: mostra quanto cada renomeacao economiza e quantos
# arquivos saem do limite. Com -Aplicar, renomeia e grava o registro de reversao.
#
# Formato do plano (JSON), um item por pasta a renomear:
#   [ { "caminho": "06 - Clientes\\06 - Fulano\\Pasta com nome longo", "novo": "Pasta curta" } ]
# O campo "caminho" e relativo a -Raiz. So o ultimo nome muda; a pasta nao sai do lugar.
#
# Cuidados que este script toma, e que nao devem ser removidos:
#   1. -LiteralPath em tudo. Nome de arquivo real traz colchete, e colchete e
#      curinga no PowerShell (SOL-0014).
#   2. Renomeia da pasta mais funda para a mais rasa, senao o caminho das filhas
#      deixa de existir no meio da execucao.
#   3. Confere depois de renomear. Renomeacao que nao aconteceu nunca pode ser
#      contada como sucesso.
#   4. Nunca apaga, nunca move, nunca toca no conteudo do arquivo.

param(
    [Parameter(Mandatory = $true)]
    [string]$Raiz,

    [Parameter(Mandatory = $true)]
    [string]$Plano,

    [switch]$Aplicar,

    [int]$Limite = 259,

    # Onde gravar o registro de reversao (padrao: ao lado do plano)
    [string]$Reversao
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Raiz)) { throw "Pasta mae nao encontrada: $Raiz" }
if (-not (Test-Path -LiteralPath $Plano)) { throw "Plano nao encontrado: $Plano" }

$Raiz = (Resolve-Path -LiteralPath $Raiz).Path.TrimEnd('\')
$itens = Get-Content -LiteralPath $Plano -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $Reversao) {
    $Reversao = [System.IO.Path]::ChangeExtension($Plano, ".reversao.json")
}

function Contar-Longos {
    param([string]$base, [int]$lim)
    @(Get-ChildItem -LiteralPath $base -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName.Length -gt $lim }).Count
}

$antes = Contar-Longos $Raiz $Limite
Write-Host ("Arquivos acima de {0} caracteres agora: {1}" -f $Limite, $antes)
Write-Host ("Modo: {0}" -f $(if ($Aplicar) { "APLICAR" } else { "simulacao (nada sera alterado)" }))
Write-Host ""

# Mais funda primeiro: renomear o pai antes quebraria o caminho das filhas
$ordenados = $itens | Sort-Object -Property @{ Expression = { ($_.caminho -split '\\').Count } } -Descending

$ok = 0
$erros = 0
$pulados = 0
$registro = @()

foreach ($it in $ordenados) {
    $origem = $Raiz + "\" + $it.caminho
    $nomeAtual = Split-Path $it.caminho -Leaf
    $pai = [System.IO.Path]::GetDirectoryName($origem)
    $destino = $pai + "\" + $it.novo

    if (-not (Test-Path -LiteralPath $origem)) {
        Write-Host ("NAO EXISTE: {0}" -f $it.caminho)
        $pulados++
        continue
    }
    if ($nomeAtual -eq $it.novo) {
        Write-Host ("JA ESTA COM O NOME NOVO: {0}" -f $it.novo)
        $pulados++
        continue
    }
    if (Test-Path -LiteralPath $destino) {
        Write-Host ("DESTINO JA EXISTE, nao renomeio para nao juntar pastas: {0}" -f $it.novo)
        $pulados++
        continue
    }

    $economia = $nomeAtual.Length - $it.novo.Length
    $quantos = @(Get-ChildItem -LiteralPath $origem -Recurse -File -ErrorAction SilentlyContinue).Count

    if (-not $Aplicar) {
        Write-Host ("[-{0,3} car | {1,4} arq] {2}" -f $economia, $quantos, $nomeAtual)
        Write-Host ("                     -> {0}" -f $it.novo)
        $ok++
        continue
    }

    try {
        Rename-Item -LiteralPath $origem -NewName $it.novo -ErrorAction Stop
        if ((Test-Path -LiteralPath $destino) -and (-not (Test-Path -LiteralPath $origem))) {
            Write-Host ("OK [-{0} car | {1} arq] {2} -> {3}" -f $economia, $quantos, $nomeAtual, $it.novo)
            $registro += [pscustomobject]@{
                pasta_pai = $pai.Substring($Raiz.Length).TrimStart('\')
                de        = $it.novo
                para      = $nomeAtual
            }
            $ok++
        } else {
            Write-Host ("FALHOU sem erro (a pasta nao mudou de nome): {0}" -f $nomeAtual)
            $erros++
        }
    } catch {
        # "acesso negado" aqui quase nunca e permissao: e uma janela do Explorer
        # aberta dentro da arvore, que trava a renomeacao da pasta (SOL-0023)
        Write-Host ("FALHOU: {0} :: {1}" -f $nomeAtual, $_.Exception.Message)
        $erros++
    }
}

Write-Host ""
if ($Aplicar) {
    if ($registro.Count -gt 0) {
        $registro | ConvertTo-Json -Depth 4 | Out-File -LiteralPath $Reversao -Encoding utf8
        Write-Host ("Registro de reversao: {0}" -f $Reversao)
    }
    $depois = Contar-Longos $Raiz $Limite
    Write-Host ("Renomeadas: {0} | Falhas: {1} | Puladas: {2}" -f $ok, $erros, $pulados)
    Write-Host ("Arquivos acima de {0} caracteres: {1} antes, {2} agora" -f $Limite, $antes, $depois)
    if ($erros -gt 0) { exit 1 }
} else {
    Write-Host ("Renomeacoes previstas: {0} | Puladas: {1}" -f $ok, $pulados)
    Write-Host "Rode de novo com -Aplicar para valer."
}
exit 0
