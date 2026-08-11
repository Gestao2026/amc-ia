# Envio de MAO UNICA da pasta mae (_82) para a pasta espelhada do Google Drive.
# Sentido: Area de Trabalho -> Google Drive. O Drive NUNCA escreve na Area de Trabalho.
# Qualquer alteracao feita na Area de Trabalho (incluir, modificar ou apagar) se
# reflete no Drive. A seguranca contra apagar algo que so existe na nuvem (ex: arquivo
# nativo do Google) vem do manifesto: so e apagado no Drive o que o proprio script viu
# existir na Area de Trabalho numa execucao anterior. O que nunca esteve la, fica intocado.
# Em caso de mesmo caminho com tamanho ou data de modificacao diferente, a Area de Trabalho
# vence e sobrescreve a copia no Drive.
#
# Historico das decisoes em .claude/rules/decisoes-tecnicas.md (SOL-0013 a SOL-0018).
# Os caminhos reais ficam em config.local.ps1, fora do controle de versao.

$ErrorActionPreference = "Stop"

# ---------- Configuracao ----------
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $Base "config.local.ps1"
if (-not (Test-Path -LiteralPath $ConfigFile)) {
    Write-Output "ERRO: configuracao nao encontrada em $ConfigFile"
    Write-Output "Copie config.exemplo.ps1 para config.local.ps1 e preencha os caminhos desta maquina."
    exit 1
}
. $ConfigFile

$LogDir = Join-Path $DadosDir "logs"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$LogFile = Join-Path $LogDir "sync_$Timestamp.log"
$EstadoFile = Join-Path $DadosDir "estado.json"
$ManifestFile = Join-Path $DadosDir "manifesto-desktop.json"

function Write-Log($msg) {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Add-Content -Path $LogFile -Value $line -Encoding utf8
}

# Grava o estado da ultima execucao, lido depois pelo vigia (verificar-sincronizacao.ps1).
function Write-Estado($sucesso, $motivo, $paraDrive, $soNoDrive, $conflitos, $apagados, $qtdErros) {
    $estado = [PSCustomObject]@{
        ultima_execucao      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        sucesso              = $sucesso
        motivo               = $motivo
        copiados_para_drive  = $paraDrive
        so_no_drive_ignorados = $soNoDrive
        conflitos_resolvidos = $conflitos
        apagados_no_drive    = $apagados
        erros                = $qtdErros
        log                  = $LogFile
    }
    $estado | ConvertTo-Json | Set-Content -Path $EstadoFile -Encoding utf8
}

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Write-Log "Inicio do envio (mao unica: Area de Trabalho -> Google Drive)"

if (-not (Test-Path -LiteralPath $Desktop)) {
    Write-Log "ERRO: pasta local nao encontrada: $Desktop"
    Write-Estado $false "Pasta da Area de Trabalho nao encontrada: $Desktop" 0 0 0 0 1
    exit 1
}
if (-not (Test-Path -LiteralPath $Drive)) {
    Write-Log "ERRO: pasta do Drive nao encontrada (Google Drive para computador fechado, sem internet, ou compartilhamento removido): $Drive"
    Write-Estado $false "Pasta do Google Drive inacessivel. O app Drive para computador pode estar fechado, sem internet, ou o compartilhamento foi removido." 0 0 0 0 1
    exit 1
}

$copiedToDrive = 0
$somenteNoDrive = 0
$conflitosResolvidos = 0
$apagadosNoDrive = 0
$erros = 0

# ---------- Manifesto da execucao anterior (para saber o que foi apagado) ----------
# Guarda quais arquivos existiam na Area de Trabalho na ultima vez que o script rodou.
# So um arquivo que estava aqui antes e sumiu agora e apagado no Drive. Arquivo que
# nunca esteve na Area de Trabalho (ex: nativo do Google, so na nuvem) nunca entra
# nesta lista e por isso nunca e apagado. Na primeira execucao apos esta mudanca, o
# manifesto ainda nao existe: nada e apagado, so a base e criada.
$manifestoAnterior = @()
if (Test-Path -LiteralPath $ManifestFile) {
    try {
        $lido = Get-Content -LiteralPath $ManifestFile -Encoding utf8 -Raw | ConvertFrom-Json
        $manifestoAnterior = @($lido | Where-Object { $_ -ne $null })
    } catch {
        Write-Log "AVISO: nao foi possivel ler o manifesto anterior, tratando como primeira execucao: $($_.Exception.Message)"
        $manifestoAnterior = @()
    }
}

