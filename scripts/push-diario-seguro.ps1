# Push COM GUARDA + relatorio das automacoes.
#
# Antes de publicar qualquer coisa no GitHub, varre o conteudo que seria publicado.
# Se achar algo suspeito (segredo, dado de cliente, caminho pessoal, arquivo que
# deveria estar protegido), NAO publica e explica o motivo.
#
# Nao roda mais sozinho de madrugada: a tarefa das 02h foi apagada em 13/08/2026
# (SOL-0022) e a publicacao voltou a ser sempre por pedido. Hoje ele e acionado
# pelo hook post-commit (modo -PosCommit, so avisa) e por pedido em conversa.
#
# Contexto que justifica a guarda: o repositorio github.com/Gestao2026/amc-ia e
# PUBLICO. Ver SOL-0016, SOL-0017 e SOL-0022 em .claude/rules/decisoes-tecnicas.md.
#
# Uso:
#   push-diario-seguro.ps1              execucao normal
#   push-diario-seguro.ps1 -Autoteste   so testa o detector, nao publica nada
#   push-diario-seguro.ps1 -SoVerificar varre e relata, mas nunca publica
#   push-diario-seguro.ps1 -Liberar     publica mesmo com achado suspeito, so depois
#                                        de a captadora ter revisado e confirmado que
#                                        e falso alarme (ex: e-mail institucional do
#                                        proprio edital, CNPJ publico do patrocinador).
#                                        O achado continua aparecendo no relatorio,
#                                        marcado como liberado manualmente. Nunca usar
#                                        sem ter revisado o achado com ela primeiro.

param(
    [switch]$Autoteste,
    [switch]$SoVerificar,
    [switch]$PosCommit,  # usado pelo vigia do commit: so varre e avisa, nao gera relatorio nem alerta
    [switch]$Liberar
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
# ARQUIVO BINARIO. O detector acima le o texto do 'git diff', e Word, Excel e
# PowerPoint nao aparecem la: o Git tenta converter com docx2txt.exe, que nao
# existe nesta maquina, e o diff volta vazio. Sem isto, um .docx com dado de
# cliente seria publicado sem a varredura nem perceber. Como sao pacotes zip,
# da para ler o texto direto do XML de dentro.
# ---------------------------------------------------------------
function Texto-De-Pacote($caminho) {
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
        $zip = [System.IO.Compression.ZipFile]::OpenRead($caminho)
        $partes = @()
        foreach ($item in $zip.Entries) {
            if ($item.FullName -notmatch '\.(xml|rels)$') { continue }
            $leitor = New-Object System.IO.StreamReader($item.Open())
            $partes += $leitor.ReadToEnd()
            $leitor.Close()
        }
        $zip.Dispose()
        # Tira as marcacoes e deixa so o texto que a pessoa leria
        return ($partes -join " ") -replace '<[^>]+>', ' '
    } catch {
        return $null
    }
}

