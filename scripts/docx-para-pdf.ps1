# Converte documento do Word (.docx ou .doc) em PDF, usando o proprio Word.
#
# Uso:
#   powershell -ExecutionPolicy Bypass -File scripts\docx-para-pdf.ps1 -Arquivos "caminho\doc.docx"
#   powershell -ExecutionPolicy Bypass -File scripts\docx-para-pdf.ps1 -Arquivos "a.docx","b.docx" -Saida "pasta"
#
# Cuidados que este script toma, e que nao devem ser removidos:
#   1. -LiteralPath em toda leitura e teste de caminho. Nome de arquivo da captadora
#      traz colchete, e colchete e curinga no PowerShell (ver SOL-0014).
#   2. Se o Word ja estiver aberto, o COM devolve a instancia dela. Nesse caso o
#      script NUNCA chama Quit, senao fecharia os documentos que ela esta usando.
#   3. Confere o PDF depois de gravar (existe e tem tamanho). Conversao que falha
#      em silencio nunca pode ser contada como sucesso.

param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arquivos,

    [string]$Saida,

    # Sobrescreve o PDF mesmo que ele ja exista e esteja mais novo que o Word
    [switch]$Forcar
)

$ErrorActionPreference = "Stop"

$wdExportFormatPDF = 17
$wdDoNotSaveChanges = 0
$wdAlertsNone = 0

# O Word so alcanca caminho de ate 259 caracteres (ver SOL-0021)
$LIMITE_CAMINHO = 259

$pendentes = @()
foreach ($a in $Arquivos) {
    if (-not (Test-Path -LiteralPath $a)) {
        Write-Host "NAO ENCONTRADO: $a"
        continue
    }
    $item = Get-Item -LiteralPath $a
    if ($Saida) {
        if (-not (Test-Path -LiteralPath $Saida)) {
            New-Item -ItemType Directory -Path $Saida -Force | Out-Null
        }
        $pdf = (Resolve-Path -LiteralPath $Saida).Path + "\" + $item.BaseName + ".pdf"
    } else {
        $pdf = [System.IO.Path]::ChangeExtension($item.FullName, ".pdf")
    }

    if ($pdf.Length -gt $LIMITE_CAMINHO) {
        Write-Host ("CAMINHO LONGO DEMAIS ({0}), o Word nao alcanca: {1}" -f $pdf.Length, $pdf)
        continue
    }

    if ((Test-Path -LiteralPath $pdf) -and (-not $Forcar)) {
        $atual = Get-Item -LiteralPath $pdf
        if ($atual.LastWriteTime -ge $item.LastWriteTime) {
            Write-Host "JA ATUALIZADO: $($item.Name)"
            continue
        }
    }

    $pendentes += [pscustomobject]@{ Word = $item.FullName; Pdf = $pdf; Nome = $item.Name }
}

if ($pendentes.Count -eq 0) {
    Write-Host "Nada a converter."
    exit 0
}

$wordJaEstavaAberto = $null -ne (Get-Process -Name WINWORD -ErrorAction SilentlyContinue)

$word = New-Object -ComObject Word.Application
$alertasAntes = $word.DisplayAlerts
$word.DisplayAlerts = $wdAlertsNone
$word.Visible = $false

$convertidos = 0
$falhas = 0

try {
    foreach ($p in $pendentes) {
        $doc = $null
        try {
            # Open(FileName, ConfirmConversions, ReadOnly, AddToRecentFiles)
            $doc = $word.Documents.Open($p.Word, $false, $true, $false)
            # ExportAsFixedFormat: formato PDF, documento inteiro, sem abrir depois
            $doc.ExportAsFixedFormat($p.Pdf, $wdExportFormatPDF, $false, 0, 0, 0, 0, 0,
                                     $true, $true, 0, $true, $true, $false)
            $doc.Close($wdDoNotSaveChanges)
            $doc = $null

            if ((Test-Path -LiteralPath $p.Pdf) -and ((Get-Item -LiteralPath $p.Pdf).Length -gt 0)) {
                $kb = [math]::Round((Get-Item -LiteralPath $p.Pdf).Length / 1KB)
                Write-Host ("OK: {0} -> {1} ({2} KB)" -f $p.Nome, (Split-Path $p.Pdf -Leaf), $kb)
                $convertidos++
            } else {
                Write-Host ("FALHOU (PDF nao chegou ao destino): {0}" -f $p.Nome)
                $falhas++
            }
        } catch {
            Write-Host ("FALHOU: {0} :: {1}" -f $p.Nome, $_.Exception.Message)
            $falhas++
            if ($null -ne $doc) {
                try { $doc.Close($wdDoNotSaveChanges) } catch {}
            }
        }
    }
} finally {
    try { $word.DisplayAlerts = $alertasAntes } catch {}
    if (-not $wordJaEstavaAberto) {
        try { $word.Quit() } catch {}
    }
    try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null } catch {}
}

Write-Host ""
Write-Host ("Convertidos: {0} | Falhas: {1}" -f $convertidos, $falhas)
if ($falhas -gt 0) { exit 1 }
exit 0
