# Encurta o NOME do arquivo, para os que continuam fora do limite depois de a
# arvore de pastas ja ter sido encurtada.
#
# A ordem certa e sempre essa (ver SOL-0023): primeiro a pasta, depois o arquivo.
# Encurtar o nome do arquivo e o ultimo recurso, porque e o nome que a captadora
# leu e reconhece.
#
# Uso:
#   powershell -File scripts\encurtar-nomes-arquivo.ps1 -Raiz "<pasta mae>"
#   powershell -File scripts\encurtar-nomes-arquivo.ps1 -Raiz "<pasta mae>" -Aplicar
#
# Sem -Aplicar so mostra o que faria. O corte e o menor possivel: tira apenas o
# que falta para caber, sempre pelo fim e, quando da, numa quebra de palavra.
# A extensao nunca muda, senao o arquivo deixa de abrir no programa certo.

param(
    [Parameter(Mandatory = $true)]
    [string]$Raiz,

    [switch]$Aplicar,

    [int]$Limite = 259,

    # Trechos de caminho a deixar de fora (ex: uma arvore que outra pessoa esta mexendo)
    [string[]]$Ignorar = @(),

    # JSON com nomes escolhidos a dedo, que valem no lugar do corte automatico.
    # Formato: { "ignorar": ["trecho"], "exatos": [{"de","para"}], "padroes": [{"regex","para"}] }
    # ATENCAO: acento so pode viver neste JSON, nunca escrito dentro deste .ps1.
    # O PowerShell 5.1 le arquivo .ps1 sem BOM como ANSI, entao "Mineracao" com til
    # dentro do script vira lixo e a comparacao falha em silencio. O JSON e lido com
    # -Encoding UTF8 explicito, e por isso e o lugar certo do texto acentuado.
    [string]$Curados,

    [string]$Reversao,

    # Nunca deixa o nome (sem extensao) menor que isto. Abaixo disso o arquivo fica
    # irreconhecivel, e o certo passa a ser encurtar a pasta.
    [int]$MinimoNome = 12
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Raiz)) { throw "Pasta mae nao encontrada: $Raiz" }
$Raiz = (Resolve-Path -LiteralPath $Raiz).Path.TrimEnd('\')
if (-not $Reversao) { $Reversao = "$Raiz\reversao-nomes.json" }

$exatos = @{}
$padroes = @()
if ($Curados) {
    if (-not (Test-Path -LiteralPath $Curados)) { throw "Lista de nomes curados nao encontrada: $Curados" }
    $c = Get-Content -LiteralPath $Curados -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($c.ignorar) { $Ignorar += $c.ignorar }
    if ($c.exatos) { foreach ($e in $c.exatos) { $exatos[$e.de] = $e.para } }
    if ($c.padroes) { $padroes = $c.padroes }
}

$alvos = Get-ChildItem -LiteralPath $Raiz -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName.Length -gt $Limite }

foreach ($ig in $Ignorar) {
    $alvos = $alvos | Where-Object { $_.FullName -notlike "*$ig*" }
}

Write-Host ("Arquivos fora do limite: {0}" -f @($alvos).Count)
Write-Host ("Modo: {0}" -f $(if ($Aplicar) { "APLICAR" } else { "simulacao (nada sera alterado)" }))
Write-Host ""

$ok = 0
$erros = 0
$impossiveis = 0
$registro = @()

