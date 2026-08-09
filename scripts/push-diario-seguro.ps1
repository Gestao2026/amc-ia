# Push diario COM GUARDA + relatorio das automacoes.
#
# Roda de madrugada. Antes de publicar qualquer coisa no GitHub, varre o conteudo
# que seria publicado. Se achar algo suspeito (segredo, dado de cliente, caminho
# pessoal, arquivo que deveria estar protegido), NAO publica e explica o motivo.
#
# Contexto que justifica a guarda: o repositorio github.com/Gestao2026/amc-ia e
# PUBLICO. Ver SOL-0016 e SOL-0017 em .claude/rules/decisoes-tecnicas.md.
#
# Uso:
#   push-diario-seguro.ps1              execucao normal
#   push-diario-seguro.ps1 -Autoteste   so testa o detector, nao publica nada
#   push-diario-seguro.ps1 -SoVerificar varre e relata, mas nunca publica

param(
    [switch]$Autoteste,
    [switch]$SoVerificar
)

$ErrorActionPreference = "Continue"

$Repo        = "C:\amc-ia"
$RelatorioDir = Join-Path $Repo "logs\push-diario"
$AlertaFile  = "C:\Users\rosep\Desktop\ALERTA - PUBLICACAO NO GITHUB BLOQUEADA.txt"
$EstadoSync  = "C:\Users\rosep\Scripts\sincronizar-pasta-82\estado.json"

# E-mails que podem aparecer no codigo sem gerar alarme.
$EmailsPermitidos = @("gestao.mobilizando@gmail.com", "noreply@anthropic.com")

# ---------------------------------------------------------------
# DETECTOR. Recebe texto e devolve a lista de achados suspeitos.
# ---------------------------------------------------------------
function Find-Suspeitos($texto) {
    $achados = @()

    $regras = @(
        @{ Nome = "Token JWT (padrao de token do Supabase/CaptaHub)"; Regex = 'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}' },
        @{ Nome = "Chave de API da OpenAI";                           Regex = 'sk-[A-Za-z0-9]{20,}' },
        @{ Nome = "Token do GitHub";                                  Regex = '\bgh[pousr]_[A-Za-z0-9]{20,}' },
        @{ Nome = "Chave da AWS";                                     Regex = '\bAKIA[0-9A-Z]{16}\b' },
        @{ Nome = "Token do Telegram";                                Regex = '\b\d{8,10}:[A-Za-z0-9_-]{30,}\b' },
        @{ Nome = "Senha ou token escrito no codigo";                 Regex = '(?i)(senha|password|secret|api[_-]?key|token)\s*=\s*["'']?[A-Za-z0-9_\-]{16,}' },
        @{ Nome = "CPF";                                              Regex = '\b\d{3}\.\d{3}\.\d{3}-\d{2}\b' },
        @{ Nome = "CNPJ";                                             Regex = '\b\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}\b' },
        @{ Nome = "Identificador de pasta do Google Drive";           Regex = '\b1[A-Za-z0-9_-]{32,}\b' },
        @{ Nome = "Conta bancaria (agencia e conta)";                 Regex = '(?i)ag[eê]ncia\s*:?\s*\d{4}' }
    )

    foreach ($r in $regras) {
        $m = [regex]::Matches($texto, $r.Regex)
        if ($m.Count -gt 0) {
            $exemplo = $m[0].Value
            if ($exemplo.Length -gt 12) { $exemplo = $exemplo.Substring(0,6) + "..." + $exemplo.Substring($exemplo.Length-4) }
            $achados += "$($r.Nome)  (ex: $exemplo, $($m.Count) ocorrencia(s))"
        }
    }

    # E-mail de terceiro
    $emails = [regex]::Matches($texto, '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}') |
              ForEach-Object { $_.Value.ToLowerInvariant() } | Sort-Object -Unique
    foreach ($e in $emails) {
        if ($EmailsPermitidos -notcontains $e) { $achados += "E-mail de terceiro: $e" }
    }

    return $achados
}