function Achados-Em-Binarios($arquivos) {
    $r = @()
    foreach ($a in $arquivos) {
        if ($a -notmatch '\.(docx|dotx|xlsx|pptx)$') { continue }
        $caminho = Join-Path $Repo $a
        if (-not (Test-Path -LiteralPath $caminho)) { continue }   # apagado no commit
        $texto = Texto-De-Pacote $caminho
        if ($null -eq $texto) {
            # Nao conseguir ler nao pode virar silencio: e justamente o caso perigoso
            $r += "Nao consegui ler o conteudo de $a para varrer. Revise a mao antes de publicar."
            continue
        }
        foreach ($x in (Find-Suspeitos $texto)) { $r += "$x  [dentro de $a]" }
    }
    return $r
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
# VIGIA DO COMMIT. Roda pelo hook post-commit, a cada alteracao salva.
# Só varre e avisa na hora, para o problema aparecer no momento em que foi
# criado, e nao so as 02h. Nao escreve relatorio nem alerta, para nao encher
# a Area de Trabalho durante o trabalho normal.
# ---------------------------------------------------------------
if ($PosCommit) {
    Set-Location $Repo
    $pend = git log --oneline "origin/main..HEAD"
    if (-not $pend) { Write-Output "Vigia do commit: nada pendente."; exit 0 }

    $conteudo = (git diff "origin/main..HEAD") -join "`n"
    $r = Find-Suspeitos $conteudo
    $r += Achados-Em-Binarios (git diff --name-only "origin/main..HEAD")
    foreach ($a in (git diff --name-only "origin/main..HEAD")) {
        foreach ($p in @('\.env$', 'config\.local\.', '\.pem$', '\.key$', 'credenciais', 'senha')) {
            if ($a -match $p) { $r += "Arquivo que nao pode ser publicado: $a" }
        }
        if ($a -match '^minhas-oscs/' -and $a -notmatch 'exemplo-instituto-semente' -and $a -notmatch 'MODELO-perfil-osc' -and $a -ne 'minhas-oscs/.ativa') {
            $r += "Dado real de cliente: $a"
        }
    }
    $r = $r | Sort-Object -Unique

    if ($r.Count -gt 0) {
        Write-Output ""
        Write-Output "  ATENCAO, O VIGIA DO COMMIT ACHOU $($r.Count) ITEM(NS) SUSPEITO(S):"
        foreach ($x in $r) { Write-Output "     - $x" }
        Write-Output ""
        Write-Output "  O commit foi salvo, mas a publicacao no GitHub vai BLOQUEAR isso."
        Write-Output "  Reveja antes de seguir."
        Write-Output ""
        exit 2
    }
    Write-Output "Vigia do commit: limpo. $(@($pend).Count) alteracao(oes) pronta(s) para publicar."
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

# Tudo que exigir uma acao dela entra aqui. Se a lista terminar vazia, nenhum
# alerta e criado. Se nao, vira arquivo na Area de Trabalho mais notificacao,
# no mesmo modelo do vigia da pasta _82. A ideia e ela nunca precisar lembrar
# de pedir nada manualmente.
$pendencias = @()

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
    $achados += Achados-Em-Binarios $arquivos
    $proibidos = @('\.env$', 'config\.local\.', '\.pem$', '\.key$', 'credenciais', 'senha')
    foreach ($a in $arquivos) {
        foreach ($p in $proibidos) {
            if ($a -match $p) { $achados += "Arquivo que nao pode ser publicado: $a" }
        }
        # Dados reais de OSC: so o exemplo, o modelo e o marcador de OSC ativa
        # (minhas-oscs/.ativa so guarda o slug da pasta, sem documento nenhum,
        # e ja era publicado desde o inicio do projeto) sao permitidos.
        if ($a -match '^minhas-oscs/' -and $a -notmatch 'exemplo-instituto-semente' -and $a -notmatch 'MODELO-perfil-osc' -and $a -ne 'minhas-oscs/.ativa') {
            $achados += "Dado real de cliente: $a"
        }
    }

    $achados = $achados | Sort-Object -Unique

    if ($achados.Count -gt 0 -and -not $Liberar) {
        $bloqueado = $true
        $resultadoPush = "BLOQUEADO. Encontrei $($achados.Count) item(ns) suspeito(s). Nada foi publicado."
        $pendencias += "A publicacao no GitHub foi bloqueada por $($achados.Count) item(ns) suspeito(s). Precisa de revisao."
    } elseif ($SoVerificar) {
        $resultadoPush = "VERIFICADO E LIMPO. Modo de verificacao, nao publiquei."
        if ($achados.Count -gt 0) { $resultadoPush = "VERIFICADO. Encontrei $($achados.Count) item(ns) suspeito(s). Modo de verificacao, nao publiquei." }
    } else {
        $saida = git push origin main 2>&1
        if ($LASTEXITCODE -eq 0) {
            if ($achados.Count -gt 0) {
                $resultadoPush = "PUBLICADO COM LIBERACAO MANUAL. $qtdPendentes alteracao(oes) enviada(s) ao GitHub, apesar de $($achados.Count) achado(s) (revisado(s) e liberado(s) por pedido explicito)."
            } else {
                $resultadoPush = "PUBLICADO COM SUCESSO. $qtdPendentes alteracao(oes) enviada(s) ao GitHub."
            }
        } else {
            $motivo = (($saida | Select-Object -Last 3) -join " | ")
            $resultadoPush = "FALHOU AO PUBLICAR. Motivo: $motivo"
            $pendencias += "A publicacao no GitHub falhou. Motivo: $motivo"
        }
    }
}

# ---------------------------------------------------------------
# 3. Situacao das outras automacoes
# ---------------------------------------------------------------
function Estado-Tarefa($nome) {
    try {
        $i = Get-ScheduledTaskInfo -TaskName $nome -ErrorAction Stop
        # 267011 = ainda nao rodou nenhuma vez. 267009 = esta rodando agora.
        # Nenhum dos dois e falha, e tratar como falha geraria alarme falso.
        $ok = switch ($i.LastTaskResult) {
            0      { "sucesso" }
            267011 { "ainda nao rodou nenhuma vez" }
            267009 { "esta rodando agora" }
            default { "FALHOU (codigo $($i.LastTaskResult))" }
        }
        $quando = if ($i.LastTaskResult -eq 267011) { "-" } else { $i.LastRunTime }
        if (@(0, 267011, 267009) -notcontains $i.LastTaskResult) {
            $script:pendencias += "A tarefa automatica '$nome' falhou na ultima execucao (codigo $($i.LastTaskResult))"
        }
        return "$nome`r`n      Ultima execucao: $quando  ->  $ok`r`n      Proxima: $($i.NextRunTime)"
    } catch {
        $script:pendencias += "A tarefa automatica '$nome' nao existe mais. Pode ter sido apagada."
        return "$nome`r`n      NAO ENCONTRADA. A tarefa pode ter sido apagada."
    }
}

$blocoSync = "Sincronizacao da pasta _82: sem dados"
if (Test-Path -LiteralPath $EstadoSync) {
    try {
        $e = Get-Content -LiteralPath $EstadoSync -Raw -Encoding utf8 | ConvertFrom-Json
        $h = [math]::Round(((Get-Date) - [datetime]::ParseExact($e.ultima_execucao,"yyyy-MM-dd HH:mm:ss",$null)).TotalHours,1)
        $st = if ($e.sucesso -and $e.erros -eq 0) { "sucesso" } else { "COM PROBLEMA: $($e.motivo)" }
        $blocoSync = "Ultima execucao: $($e.ultima_execucao) (ha $h horas)  ->  $st`r`n      Arquivos enviados ao Drive: $($e.copiados_para_drive)  |  Erros: $($e.erros)"
        if (-not $e.sucesso -or $e.erros -gt 0) { $pendencias += "A sincronizacao da pasta _82 falhou: $($e.motivo)" }
        elseif ($h -gt 24) { $pendencias += "A pasta _82 esta ha $h horas sem sincronizar com o Google Drive" }
    } catch {
        $blocoSync = "Nao foi possivel ler o estado: $($_.Exception.Message)"
        $pendencias += "Nao consegui ler o estado da sincronizacao da pasta _82"
    }
} else {
    $pendencias += "A sincronizacao da pasta _82 nunca registrou execucao"
}

# Alteracoes que ficaram sem ser salvas. As 02h, depois do commit da 01h30,
# isso indica que o commit automatico nao rodou ou nao conseguiu salvar.
if ($statusCurto) {
    $qtd = @($statusCurto -split "`r`n" | Where-Object { $_.Trim() }).Count
    $pendencias += "$qtd arquivo(s) alterado(s) e ainda nao salvo(s) no historico do projeto"
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
if ($achados.Count -gt 0) {
    $rel += ""
    $rel += if ($bloqueado) { "   O QUE ME FEZ PARAR:" } else { "   ACHADOS REVISADOS E LIBERADOS MANUALMENTE:" }
    foreach ($a in $achados) { $rel += "      - $a" }
    if ($bloqueado) {
        $rel += ""
        $rel += "   O QUE FAZER: nada foi perdido, suas alteracoes continuam salvas no"
        $rel += "   computador. Peca a revisao na proxima conversa. Se for alarme falso,"
        $rel += "   a publicacao pode ser liberada manualmente."
    }
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
# 'AMC-IA-Push-Diario' saiu desta lista de proposito. A tarefa das 02h foi apagada
# a pedido da captadora em 13/08/2026 (SOL-0022): a publicacao no GitHub voltou a
# ser sempre manual. Continuar procurando por ela acusava pendencia todo dia por
# uma tarefa que nao deve existir. Se um dia a publicacao automatica voltar,
# recriar a tarefa e devolver o nome aqui.
foreach ($t in @('AMC-IA-Sincronizar-Pasta82','AMC-IA-Vigia-Pasta82','AMC-IA-SincronizacaoDiaria')) {
    $rel += "   " + (Estado-Tarefa $t)
}
$rel += ""
if ($statusCurto) {
    $rel += "=================================================="
    $rel += "4. ARQUIVOS ALTERADOS E AINDA NAO SALVOS"
    $rel += "=================================================="
    $rel += $statusCurto
    $rel += ""
}
$rel += "=================================================="
$rel += "5. PRECISA DE ACAO?"
$rel += "=================================================="
if ($pendencias.Count -eq 0) {
    $rel += "   NAO. Tudo rodou sozinho e deu certo. Nenhuma acao necessaria."
} else {
    $rel += "   SIM, $($pendencias.Count) item(ns):"
    foreach ($p in $pendencias) { $rel += "      - $p" }
    $rel += ""
    $rel += "   Um alerta foi criado na Area de Trabalho."
}

$arquivoRel = Join-Path $RelatorioDir "relatorio-$hoje.txt"
Set-Content -LiteralPath $arquivoRel -Value ($rel -join "`r`n") -Encoding utf8

# ---------------------------------------------------------------
# 5. Alerta, no mesmo modelo do vigia da pasta _82
# ---------------------------------------------------------------
# So aparece quando algo exige acao dela. Some sozinho quando normaliza,
# para que a presenca do arquivo signifique sempre "tem coisa pendente".
if ($pendencias.Count -gt 0) {
    $al = @()
    $al += "ALERTA. ALGO NAS AUTOMACOES PRECISA DE VOCE"
    $al += "Gerado em $(Get-Date -Format 'dd/MM/yyyy HH:mm')"
    $al += ""
    $al += "O QUE PRECISA DE ACAO ($($pendencias.Count) item(ns)):"
    foreach ($p in $pendencias) { $al += "   - $p" }
    if ($bloqueado) {
        $al += ""
        $al += "DETALHE DO QUE BLOQUEOU A PUBLICACAO:"
        foreach ($a in $achados) { $al += "   - $a" }
    }
    $al += ""
    $al += "NADA FOI PERDIDO. Seu trabalho continua salvo no computador."
    $al += "Abra a conversa com o assistente e diga que apareceu este alerta."
    $al += "Ele ja sabe onde procurar e o que fazer."
    $al += ""
    $al += "Relatorio completo: $arquivoRel"
    $al += ""
    $al += "Este arquivo some sozinho quando tudo voltar ao normal."

    Set-Content -LiteralPath $AlertaFile -Value ($al -join "`r`n") -Encoding utf8

    try {
        Add-Type -AssemblyName System.Windows.Forms
        $ni = New-Object System.Windows.Forms.NotifyIcon
        $ni.Icon = [System.Drawing.SystemIcons]::Warning
        $ni.BalloonTipTitle = "AMC IA: algo precisa de voce"
        $ni.BalloonTipText  = "$($pendencias.Count) pendencia(s). Veja o alerta na Area de Trabalho."
        $ni.Visible = $true
        $ni.ShowBalloonTip(20000)
        Start-Sleep -Seconds 12
        $ni.Dispose()
    } catch { }
} elseif (Test-Path -LiteralPath $AlertaFile) {
    Remove-Item -LiteralPath $AlertaFile -Force -ErrorAction SilentlyContinue
}

Write-Output $resultadoPush
if ($pendencias.Count -gt 0) {
    Write-Output ""
    Write-Output "PENDENCIAS QUE PRECISAM DE ACAO ($($pendencias.Count)):"
    foreach ($p in $pendencias) { Write-Output "   - $p" }
}
Write-Output "Relatorio: $arquivoRel"
if ($pendencias.Count -gt 0) { exit 2 } else { exit 0 }