foreach ($f in $alvos) {
    $ext = $f.Extension
    $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    $pasta = $f.DirectoryName

    # 1) nome escolhido a dedo, quando houver: sempre melhor que o corte automatico,
    #    porque preserva o que identifica o documento (numero de processo, data)
    $curado = $null
    if ($exatos.ContainsKey($f.Name)) {
        $curado = $exatos[$f.Name]
    } else {
        foreach ($p in $padroes) {
            if ($f.Name -match $p.regex) { $curado = [regex]::Replace($f.Name, $p.regex, $p.para); break }
        }
    }
    if ($curado) {
        $destinoCurado = $pasta + "\" + $curado
        if ($destinoCurado.Length -le $Limite -and -not (Test-Path -LiteralPath $destinoCurado)) {
            if (-not $Aplicar) {
                Write-Host ("[{0} -> {1} car] (nome escolhido)" -f $f.FullName.Length, $destinoCurado.Length)
                Write-Host ("   de:   {0}" -f $f.Name)
                Write-Host ("   para: {0}" -f $curado)
                $ok++
                continue
            }
            try {
                Rename-Item -LiteralPath $f.FullName -NewName $curado -ErrorAction Stop
                if ((Test-Path -LiteralPath $destinoCurado) -and (-not (Test-Path -LiteralPath $f.FullName))) {
                    Write-Host ("OK [{0} -> {1} car] {2}" -f $f.FullName.Length, $destinoCurado.Length, $curado)
                    $registro += [pscustomobject]@{
                        pasta = $pasta.Substring($Raiz.Length).TrimStart('\')
                        de    = $curado
                        para  = $f.Name
                    }
                    $ok++
                } else {
                    Write-Host ("FALHOU sem erro (o nome nao mudou): {0}" -f $f.Name)
                    $erros++
                }
            } catch {
                Write-Host ("FALHOU: {0} :: {1}" -f $f.Name, $_.Exception.Message)
                $erros++
            }
            continue
        }
        Write-Host ("Nome escolhido nao serve (nao cabe ou ja existe), caindo no corte automatico: {0}" -f $f.Name)
    }

    # 2) corte automatico: tira so o que falta para caber, pelo fim
    $sobra = $f.FullName.Length - $Limite
    $alvoBase = $base.Length - $sobra

    if ($alvoBase -lt $MinimoNome) {
        Write-Host ("NAO CABE (a pasta e que precisa encurtar, {0} car): {1}" -f $f.FullName.Length, $f.Name)
        $impossiveis++
        continue
    }

    $novoBase = $base.Substring(0, $alvoBase)
    # corta numa quebra de palavra, se houver uma razoavelmente perto do fim
    $ultimoEspaco = $novoBase.LastIndexOf(' ')
    if ($ultimoEspaco -ge [math]::Max($MinimoNome, [int]($alvoBase * 0.6))) {
        $novoBase = $novoBase.Substring(0, $ultimoEspaco)
    }
    $novoBase = $novoBase.TrimEnd(' ', '-', '_', ',', '.', '(', '[')
    if ($novoBase.Length -lt $MinimoNome) {
        Write-Host ("NAO CABE depois de aparar: {0}" -f $f.Name)
        $impossiveis++
        continue
    }

    $novoNome = $novoBase + $ext
    $destino = $pasta + "\" + $novoNome

    # colisao: numera, sem estourar de novo o limite
    $n = 2
    while ((Test-Path -LiteralPath $destino) -and ($destino -ne $f.FullName)) {
        $sufixo = " ($n)"
        $corte = [math]::Max($MinimoNome, $novoBase.Length - $sufixo.Length)
        $novoNome = $novoBase.Substring(0, $corte).TrimEnd(' ', '-', '_') + $sufixo + $ext
        $destino = $pasta + "\" + $novoNome
        $n++
        if ($n -gt 20) { break }
    }

    if ($destino.Length -gt $Limite) {
        Write-Host ("NAO CABE nem numerado: {0}" -f $f.Name)
        $impossiveis++
        continue
    }

    if (-not $Aplicar) {
        Write-Host ("[{0} -> {1} car]" -f $f.FullName.Length, $destino.Length)
        Write-Host ("   de:   {0}" -f $f.Name)
        Write-Host ("   para: {0}" -f $novoNome)
        $ok++
        continue
    }

    try {
        Rename-Item -LiteralPath $f.FullName -NewName $novoNome -ErrorAction Stop
        if ((Test-Path -LiteralPath $destino) -and (-not (Test-Path -LiteralPath $f.FullName))) {
            Write-Host ("OK [{0} -> {1} car] {2}" -f $f.FullName.Length, $destino.Length, $novoNome)
            $registro += [pscustomobject]@{
                pasta = $pasta.Substring($Raiz.Length).TrimStart('\')
                de    = $novoNome
                para  = $f.Name
            }
            $ok++
        } else {
            Write-Host ("FALHOU sem erro (o nome nao mudou): {0}" -f $f.Name)
            $erros++
        }
    } catch {
        Write-Host ("FALHOU: {0} :: {1}" -f $f.Name, $_.Exception.Message)
        $erros++
    }
}

Write-Host ""
if ($Aplicar) {
    if ($registro.Count -gt 0) {
        $registro | ConvertTo-Json -Depth 4 | Out-File -LiteralPath $Reversao -Encoding utf8
        Write-Host ("Registro de reversao: {0}" -f $Reversao)
    }
    Write-Host ("Renomeados: {0} | Falhas: {1} | Sem solucao pelo nome: {2}" -f $ok, $erros, $impossiveis)
    if ($erros -gt 0) { exit 1 }
} else {
    Write-Host ("Renomeacoes previstas: {0} | Sem solucao pelo nome: {1}" -f $ok, $impossiveis)
    Write-Host "Rode de novo com -Aplicar para valer."
}
exit 0