# ---------------------------------------------------------------
# AUTOTESTE. Prova que o detector funciona, sem publicar nada.
# ---------------------------------------------------------------
if ($Autoteste) {
    Write-Output "AUTOTESTE DO DETECTOR"
    Write-Output ""
    # As amostras sao montadas em pedacos de proposito. Se os padroes aparecessem
    # inteiros aqui, o proprio detector bloquearia a publicacao deste arquivo,
    # o que de fato aconteceu na primeira versao. Ver SOL-0017.
    $arroba = [char]64
    $amostras = @(
        @{ Desc = "Texto limpo, sem nada suspeito"; Txt = "Este e um texto normal de documentacao do projeto." },
        @{ Desc = "CPF";                            Txt = "O representante legal tem CPF " + "123.456.789" + "-00." },
        @{ Desc = "CNPJ";                           Txt = "A OSC tem CNPJ " + "00.000.000" + "/0001-00." },
        @{ Desc = "Token JWT";                      Txt = "TOKEN_DE_EXEMPLO=" + "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" + "." + "eyJzdWIiOiJFWEVNUExPIn0" },
        @{ Desc = "Id de pasta do Google Drive";    Txt = "Destino: " + "1" + ("A" * 33) },
        @{ Desc = "E-mail de terceiro";             Txt = "Compartilhado com fulano.teste" + $arroba + "exemplo.com" },
        @{ Desc = "E-mail permitido (nao alarma)";  Txt = "Contato: gestao.mobilizando" + $arroba + "gmail.com" }
    )
    foreach ($a in $amostras) {
        $r = Find-Suspeitos $a.Txt
        $status = if ($r.Count) { "DETECTOU" } else { "limpo" }
        Write-Output ("{0,-10} {1}" -f $status, $a.Desc)
        foreach ($x in $r) { Write-Output ("             -> " + $x) }
    }
    exit 0
}

# ---------------------------------------------------------------
# 1. Situacao do repositorio
# ---------------------------------------------------------------
Set-Location $Repo
New-Item -ItemType Directory -Force -Path $RelatorioDir | Out-Null

$statusCurto = (git status --short) -join "`r`n"
$pendentes   = git log --oneline "origin/main..HEAD"
$qtdPendentes = if ($pendentes) { @($pendentes).Count } else { 0 }

$bloqueado = $false
$achados = @()
$resultadoPush = ""

if ($qtdPendentes -eq 0) {
    $resultadoPush = "NADA A FAZER. Nao havia alteracao nova para publicar."
} else {
    # ---------------------------------------------------------------
    # 2. Varredura do que seria publicado
    # ---------------------------------------------------------------
    $conteudo = (git diff "origin/main..HEAD") -join "`n"
    $achados += Find-Suspeitos $conteudo

    # Arquivos que nunca podem ser publicados, mesmo que o conteudo pareca inofensivo
    $arquivos = git diff --name-only "origin/main..HEAD"
    $proibidos = @('\.env$', 'config\.local\.', '\.pem$', '\.key$', 'credenciais', 'senha')
    foreach ($a in $arquivos) {
        foreach ($p in $proibidos) {
            if ($a -match $p) { $achados += "Arquivo que nao pode ser publicado: $a" }
        }
        # Dados reais de OSC: so o exemplo e o modelo sao permitidos
        if ($a -match '^minhas-oscs/' -and $a -notmatch 'exemplo-instituto-semente' -and $a -notmatch 'MODELO-perfil-osc') {
            $achados += "Dado real de cliente: $a"
        }
    }

    $achados = $achados | Sort-Object -Unique

    if ($achados.Count -gt 0) {
        $bloqueado = $true
        $resultadoPush = "BLOQUEADO. Encontrei $($achados.Count) item(ns) suspeito(s). Nada foi publicado."
    } elseif ($SoVerificar) {
        $resultadoPush = "VERIFICADO E LIMPO. Modo de verificacao, nao publiquei."
    } else {
        $saida = git push origin main 2>&1
        if ($LASTEXITCODE -eq 0) {
            $resultadoPush = "PUBLICADO COM SUCESSO. $qtdPendentes alteracao(oes) enviada(s) ao GitHub."
        } else {
            $resultadoPush = "FALHOU AO PUBLICAR. Motivo: " + (($saida | Select-Object -Last 3) -join " | ")
        }
    }
}