# ---------- Backup de pastas externas ----------
# Pastas que vivem fora da pasta mae (ex: os dados das OSCs em C:\amc-ia\minhas-oscs)
# ganham uma copia dentro dela, para herdarem o envio ao Drive. Sem isso, esses
# dados nao teriam backup em lugar nenhum.
# Os contadores sao criados ACIMA de proposito: um erro aqui precisa sobreviver
# ate o resumo final, e nao ser zerado depois.
if ($BackupPastas -and $BackupPastas.Count -gt 0) {
    foreach ($b in $BackupPastas) {
        $origem  = $b.Origem
        $destino = Join-Path $Desktop $b.Destino
        if (-not (Test-Path -LiteralPath $origem)) {
            Write-Log "AVISO: origem de backup nao encontrada, ignorada: $origem"
            continue
        }
        try {
            # /MIR aqui e seguro: o destino e uma pasta gerenciada só por este script.
            $r = robocopy $origem $destino /MIR /FFT /R:1 /W:1 /NP /NFL /NDL /NJH /NJS
            # robocopy usa 0 a 7 para sucesso; 8 ou mais e erro real.
            if ($LASTEXITCODE -ge 8) { throw "robocopy retornou $LASTEXITCODE" }
            Write-Log "Backup atualizado: $origem -> $($b.Destino)"
        } catch {
            $erros++
            Write-Log "ERRO no backup de $origem : $($_.Exception.Message)"
        }
    }
}

$filesDesktop = Get-ChildItem -LiteralPath $Desktop -Recurse -File | ForEach-Object {
    [PSCustomObject]@{ Rel = $_.FullName.Substring($Desktop.Length); Length = $_.Length; LastWriteTime = $_.LastWriteTime; Full = $_.FullName }
}
$filesDrive = Get-ChildItem -LiteralPath $Drive -Recurse -File | ForEach-Object {
    [PSCustomObject]@{ Rel = $_.FullName.Substring($Drive.Length); Length = $_.Length; LastWriteTime = $_.LastWriteTime; Full = $_.FullName }
}

$mapDesktop = @{}
foreach ($f in $filesDesktop) { $mapDesktop[$f.Rel] = $f }
$mapDrive = @{}
foreach ($f in $filesDrive) { $mapDrive[$f.Rel] = $f }

# Arquivos que estavam na Area de Trabalho na execucao anterior e sumiram -> apagar no Drive
#
# Circuito de seguranca contra exclusao em massa: protege contra o cenario mais perigoso,
# um problema de leitura da pasta (permissao, antivirus, unidade desconectada no meio da
# varredura) fazer parecer que quase tudo sumiu, e o script apagar isso tudo no Drive por
# engano. So apaga de verdade se a quantidade for compativel com uma limpeza manual normal;
# caso contrario, para, avisa na Area de Trabalho e nao apaga nada.
$AlertaExclusaoFile = Join-Path (Split-Path -Parent $AlertaFile) "ALERTA - EXCLUSAO EM MASSA NA PASTA 82.txt"
$candidatosExclusao = @($manifestoAnterior | Where-Object { -not $mapDesktop.ContainsKey($_) -and $mapDrive.ContainsKey($_) })
$LimiteExclusaoPercentual = 0.30
$LimiteExclusaoMinimo = 15
$bloqueiaExclusaoEmMassa = $false
if ($manifestoAnterior.Count -gt 0 -and $candidatosExclusao.Count -gt $LimiteExclusaoMinimo) {
    $proporcaoExclusao = $candidatosExclusao.Count / $manifestoAnterior.Count
    if ($proporcaoExclusao -gt $LimiteExclusaoPercentual) { $bloqueiaExclusaoEmMassa = $true }
}

