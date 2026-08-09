# Vigia da sincronizacao da pasta _82.
# Le o estado da ultima execucao e, se a sincronizacao nao esta acontecendo,
# monta um relatorio de alerta, mostra notificacao no Windows e (se configurado) envia por e-mail.
# Nao altera nenhum arquivo da pasta _82. So observa e avisa. Ver SOL-0015.

$ErrorActionPreference = "Continue"

# ---------- Configuracao ----------
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $Base "config.local.ps1"
if (-not (Test-Path -LiteralPath $ConfigFile)) {
    Write-Output "ERRO: configuracao nao encontrada em $ConfigFile"
    exit 1
}
. $ConfigFile

$EstadoFile = Join-Path $DadosDir "estado.json"
$EnvFile    = Join-Path $DadosDir ".env"
$LogVigia   = Join-Path $DadosDir "logs\vigia.log"

function Log-Vigia($msg) {
    Add-Content -Path $LogVigia -Value ("$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg") -Encoding utf8
}

# ---------- 1. Diagnostico ----------
$problema = $false
$motivo   = ""
$detalhe  = ""
$resumoUltima = "(sem dados da ultima execucao)"

if (-not (Test-Path -LiteralPath $EstadoFile)) {
    $problema = $true
    $motivo   = "Nunca houve uma execucao registrada"
    $detalhe  = "O arquivo de estado ($EstadoFile) nao existe. A sincronizacao pode nunca ter rodado desde a ultima mudanca."
} else {
    try {
        $e = Get-Content -LiteralPath $EstadoFile -Raw -Encoding utf8 | ConvertFrom-Json
        $ultima = [datetime]::ParseExact($e.ultima_execucao, "yyyy-MM-dd HH:mm:ss", $null)
        $horas  = [math]::Round(((Get-Date) - $ultima).TotalHours, 1)

        if (-not $e.sucesso) {
            $problema = $true
            $motivo   = "A ultima sincronizacao falhou"
            $detalhe  = "Motivo registrado: $($e.motivo)`r`nLog detalhado: $($e.log)"
        } elseif ($e.erros -gt 0) {
            $problema = $true
            $motivo   = "A ultima sincronizacao terminou com $($e.erros) erro(s)"
            $detalhe  = "Alguns arquivos podem nao ter subido.`r`nLog detalhado: $($e.log)"
        } elseif ($horas -gt $LimiteHoras) {
            $problema = $true
            $motivo   = "Sem sincronizar ha $horas horas"
            $detalhe  = "A ultima execucao com sucesso foi em $($e.ultima_execucao). O limite de tolerancia e de $LimiteHoras horas.`r`nCausas comuns: laptop desligado por muito tempo, app do Google Drive fechado, sem internet, ou o compartilhamento da pasta foi removido."
        }
        $resumoUltima = "Ultima execucao: $($e.ultima_execucao) (ha $horas horas)`r`nArquivos enviados ao Drive: $($e.copiados_para_drive)`r`nConflitos resolvidos: $($e.conflitos_resolvidos)`r`nErros: $($e.erros)"
    } catch {
        $problema = $true
        $motivo   = "Nao foi possivel ler o estado da sincronizacao"
        $detalhe  = "Erro ao ler $EstadoFile : $($_.Exception.Message)"
    }
}

# ---------- 2. Tudo certo: limpa alerta antigo e sai ----------
if (-not $problema) {
    if (Test-Path -LiteralPath $AlertaFile) {
        Remove-Item -LiteralPath $AlertaFile -Force -ErrorAction SilentlyContinue
        Log-Vigia "Situacao normalizada, alerta anterior removido."
    }
    Log-Vigia ("OK. " + $resumoUltima.Replace("`r`n", " | "))
    Write-Output "OK: sincronizacao em dia."
    exit 0
}

# ---------- 3. Monta o relatorio ----------
$relatorio = @"
ALERTA. A SINCRONIZACAO DA PASTA _82 NAO ESTA ACONTECENDO

