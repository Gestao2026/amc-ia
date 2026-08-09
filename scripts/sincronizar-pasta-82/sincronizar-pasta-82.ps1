# Envio de MAO UNICA da pasta mae (_82) para a pasta espelhada do Google Drive.
# Sentido: Area de Trabalho -> Google Drive. O Drive NUNCA escreve na Area de Trabalho.
# Regra de seguranca: NUNCA apaga arquivo, em nenhum dos dois lados.
# Em caso de mesmo caminho com tamanho diferente, a Area de Trabalho vence e sobrescreve a copia no Drive.
#
# Historico das decisoes em .claude/rules/decisoes-tecnicas.md (SOL-0013, SOL-0014 e SOL-0015).
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

function Write-Log($msg) {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Add-Content -Path $LogFile -Value $line -Encoding utf8
}

# Grava o estado da ultima execucao, lido depois pelo vigia (verificar-sincronizacao.ps1).
function Write-Estado($sucesso, $motivo, $paraDrive, $soNoDrive, $conflitos, $qtdErros) {
    $estado = [PSCustomObject]@{
        ultima_execucao      = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        sucesso              = $sucesso
        motivo               = $motivo
        copiados_para_drive  = $paraDrive
        so_no_drive_ignorados = $soNoDrive
        conflitos_resolvidos = $conflitos
        erros                = $qtdErros
        log                  = $LogFile
    }
    $estado | ConvertTo-Json | Set-Content -Path $EstadoFile -Encoding utf8
}

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Write-Log "Inicio do envio (mao unica: Area de Trabalho -> Google Drive)"

if (-not (Test-Path -LiteralPath $Desktop)) {
    Write-Log "ERRO: pasta local nao encontrada: $Desktop"
    Write-Estado $false "Pasta da Area de Trabalho nao encontrada: $Desktop" 0 0 0 1
    exit 1
}
if (-not (Test-Path -LiteralPath $Drive)) {
    Write-Log "ERRO: pasta do Drive nao encontrada (Google Drive para computador fechado, sem internet, ou compartilhamento removido): $Drive"
    Write-Estado $false "Pasta do Google Drive inacessivel. O app Drive para computador pode estar fechado, sem internet, ou o compartilhamento foi removido." 0 0 0 1
    exit 1
}

$copiedToDrive = 0
$somenteNoDrive = 0
$conflitosResolvidos = 0
$erros = 0

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
    [PSCustomObject]@{ Rel = $_.FullName.Substring($Desktop.Length); Length = $_.Length; Full = $_.FullName }
}
$filesDrive = Get-ChildItem -LiteralPath $Drive -Recurse -File | ForEach-Object {
    [PSCustomObject]@{ Rel = $_.FullName.Substring($Drive.Length); Length = $_.Length; Full = $_.FullName }
}

$mapDesktop = @{}
foreach ($f in $filesDesktop) { $mapDesktop[$f.Rel] = $f }
$mapDrive = @{}
foreach ($f in $filesDrive) { $mapDrive[$f.Rel] = $f }

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

# Arquivos nos dois lados com tamanho diferente -> Area de Trabalho vence (sobrescreve o Drive)
foreach ($rel in $mapDesktop.Keys) {
    if ($mapDrive.ContainsKey($rel)) {
        if ($mapDesktop[$rel].Length -ne $mapDrive[$rel].Length) {
            try {
                Copy-Item -LiteralPath $mapDesktop[$rel].Full -Destination $mapDrive[$rel].Full -Force -ErrorAction Stop
                $conflitosResolvidos++
                Write-Log "Conflito (tamanho diferente), Area de Trabalho venceu, sobrescreveu Drive: $rel"
            } catch {
                $erros++
                Write-Log "ERRO resolvendo conflito ($rel): $($_.Exception.Message)"
            }
        }
    }
}

Write-Log "Resumo: $copiedToDrive copiados p/ Drive | $somenteNoDrive existiam so no Drive e foram ignorados (mao unica) | $conflitosResolvidos conflitos resolvidos (Area de Trabalho venceu) | $erros erros"
Write-Log "Fim do envio"

Write-Estado ($erros -eq 0) $(if ($erros -eq 0) { "Envio concluido sem erros" } else { "Envio concluido com $erros erro(s), ver o log" }) $copiedToDrive $somenteNoDrive $conflitosResolvidos $erros

Write-Output "Copiados para o Drive: $copiedToDrive"
Write-Output "Existiam so no Drive, ignorados (mao unica): $somenteNoDrive"
Write-Output "Conflitos resolvidos (Area de Trabalho venceu): $conflitosResolvidos"
Write-Output "Erros: $erros"
Write-Output "Log completo: $LogFile"