# ---------------------------------------------------------------
# 3. Situacao das outras automacoes
# ---------------------------------------------------------------
function Estado-Tarefa($nome) {
    try {
        $i = Get-ScheduledTaskInfo -TaskName $nome -ErrorAction Stop
        $ok = if ($i.LastTaskResult -eq 0) { "sucesso" } else { "FALHOU (codigo $($i.LastTaskResult))" }
        return "$nome`r`n      Ultima execucao: $($i.LastRunTime)  ->  $ok`r`n      Proxima: $($i.NextRunTime)"
    } catch { return "$nome`r`n      NAO ENCONTRADA. A tarefa pode ter sido apagada." }
}

$blocoSync = "Sincronizacao da pasta _82: sem dados"
if (Test-Path -LiteralPath $EstadoSync) {
    try {
        $e = Get-Content -LiteralPath $EstadoSync -Raw -Encoding utf8 | ConvertFrom-Json
        $h = [math]::Round(((Get-Date) - [datetime]::ParseExact($e.ultima_execucao,"yyyy-MM-dd HH:mm:ss",$null)).TotalHours,1)
        $st = if ($e.sucesso -and $e.erros -eq 0) { "sucesso" } else { "COM PROBLEMA: $($e.motivo)" }
        $blocoSync = "Ultima execucao: $($e.ultima_execucao) (ha $h horas)  ->  $st`r`n      Arquivos enviados ao Drive: $($e.copiados_para_drive)  |  Erros: $($e.erros)"
    } catch { $blocoSync = "Nao foi possivel ler o estado: $($_.Exception.Message)" }
}

# ---------------------------------------------------------------
# 4. Relatorio
# ---------------------------------------------------------------
$hoje = Get-Date -Format "yyyy-MM-dd"
$rel = @()
$rel += "RELATORIO DIARIO DAS AUTOMACOES"
$rel += "Gerado em $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
$rel += ""
$rel += "=================================================="
$rel += "1. PUBLICACAO NO GITHUB"
$rel += "=================================================="
$rel += "   $resultadoPush"
if ($qtdPendentes -gt 0) {
    $rel += ""
    $rel += "   Alteracoes envolvidas:"
    foreach ($c in $pendentes) { $rel += "      $c" }
}
if ($bloqueado) {
    $rel += ""
    $rel += "   O QUE ME FEZ PARAR:"
    foreach ($a in $achados) { $rel += "      - $a" }
    $rel += ""
    $rel += "   O QUE FAZER: nada foi perdido, suas alteracoes continuam salvas no"
    $rel += "   computador. Peca a revisao na proxima conversa. Se for alarme falso,"
    $rel += "   a publicacao pode ser liberada manualmente."
}
$rel += ""
$rel += "=================================================="
$rel += "2. SINCRONIZACAO DA PASTA _82 COM O GOOGLE DRIVE"
$rel += "=================================================="
$rel += "   $blocoSync"
$rel += ""
$rel += "=================================================="
$rel += "3. TAREFAS AGENDADAS"
$rel += "=================================================="
foreach ($t in @('AMC-IA-Sincronizar-Pasta82','AMC-IA-Vigia-Pasta82','AMC-IA-SincronizacaoDiaria','AMC-IA-Push-Diario')) {
    $rel += "   " + (Estado-Tarefa $t)
}
$rel += ""
if ($statusCurto) {
    $rel += "=================================================="
    $rel += "4. ARQUIVOS ALTERADOS E AINDA NAO SALVOS"
    $rel += "=================================================="
    $rel += $statusCurto
}

$arquivoRel = Join-Path $RelatorioDir "relatorio-$hoje.txt"
Set-Content -LiteralPath $arquivoRel -Value ($rel -join "`r`n") -Encoding utf8

# Alerta na Area de Trabalho so quando algo exige acao dela.
if ($bloqueado) {
    Set-Content -LiteralPath $AlertaFile -Value ($rel -join "`r`n") -Encoding utf8
} elseif (Test-Path -LiteralPath $AlertaFile) {
    Remove-Item -LiteralPath $AlertaFile -Force -ErrorAction SilentlyContinue
}

Write-Output $resultadoPush
Write-Output "Relatorio: $arquivoRel"
if ($bloqueado) { exit 2 } else { exit 0 }