Gerado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm')
Computador: $env:COMPUTERNAME

PROBLEMA
$motivo

DETALHE
$detalhe

SITUACAO ATUAL
$resumoUltima

O QUE ISSO SIGNIFICA
Os arquivos salvos na pasta mae, na Area de Trabalho, podem nao ter copia no
Google Drive. O trabalho nao foi perdido, ele esta no computador, mas esta sem
backup na nuvem ate isso ser resolvido.

O QUE VERIFICAR, NESTA ORDEM
1. O app Google Drive para computador esta aberto e conectado? (icone perto do relogio)
2. A unidade G: aparece no Explorador de Arquivos?
3. Tem internet?
4. O compartilhamento da pasta continua ativo?

COMO FORCAR UMA SINCRONIZACAO AGORA
Abrir o Agendador de Tarefas do Windows, localizar a tarefa
AMC-IA-Sincronizar-Pasta82 e clicar em Executar.

Este alerta some sozinho assim que a sincronizacao voltar ao normal.
"@

Set-Content -LiteralPath $AlertaFile -Value $relatorio -Encoding utf8
Log-Vigia "ALERTA gerado. Motivo: $motivo"

# ---------- 4. Notificacao no Windows ----------
try {
    Add-Type -AssemblyName System.Windows.Forms
    $ni = New-Object System.Windows.Forms.NotifyIcon
    $ni.Icon = [System.Drawing.SystemIcons]::Warning
    $ni.BalloonTipTitle = "Pasta _82 sem sincronizar"
    $ni.BalloonTipText  = "$motivo. Veja o arquivo de alerta na Area de Trabalho."
    $ni.Visible = $true
    $ni.ShowBalloonTip(20000)
    Start-Sleep -Seconds 12
    $ni.Dispose()
} catch {
    Log-Vigia "Nao foi possivel mostrar a notificacao: $($_.Exception.Message)"
}

# ---------- 5. E-mail (so se as credenciais estiverem no .env) ----------
# O .env vive em $DadosDir, fora do repositorio. NUNCA versionar nem exibir seu conteudo.
# Chaves esperadas: SMTP_USUARIO, SMTP_SENHA_APP, ALERTA_DESTINO
if (Test-Path -LiteralPath $EnvFile) {
    $cfg = @{}
    Get-Content -LiteralPath $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([A-Z_]+)\s*=\s*(.+?)\s*$') { $cfg[$matches[1]] = $matches[2] }
    }
    if ($cfg.SMTP_USUARIO -and $cfg.SMTP_SENHA_APP -and $cfg.ALERTA_DESTINO) {
        try {
            $sec = ConvertTo-SecureString $cfg.SMTP_SENHA_APP -AsPlainText -Force
            $cred = New-Object System.Management.Automation.PSCredential($cfg.SMTP_USUARIO, $sec)
            Send-MailMessage -To $cfg.ALERTA_DESTINO -From $cfg.SMTP_USUARIO `
                -Subject "ALERTA: pasta _82 sem sincronizar com o Google Drive" `
                -Body $relatorio -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl `
                -Credential $cred -Encoding UTF8 -ErrorAction Stop
            Log-Vigia "E-mail de alerta enviado para $($cfg.ALERTA_DESTINO)."
            Write-Output "E-mail de alerta enviado."
        } catch {
            Log-Vigia "FALHA ao enviar e-mail: $($_.Exception.Message)"
            Write-Output "Falha ao enviar o e-mail de alerta. Ver $LogVigia"
        }
    } else {
        Log-Vigia "E-mail nao enviado: .env existe mas falta SMTP_USUARIO, SMTP_SENHA_APP ou ALERTA_DESTINO."
    }
} else {
    Log-Vigia "E-mail nao enviado: .env nao configurado (envio por e-mail desativado)."
}

Write-Output "ALERTA: $motivo"
Write-Output "Relatorio salvo em: $AlertaFile"
exit 2