if ($bloqueiaExclusaoEmMassa) {
    $pctTexto = [math]::Round($proporcaoExclusao * 100, 1)
    Write-Log "ALERTA: $($candidatosExclusao.Count) de $($manifestoAnterior.Count) arquivos ($pctTexto%) sumiram da Area de Trabalho de uma vez. Por seguranca, NENHUMA exclusao foi feita no Drive nesta execucao."
    $relatorioExclusao = @"
ALERTA. EXCLUSAO EM MASSA DETECTADA NA SINCRONIZACAO DA PASTA _82

Gerado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm')

O QUE ACONTECEU
$($candidatosExclusao.Count) de $($manifestoAnterior.Count) arquivos que existiam na Area de
Trabalho na execucao anterior ($pctTexto%) sumiram de uma vez. Isso pode ser uma limpeza
grande de proposito, ou um problema de leitura da pasta (permissao, antivirus, pasta ou
unidade temporariamente desconectada), que faz parecer que os arquivos sumiram sem terem
sumido de verdade.

O QUE FOI FEITO
Por seguranca, nada foi apagado no Drive nesta execucao. Nenhum dado foi perdido, nem no
computador nem no Drive.

O QUE FAZER
1. Confira se a pasta $Desktop esta acessivel normalmente, com o conteudo esperado.
2. Se a exclusao foi mesmo intencional (uma limpeza grande de proposito), avise para
   liberar a exclusao no Drive.
3. Se nao foi intencional, nao precisa fazer nada, nenhum dado foi apagado.

Alguns dos itens envolvidos (ate 20):
$($candidatosExclusao | Select-Object -First 20 | ForEach-Object { "- $_" } | Out-String)
Este alerta some sozinho na proxima execucao normal (sem exclusao em massa).
"@
    Set-Content -LiteralPath $AlertaExclusaoFile -Value $relatorioExclusao -Encoding utf8
} else {
    if (Test-Path -LiteralPath $AlertaExclusaoFile) {
        Remove-Item -LiteralPath $AlertaExclusaoFile -Force -ErrorAction SilentlyContinue
    }
    foreach ($rel in $candidatosExclusao) {
        try {
            Remove-Item -LiteralPath $mapDrive[$rel].Full -Force -ErrorAction Stop
            $mapDrive.Remove($rel)
            $apagadosNoDrive++
            Write-Log "Apagado no Drive (sumiu da Area de Trabalho): $rel"
        } catch {
            $erros++
            Write-Log "ERRO apagando no Drive ($rel): $($_.Exception.Message)"
        }
    }
}

# Remove pastas que ficaram vazias no Drive por causa das exclusoes acima.
# Ordenado da mais profunda para a mais rasa, para o pai esvaziar antes de ser checado.
# Ignora "desktop.ini": o proprio Google Drive cria esse arquivo oculto sozinho dentro de
# pastas, e sem ignora-lo a pasta nunca pareceria vazia de verdade.
if ($apagadosNoDrive -gt 0) {
    Get-ChildItem -LiteralPath $Drive -Recurse -Directory |
        Sort-Object { $_.FullName.Length } -Descending |
        ForEach-Object {
            $itens = Get-ChildItem -LiteralPath $_.FullName -Force | Where-Object { $_.Name -ne "desktop.ini" }
            if (@($itens).Count -eq 0) {
                try {
                    Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop
                    Write-Log "Pasta vazia removida no Drive: $($_.FullName.Substring($Drive.Length))"
                } catch {
                    Write-Log "AVISO: nao foi possivel remover pasta vazia no Drive ($($_.FullName)): $($_.Exception.Message)"
                }
            }
        }
}

# Arquivos que so existem no Desktop -> copiar para o Drive
foreach ($rel in $mapDesktop.Keys) {
    if (-not $mapDrive.ContainsKey($rel)) {
        # LiteralPath obrigatorio: nomes com colchete ([1], [PRORROGADO]) sao lidos como
        # curinga pelo -Path e a copia nao acontece, mesmo sem erro. Ver SOL-0014.
        $destino = $Drive + $rel
        $destinoDir = [System.IO.Path]::GetDirectoryName($destino)
        try {
            if (-not (Test-Path -LiteralPath $destinoDir)) { New-Item -ItemType Directory -Force -Path $destinoDir | Out-Null }
            Copy-Item -LiteralPath $mapDesktop[$rel].Full -Destination $destino -Force -ErrorAction Stop
            if (-not (Test-Path -LiteralPath $destino)) { throw "a copia nao chegou ao destino" }
            $copiedToDrive++
            Write-Log "Copiado Desktop -> Drive: $rel"
        } catch {
            $erros++
            Write-Log "ERRO copiando Desktop -> Drive ($rel): $($_.Exception.Message)"
        }
    }
}

# MAO UNICA: o bloco que copiava do Drive para o Desktop foi removido em 08/08/2026.
# O Google Drive NUNCA escreve na Area de Trabalho. Arquivo que so existe no Drive fica so la.
foreach ($rel in $mapDrive.Keys) {
    if (-not $mapDesktop.ContainsKey($rel)) {
        $somenteNoDrive++
        Write-Log "Existe so no Drive, ignorado (mao unica): $rel"
    }
}

# Arquivos nos dois lados com tamanho diferente -> Area de Trabalho vence (sobrescreve o
# Drive). So o tamanho e usado como sinal de mudanca: um teste real (10/08/2026) mostrou
# que milhares de arquivos antigos tem data de modificacao diferente nos dois lados mesmo
# com conteudo identico (chegaram em cada lado em momentos diferentes da historia da pasta),
# o que fazia a comparacao por data recopiar arquivos sem necessidade nenhuma.
foreach ($rel in $mapDesktop.Keys) {
    if ($mapDrive.ContainsKey($rel)) {
        $difTamanho = $mapDesktop[$rel].Length -ne $mapDrive[$rel].Length
        if ($difTamanho) {
            try {
                Copy-Item -LiteralPath $mapDesktop[$rel].Full -Destination $mapDrive[$rel].Full -Force -ErrorAction Stop
                $conflitosResolvidos++
                Write-Log "Conteudo diferente, Area de Trabalho venceu, sobrescreveu Drive: $rel"
            } catch {
                $erros++
                Write-Log "ERRO resolvendo conflito ($rel): $($_.Exception.Message)"
            }
        }
    }
}

# Grava o manifesto desta execucao (o que existe agora na Area de Trabalho), para a
# proxima execucao saber o que foi apagado.
try {
    ConvertTo-Json -InputObject @($mapDesktop.Keys) | Set-Content -Path $ManifestFile -Encoding utf8
} catch {
    Write-Log "AVISO: nao foi possivel salvar o manifesto desta execucao: $($_.Exception.Message)"
}

Write-Log "Resumo: $copiedToDrive copiados p/ Drive | $somenteNoDrive nunca estiveram na Area de Trabalho, ignorados | $conflitosResolvidos conflitos resolvidos (Area de Trabalho venceu) | $apagadosNoDrive apagados no Drive (sumiram da Area de Trabalho) | $erros erros"
Write-Log "Fim do envio"

Write-Estado ($erros -eq 0) $(if ($erros -eq 0) { "Envio concluido sem erros" } else { "Envio concluido com $erros erro(s), ver o log" }) $copiedToDrive $somenteNoDrive $conflitosResolvidos $apagadosNoDrive $erros

Write-Output "Copiados para o Drive: $copiedToDrive"
Write-Output "Nunca estiveram na Area de Trabalho, ignorados: $somenteNoDrive"
Write-Output "Conflitos resolvidos (Area de Trabalho venceu): $conflitosResolvidos"
Write-Output "Apagados no Drive (sumiram da Area de Trabalho): $apagadosNoDrive"
Write-Output "Erros: $erros"
Write-Output "Log completo: $LogFile"
