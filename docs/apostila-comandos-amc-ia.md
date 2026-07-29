# Apostila de Comandos. AMC IA

> Guia de referência completo de todos os comandos, agentes e áreas de trabalho da AMC IA. Um capítulo por comando: o que faz, o que pede, o passo a passo, o que entrega, onde salva e as travas que protegem o seu trabalho.

**Como usar esta apostila:**

Os comandos estão organizados pelas mesmas fases do Método Captar 2.0: primeiro **CAPTAR** (o dia a dia técnico com um edital e uma OSC), depois **POSICIONAR** (o marketing do captador como negócio) e **ASSESSORAR** (a venda e a prestação do serviço). No fim, uma área de **Apoio e Sistema** reúne o que dá suporte a tudo isso, seguida das tabelas de referência rápida (agentes, bases de conhecimento, fluxo completo e índice de perguntas).

Cada capítulo de comando traz sempre a mesma estrutura:

- **Para que serve.** A função do comando em uma frase.
- **Quando usar.** O momento certo de digitar aquele comando.
- **Contexto que ele lê.** O que o sistema consulta antes de começar (OSC ativa, arquivos do projeto).
- **Passo a passo.** O que o comando pergunta e faz, na ordem.
- **O que entrega.** O documento, arquivo ou resultado final, com a estrutura do conteúdo.
- **Onde salva.** O caminho exato do arquivo gerado.
- **Travas e dependências.** O que precisa existir antes, e o que impede o comando de seguir.
- **Próximo passo sugerido.** Para onde ir depois.

---

## Antes de tudo. Como o sistema pensa

A AMC IA sempre trabalha em cima de duas coisas: **uma OSC ativa** e, dentro dela, **um projeto** (um edital sendo trabalhado). Quase todo comando começa lendo `minhas-oscs/.ativa` para saber qual organização está em foco.

```
CaptaHub (fonte da verdade: editais + carteira + pipeline)
        ↓ puxa
    AMC IA (estúdio de elaboração)
        ↓
  OSC ativa → Projeto (edital) → os 4 agentes → entrega pronta para submeter
```

O CaptaHub não compete com a AMC IA: ele é de onde vêm os editais e onde mora a carteira de clientes. A AMC IA é a bancada de trabalho onde um edital vira um projeto aprovado.

Duas regras valem para (quase) todo comando:

- **Gate de Elegibilidade.** Nenhuma proposta é escrita antes de a elegibilidade (CaptaDoc) ter sido verificada para aquele edital e aquela OSC. É a trava mais importante do sistema.
- **Aprovação antes de salvar.** Ao final da geração de um entregável, o comando mostra o resultado e pergunta "1. Aprovar e salvar" ou "2. Quero ajustar algo", exceto quando você pede para ir direto à versão final.

---

# ÁREA 1. ORGANIZAÇÃO (A OSC)

Cadastro e gestão da organização atendida. Todo o resto do sistema depende de existir uma OSC ativa.

## `/osc-nova`

**Para que serve.** Cadastra uma organização da sociedade civil do zero e a define como ativa. É a porta de entrada do sistema: sem OSC cadastrada não há contexto para minerar editais ou elaborar projetos.

**Quando usar.** Primeira vez que você vai trabalhar com aquela organização, e ela ainda não está na carteira do CaptaHub (se já estiver lá, use `/osc-importar` em vez deste).

**Contexto que ele lê.** `minhas-oscs/.ativa` (para saber se já existem outras OSCs na carteira) e verifica se há conexão com o CaptaHub (`CAPTAHUB_API_TOKEN` no `.env`). Se estiver conectado, o sistema avisa que a OSC pode já existir lá e sugere `/osc-importar` antes de cadastrar do zero.

**Passo a passo (entrevista, uma pergunta por vez):**
1. Nome da organização.
2. CNPJ.
3. Natureza jurídica (1. Associação, 2. Fundação, 3. OSCIP, 4. Organização religiosa, 5. Cooperativa social, 6. Outra).
4. Data de fundação (para calcular o tempo de existência).
5. Município e UF da sede, e territórios onde atua.
6. Área(s) temática(s) de atuação.
7. Missão e principais programas.
8. Experiência com editais e projetos já aprovados (valor, financiador, ano).
9. Situação documental: passa o checklist do modelo e pergunta o que a OSC já tem em dia.

Ao final, resume os dados e o slug que será gerado (kebab-case do nome, ex: `instituto-semente`) e pede OK antes de salvar.

**O que entrega.** O perfil completo da organização, no formato do modelo `minhas-oscs/MODELO-perfil-osc.md`: identificação, dados cadastrais, natureza jurídica, território, área de atuação, missão, histórico de projetos e checklist documental.

**Onde salva.** `minhas-oscs/{slug}/perfil-osc.md`, com a subpasta `minhas-oscs/{slug}/projetos/` já criada. O slug é gravado em `minhas-oscs/.ativa`.

**Sincronização com o CaptaHub.** Se conectado, o sistema cria automaticamente o cliente na carteira do CaptaHub (checando antes que não existe, para não duplicar) e grava o id retornado no perfil local (`ID CaptaHub: {id}`).

**Travas e dependências.** Nenhuma trava de entrada; é o primeiro comando do sistema.

**Próximo passo sugerido.** `/edital-minerar` para encontrar editais alinhados, ou `/edital-analisar` se você já tem um edital em mãos.

---

## `/osc-importar`

**Para que serve.** Traz uma organização que já existe na carteira do CaptaHub para dentro da AMC IA, criando o perfil local completo e definindo-a como ativa. Evita recadastrar do zero uma OSC que já está cadastrada lá.

**Quando usar.** A organização já está na carteira do CaptaHub (visível em `/osc-trocar` ou ao abrir a sessão), mas ainda não tem pasta de trabalho aqui na AMC IA.

**Contexto que ele lê.** Verifica a conexão com o CaptaHub (`CAPTAHUB_API_TOKEN` no `.env`). Sem token, orienta `/captahub-conectar` primeiro, ou `/osc-nova` se você preferir cadastrar manualmente.

**Passo a passo:**
1. Lista a carteira inteira (nome, UF, município, área temática) rodando `captahub-api.py clientes --all`, numerada para escolha. Se você já disse qual OSC quer, pula direto para o próximo passo.
2. Busca o registro completo da OSC escolhida (`captahub-api.py cliente --id {id}`).
3. Mapeia cada campo do CaptaHub para o campo correspondente do perfil local (nome, sigla, CNPJ, natureza jurídica, fundação, município/UF, territórios, áreas temáticas, missão, contato, situação documental, histórico de aprovações). Campo que vier vazio no CaptaHub fica marcado como "a confirmar com a OSC", nunca é inventado.
4. Resume o que foi importado e o que ficou pendente de confirmação, pede OK.

**O que entrega.** O perfil local completo da OSC, já ligado ao registro do CaptaHub pelo id, pronto para minerar editais e abrir projetos.

**Onde salva.** `minhas-oscs/{slug}/perfil-osc.md` (slug em kebab-case do nome) e a subpasta `projetos/`. O slug é gravado em `minhas-oscs/.ativa`.

**Travas e dependências.** Exige `CAPTAHUB_API_TOKEN` configurado (rode `/captahub-conectar` antes, se necessário).

**Próximo passo sugerido.** `/osc-perfil` para completar os campos que ficaram "a confirmar", ou `/edital-minerar` para já buscar editais alinhados.

---

## `/osc-trocar`

**Para que serve.** Mostra a carteira inteira (sincronizada com o CaptaHub) e troca qual OSC está ativa no momento.

**Quando usar.** Você vai atender outro cliente na mesma sessão, ou quer ver de relance o estágio de todas as organizações que atende.

**Contexto que ele lê.** Puxa a carteira ao vivo do CaptaHub (se conectado) e varre as pastas locais em `minhas-oscs/`, ligando cada uma ao registro do CaptaHub pelo id (ou por nome, na falta do id).

**Passo a passo:**
1. Sincroniza a carteira com o CaptaHub.
2. Apresenta uma lista numerada e unificada, classificando cada OSC como: **no CaptaHub + local** (pronta para trabalhar), **só no CaptaHub** (precisa importar antes) ou **só local** (fora da carteira). Mostra nome, UF, área e quantos projetos abertos cada uma tem, e marca qual está ativa agora.
3. Pergunta qual OSC você quer tornar ativa.
4. Se for "só no CaptaHub", importa primeiro (aciona `/osc-importar` internamente). Grava o slug escolhido em `minhas-oscs/.ativa`.

**O que entrega.** A confirmação "OSC ativa agora: {nome}".

**Onde salva.** Atualiza `minhas-oscs/.ativa`.

**Travas e dependências.** Nenhuma. Funciona mesmo sem CaptaHub conectado, usando só as OSCs locais.

**Próximo passo sugerido.** `/edital-minerar` para pegar editais novos, ou retomar um projeto aberto daquela OSC.

---

## `/osc-perfil`

**Para que serve.** Mostra e atualiza o perfil da OSC ativa: dados cadastrais, documentos, capacidade técnica.

**Quando usar.** Precisa checar ou corrigir um dado da organização, ou marcar um documento como obtido ou vencido (isso é crítico para o CaptaDoc, que usa exatamente esse campo para o veredito de elegibilidade).

**Contexto que ele lê.** `minhas-oscs/.ativa` e o `perfil-osc.md` da OSC ativa. Sem OSC ativa, orienta `/osc-nova`.

**Passo a passo:**
1. Apresenta um resumo legível do perfil: identificação, atuação, capacidade institucional e situação documental, destacando o que falta.
2. Pergunta o que você quer fazer: 1. Atualizar um dado específico, 2. Atualizar a situação documental (documentos obtidos ou vencidos), 3. Só visualizar.
3. Se for atualização, faz a edição cirúrgica no arquivo (altera só o que foi pedido, sem reescrever o resto).

**O que entrega.** O perfil atualizado, ou apenas a visualização, conforme sua escolha.

**Onde salva.** `minhas-oscs/{ativa}/perfil-osc.md` (edição no próprio arquivo).

**Travas e dependências.** Precisa de uma OSC ativa definida.

**Próximo passo sugerido.** Conforme o que você estiver fazendo no momento; não força um próximo passo específico.

---

# ÁREA 2. EDITAIS

Descoberta e leitura de oportunidades. Os editais sempre vêm do CaptaHub; a base local é só um cache de apoio.

## `/edital-minerar`

**Para que serve.** Puxa os editais do CaptaHub, atualiza o cache local e lista os mais aderentes ao perfil da OSC ativa (escopo, valor, prazo, área).

**Quando usar.** Está procurando qual edital vale a pena buscar para a OSC ativa.

**Contexto que ele lê.** `minhas-oscs/.ativa` e o `perfil-osc.md`. Sem OSC ativa, orienta `/osc-nova` primeiro.

**Passo a passo:**
1. Anuncia o início (cerca de 30 segundos).
2. Atualiza o cache rodando `captahub-editais.py`. Se o CaptaHub não estiver conectado, avisa que está usando o último cache local e segue mesmo assim (não trava).
3. Aciona o agente `minerador-editais`, que aplica os filtros do perfil (escopo, área, faixa de valor, prazo mínimo), descarta editais vencidos e classifica por aderência: ALTA, MÉDIA ou BAIXA. Você pode pedir filtros extras: um escopo específico, faixa de valor, prazo mínimo de dias, palavra-chave de área.
4. **Fallback de varredura web.** Se o CaptaHub não trouxer nenhum candidato com aderência ALTA ou MÉDIA, o sistema aciona automaticamente o agente `minerador-web`, que busca editais abertos na internet (portais, Transferegov, leis de incentivo, fundações), confirma o prazo na fonte oficial e devolve candidatos no mesmo formato, marcados como "ainda fora do CaptaHub".

**O que entrega.** Uma lista priorizada (top 10 a 15) em tabela: edital, órgão, escopo, valor, prazo, aderência e o motivo em uma linha. Os achados da varredura web vêm em um bloco separado. Para os de aderência ALTA, oferece já abrir o projeto (criar a pasta e um `edital.md` inicial).

**Onde salva.** Se você abrir um projeto a partir da lista, cria `minhas-oscs/{ativa}/projetos/{edital-slug}/edital.md`.

**Travas e dependências.** Nunca recomenda edital com prazo vencido. A aderência aqui é indicativa; quem dá o veredito final de elegibilidade é o CaptaDoc.

**Próximo passo sugerido.** `/edital-analisar` para aprofundar o edital escolhido, e depois `/projeto-elegibilidade`.

---

## `/edital-analisar`

**Para que serve.** Lê um edital inteiro e o transforma em um resumo estruturado que alimenta os 4 agentes (CaptaDoc, CaptaBuilder, CaptaBudget, CaptaScore). Sem esse resumo, nenhum dos quatro tem o que precisa para trabalhar.

**Quando usar.** Você já escolheu o edital (via `/edital-minerar` ou por conta própria) e precisa entendê-lo a fundo antes de qualquer outra etapa, dentro do projeto de uma OSC.

**Contexto que ele lê.** `minhas-oscs/.ativa` e o `perfil-osc.md`.

**Passo a passo:**
1. Pergunta como você vai fornecer o edital: 1. Colar o texto, 2. Caminho de um PDF na máquina, 3. Link do edital.
2. Anuncia o início (2 a 4 minutos).
3. Extrai e organiza 8 pontos: identificação (órgão, número, objeto, modalidade), quem pode participar (natureza jurídica, tempo de existência, território, área), documentos exigidos para habilitação, valores (teto total e por categoria, percentuais máximos, contrapartida), despesas permitidas e vedadas, critérios de pontuação e pesos, prazos (submissão, vigência, cronograma) e forma de submissão (plataforma, formato dos anexos, formulário oficial).

**O que entrega.** O resumo estruturado do edital nos 8 pontos acima, ancorado sempre no texto original (o que for ambíguo é marcado como "verificar no edital", nunca inventado).

**Onde salva.** `minhas-oscs/{ativa}/projetos/{edital-slug}/edital.md`, e cria também `estado.md` marcando a etapa "edital analisado".

**Travas e dependências.** Precisa de uma OSC ativa. Não invente exigência que não esteja no texto do edital.

**Próximo passo sugerido.** `/projeto-elegibilidade` (CaptaDoc), sempre.

---

## `/descricao-edital`

**Para que serve.** Gera uma ficha descritiva completa e avulsa de um edital específico, entregue como documento `.doc` para baixar, sem vincular a nenhuma OSC. É mais profunda que o `/edital-analisar` em dois pontos: cobre também execução, prestação de contas, comunicação/divulgação e uma seção extra de "pontos de atenção" (detalhes que passam despercebidos numa leitura corrida, mas custam pontos, desclassificam ou inabilitam).

**Quando usar.** Você só quer entender rápido as regras de um edital, sem ainda ter decidido a OSC, ou precisa checar as regras de execução e prestação de contas antes de assumir o compromisso.

**Contexto que ele lê.** Nenhum. Este comando é intencionalmente desvinculado de qualquer organização: não lê `minhas-oscs/.ativa` nem nenhum perfil.

**Passo a passo:**
1. Pergunta como você vai fornecer o edital (colar texto, caminho de PDF, ou link).
2. Anuncia o início (2 a 4 minutos, 12 pontos).
3. Extrai e organiza 12 seções: identificação; quem pode participar; documentos exigidos; valores; despesas permitidas e vedadas; critérios de pontuação e critérios de desempate; prazos (submissão, resultado, recurso, habilitação, pagamento, execução, prestação de contas); forma de submissão; execução e contratação (o que pode e não pode ser pago, remanejamento); prestação de contas (o que apresentar, prazo, canal, tempo de guarda); comunicação e divulgação (exigência de menção ao apoio, uso de logomarca); e pontos de atenção críticos (ex: exigências de comprovante de residência com janela de validade, critérios que pontuam ao contrário do intuitivo, valores que precisam fechar exatamente, limite de propostas por proponente, itens cuja ausência sozinha já desclassifica, situações cadastrais externas como SIAFI ou Cadin que travam a habilitação).
4. Converte o conteúdo em `.doc`.

**O que entrega.** Um documento `.doc` com as 12 seções, pronto para consulta ou impressão.

**Onde salva.** `Descrição Editais/{edital-slug}.doc` (pasta na raiz do projeto, fora de `minhas-oscs/`).

**Travas e dependências.** Nenhuma. Não lê nem grava nada dentro de `minhas-oscs/`, mesmo que exista uma OSC ativa.

**Próximo passo sugerido.** Nenhum específico de OSC é sugerido, a menos que você peça.

---

## `/editais-pasta-processar`

**Para que serve.** Lê tudo que estiver salvo na pasta `editais-para-cadastrar/`, extrai os dados de cada edital, confere se já existe (na base local e no CaptaHub ao vivo) para nunca duplicar, e prepara os editais novos para cadastro.

**Quando usar.** Toda vez que chegam editais novos para cadastrar na base (pensado para rodar toda segunda-feira, mas pode ser chamado a qualquer momento).

**Contexto que ele lê.** Testa a conexão com o CaptaHub (`captahub-api.py testar`). Se não responder, avisa que a checagem de duplicidade vai usar só a base local e segue mesmo assim.

**Passo a passo:**
1. Anuncia o início (2 a 4 minutos).
2. Lista os arquivos da pasta `editais-para-cadastrar/`, ignorando `LEIAME.md`, a subpasta `processados/` e o `prontos-para-cadastro.json`. Sem arquivo nenhum, avisa e para.
3. Extrai o texto de cada arquivo conforme a extensão: PDF/imagem lê direto; `.txt`/`.md` lê (ou busca a página, se for um link); `.docx`/`.xlsx` roda um script de extração à parte. Formato não suportado é avisado e pulado (nunca apagado).
4. Extrai os campos no formato do CaptaHub: título, instituição, categoria, escopo, valor, prazo, se é contínuo, url, descrição, tags. Campo não encontrado fica `null`, nunca é inventado.
5. Para cada edital extraído, checa duplicidade rodando um script que compara título, órgão e url contra a base local e o CaptaHub.
6. Separa os duplicados (descartados) dos novos (candidatos a cadastro).

**O que entrega.** Um relatório final: quantos arquivos foram lidos, quantos editais novos foram preparados, quantos já existiam (pulados), com a lista de cada um (título e órgão). Como ainda não existe endpoint confirmado de criação de edital via API, o cadastro automático no CaptaHub ainda não roda sozinho: o comando orienta cadastrar manualmente na tela do CaptaHub, usando o JSON gerado como referência.

**Onde salva.** Os editais novos, prontos para cadastro, em `editais-para-cadastrar/prontos-para-cadastro.json`. Os arquivos já processados (novos e duplicados) são movidos para `editais-para-cadastrar/processados/{AAAA-MM-DD}/`, preservando o nome original (nunca apagados).

**Travas e dependências.** Na dúvida entre duplicado e novo, o sistema trata como duplicado e pede conferência manual (erra para o lado seguro).

**Próximo passo sugerido.** Cadastrar manualmente no CaptaHub os editais novos listados no relatório.

---

# ÁREA 3. PROJETO. OS 4 AGENTES (O CORAÇÃO DO SISTEMA)

A linha de montagem que transforma um edital analisado em um projeto pronto para submeter. Segue sempre esta ordem, protegida pelo **Gate de Elegibilidade**: nunca se escreve proposta sem elegibilidade verificada primeiro.

```
CaptaDoc → CaptaBuilder → CaptaBudget → CaptaScore
```

Os quatro tratam, em ordem, os quatro motivos recorrentes de reprovação de um projeto: edital errado, elegibilidade falha, texto fraco e orçamento furado.

## `/projeto-elegibilidade`

**Para que serve.** Aciona o CaptaDoc para cruzar o edital com o perfil da OSC e emitir o veredito de elegibilidade. É o Gate de Elegibilidade do Método Captar: ninguém escreve proposta antes deste passo.

**Quando usar.** Sempre o primeiro passo depois de `/edital-analisar`, antes de qualquer elaboração.

**Contexto que ele lê.** `minhas-oscs/.ativa` e identifica o projeto (se houver vários, pergunta qual edital). Se o edital ainda não foi analisado (sem `edital.md`), orienta `/edital-analisar` primeiro.

**Passo a passo:**
1. Anuncia o início (cerca de 90 segundos).
2. Aciona o agente `captador-doc`, que confere natureza jurídica, tempo de existência, território, área de atuação e certidões da OSC contra as exigências do edital, e monta o checklist de documentos obrigatórios, identificando riscos de inabilitação.

**O que entrega.** O veredito (**APTO**, **APTO COM PENDÊNCIAS** ou **INAPTO NO MOMENTO**), o checklist documental completo e os riscos de inabilitação identificados.

**Onde salva.** `minhas-oscs/{ativa}/projetos/{edital-slug}/elegibilidade.md`.

**Travas e dependências.** Exige `edital.md` já existente. Este comando, por sua vez, é a trava que protege `/projeto-escrever`: nenhuma proposta nasce sem ele ter rodado antes.

**Próximo passo sugerido, conforme o veredito:**
- **APTO:** siga para `/projeto-escrever`.
- **APTO COM PENDÊNCIAS:** o sistema lista o que falta resolver; a elaboração pode começar em paralelo, mas a submissão depende de regularizar.
- **INAPTO NO MOMENTO:** o sistema explica o impedimento e sugere buscar outro edital com `/edital-minerar`.

---

## `/projeto-escrever`

**Para que serve.** Aciona o CaptaBuilder para elaborar a proposta completa do projeto, bloco a bloco, ancorada nos critérios do edital.

**Quando usar.** Depois da elegibilidade confirmada como APTO ou APTO COM PENDÊNCIAS.

**Contexto que ele lê.** `minhas-oscs/.ativa`, o projeto identificado e o `elegibilidade.md`. Se estiver ausente, roda `/projeto-elegibilidade` antes. Se o veredito for INAPTO, o comando não prossegue.

**Passo a passo:**
1. Anuncia o início (4 a 8 minutos).
2. Aciona o agente `captador-builder`, que conduz a coleta por blocos, uma pergunta por vez, reaproveitando o que já está no perfil da OSC (sem repetir pergunta): identificação, justificativa, problema central, público-alvo, objetivo geral, objetivos específicos, metas, metodologia, cronograma, equipe, orçamento resumido, monitoramento e avaliação, resultados esperados, sustentabilidade, contrapartida, diferenciais competitivos e riscos/mitigação. Sempre adaptado ao formulário oficial quando o edital fornece um.
3. Mostra a proposta completa para aprovação: "1. Aprovar e salvar / 2. Quero ajustar algo".

**O que entrega.** A proposta completa, estruturada e ancorada no edital (cada afirmação responde a um critério ou exigência), com pontos fortes, fragilidades e estimativa de desempenho.

**Onde salva.** `minhas-oscs/{ativa}/projetos/{edital-slug}/proposta.md`.

**Travas e dependências.** Não escreve nada sem `elegibilidade.md` existente e sem veredito diferente de INAPTO.

**Próximo passo sugerido.** `/projeto-orcamento`.

---

## `/projeto-orcamento`

**Para que serve.** Aciona o CaptaBudget para transformar a proposta em um orçamento técnico defensável, por rubrica, com memória de cálculo.

**Quando usar.** Depois que a proposta existe: o orçamento nasce das atividades descritas nela.

**Contexto que ele lê.** `minhas-oscs/.ativa`, o projeto e a `proposta.md`. Sem ela, orienta `/projeto-escrever` antes.

**Passo a passo:**
1. Anuncia o início (2 a 4 minutos).
2. Aciona o agente `captador-budget`, que lê as regras financeiras do edital (teto total, teto por categoria, percentuais máximos, despesas vedadas), deriva os itens necessários das atividades da proposta, monta o quadro por rubrica (pessoal e encargos, serviços de terceiros, material de consumo, material permanente, diárias e passagens, despesas administrativas, contrapartida) com memória de cálculo e justificativa técnica, busca referências de preço na web quando o edital exige, e sinaliza risco de glosa, itens vedados e a exigência de 3 cotações.
3. Mostra o orçamento para aprovação.

**O que entrega.** O orçamento técnico completo por rubrica, com memória de cálculo, dentro do teto e das regras financeiras do edital, e as pendências identificadas (cotações faltando, item de risco).

**Onde salva.** `minhas-oscs/{ativa}/projetos/{edital-slug}/orcamento.md`.

**Travas e dependências.** Exige `proposta.md` existente. Exige coerência absoluta entre proposta e orçamento (toda atividade tem item de orçamento correspondente, e vice-versa).

**Próximo passo sugerido.** `/projeto-avaliar`.

---

## `/projeto-avaliar`

**Para que serve.** Aciona o CaptaScore para auditar o projeto inteiro com visão de banca antes da submissão. É o diferencial do método: você sabe a chance de aprovação antes de enviar.

**Quando usar.** Proposta e orçamento prontos, antes de revisar e submeter.

**Contexto que ele lê.** `minhas-oscs/.ativa`, o projeto, `proposta.md` e `orcamento.md`. Avalia o que existir e avisa o que não pôde ser pontuado se algum estiver faltando.

**Passo a passo:**
1. Anuncia o início (2 a 3 minutos).
2. Aciona o agente `captador-score`, que extrai os critérios de pontuação do próprio edital (ou usa os critérios padrão do método quando o edital não especifica: aderência, capacidade técnica, potencial de impacto, coerência metodológica, clareza de objetivos, orçamento, cronograma, inovação, sustentabilidade), dá nota de 0 a 10 por critério, estima a chance de aprovação por fase (eliminatória, técnica, contemplação final), aponta riscos de desclassificação e reescreve os campos mais críticos numa versão "nota 9,5".

**O que entrega.** Nota geral, chance de aprovação por fase, nota detalhada por critério, riscos de desclassificação e as reescritas dos campos críticos.

**Onde salva.** `minhas-oscs/{ativa}/projetos/{edital-slug}/score.md`.

**Travas e dependências.** Nenhuma trava de bloqueio, mas a avaliação fica incompleta se faltar `proposta.md` ou `orcamento.md`.

**Próximo passo sugerido, conforme o resultado:**
- **PRONTO PARA SUBMETER:** siga para `/projeto-revisar`.
- **AJUSTAR ANTES:** aplique as reescritas sugeridas (voltando a `/projeto-escrever` ou `/projeto-orcamento`, conforme o caso) e avalie de novo.

---

## `/projeto-revisar`

**Para que serve.** Faz a última checagem do projeto antes de submeter, acionando o agente `revisor-proposta`.

**Quando usar.** Último passo antes de exportar e submeter, depois da avaliação do CaptaScore.

**Contexto que ele lê.** `minhas-oscs/.ativa`, o projeto, `proposta.md` e `orcamento.md`.

**Passo a passo:**
1. Anuncia o início (cerca de 60 segundos).
2. Aciona o agente `revisor-proposta`, que aplica 4 blocos de checagem: **A** completude (todas as seções obrigatórias presentes), **B** coerência interna (objetivos, metas, metodologia, cronograma e orçamento contando a mesma história), **C** conformidade com o edital (teto, prazo, formulário oficial) e **D** revisão de português (acentuação, ausência de travessão).

**O que entrega.** Um relatório com o que já foi corrigido automaticamente, o que exige uma decisão sua, e o veredito final: **PRONTO PARA SUBMETER** ou **AJUSTAR ANTES**.

**Onde salva.** As correções são aplicadas diretamente em `proposta.md` e `orcamento.md`. Se PRONTO, atualiza `estado.md` para "pronto para submeter".

**Travas e dependências.** Nunca altera conteúdo que exige decisão sua sem perguntar primeiro; corrige só português e formatação por conta própria.

**Próximo passo sugerido.** Se PRONTO, lembra a forma de submissão indicada no `edital.md` (plataforma, anexos, prazo) e sugere `/projeto-exportar`.

---

## `/projeto-exportar`

**Para que serve.** Transforma a proposta e o orçamento (que estão em markdown) nos arquivos finais que o financiador aceita: Word editável, PDF e planilha. É o último passo antes de submeter.

**Quando usar.** Projeto revisado e aprovado, hora de gerar os arquivos finais para anexar na plataforma de submissão.

**Contexto que ele lê.** `minhas-oscs/.ativa`, o projeto, `proposta.md` e `orcamento.md`. Se faltar algum, avisa e orienta rodar o comando correspondente antes (mas pode exportar só o que já existir).

**Passo a passo:**
1. Anuncia o início (cerca de 30 segundos).
2. Roda o script de exportação, que gera todos os arquivos na pasta `entrega-final/` do projeto, removendo automaticamente a seção interna "Notas do CaptaBuilder (não submeter)" da versão final.

**O que entrega.**
- `proposta.doc` (edita no Word ou Google Docs)
- `proposta.pdf` (pronto para anexar)
- `orcamento.xls` e `orcamento.csv` (abrem no Excel ou Google Sheets)
- `orcamento.pdf`
- `projeto-completo.pdf` (proposta, orçamento, parecer e nota, tudo em um arquivo)
- versões `-impressao.html`, para gerar o PDF manualmente pelo navegador se o Google Chrome não estiver instalado na máquina

**Onde salva.** `minhas-oscs/{ativa}/projetos/{edital-slug}/entrega-final/`.

**Travas e dependências.** O PDF automático depende do Google Chrome estar instalado; sem ele, use o HTML de impressão e "Salvar como PDF" pelo navegador. Sempre confira o documento final: se o edital exigir um modelo oficial próprio, cole o conteúdo do `.doc` nesse modelo.

**Próximo passo sugerido.** Submeter na plataforma do edital e, depois, atualizar o status do projeto para "submetido" no CaptaHub.

---

# ÁREA 4. CAPTAHUB (CONEXÃO E SINCRONIZAÇÃO)

Comandos de integração entre a AMC IA e a plataforma que centraliza editais, carteira e pipeline.

## `/captahub-conectar`

**Para que serve.** Liga a AMC IA ao CaptaHub, de onde vêm os editais e onde mora a carteira (pipeline e clientes).

**Quando usar.** Primeira configuração do projeto, ou se a conexão parou de funcionar.

**Contexto que ele lê.** As credenciais ficam só no `.env`; nunca aparecem em outro arquivo nem são exibidas sem máscara.

**Passo a passo (caminho recomendado, API por token):**
1. Pergunta se você já tem o token da API do CaptaHub (gerado na aba API da plataforma). Se não tiver, orienta a gerá-lo lá.
2. Grava `CAPTAHUB_API_URL` e `CAPTAHUB_API_TOKEN` no `.env` (cria o arquivo se não existir), sem nunca ecoar o valor no chat, mostrando apenas `CAPTAHUB_API_TOKEN = (salvo, mascarado)`.
3. Testa a conexão e informa o dono do token e os escopos concedidos.

Há também um caminho legado (banco direto via `SUPABASE_URL`, `SUPABASE_KEY`, `CAPTAHUB_EDITAIS_TABLE`), que serve apenas como fallback de leitura de editais.

**O que entrega.** A confirmação da conexão ativa, com editais, carteira e clientes disponíveis pelo conector.

**Onde salva.** As variáveis no `.env` da raiz do projeto.

**Travas e dependências.** Sem as credenciais, o sistema continua funcionando com o último cache local de editais, mas sem acesso à carteira ao vivo.

**Próximo passo sugerido.** `/edital-minerar` ou `/osc-trocar` para ver a carteira sincronizada.

---

## `/captahub-sincronizar`

**Para que serve.** Reconcilia a carteira e o pipeline com o CaptaHub nos dois sentidos: puxa as atualizações de lá e sobe o que existe só localmente aqui.

**Quando usar.** Ao abrir a sessão, ao terminar uma etapa importante do projeto, ou sempre que quiser garantir que tudo está espelhado.

**Contexto que ele lê.** Verifica `CAPTAHUB_API_TOKEN` no `.env`. Sem token, orienta `/captahub-conectar` e para.

**Passo a passo:**
1. Anuncia o início (cerca de 30 segundos).
2. **Puxa do CaptaHub:** a carteira de OSCs inteira e atualiza o cache de editais.
3. **Cruza carteira local x CaptaHub:** classifica cada OSC como em dia, só no CaptaHub (importável) ou só local (fora da carteira).
4. **Sobe o que está só local**, sempre checando o id antes de criar (nunca duplica): cria no CaptaHub qualquer OSC que exista só aqui, e cria ou atualiza o projeto da OSC ativa (valor do orçamento, nota técnica, chance de aprovação, status/estágio, data de submissão).

**O que entrega.** Um resumo em tabela: o que foi puxado, o que foi criado, o que foi atualizado e o que ficou pendente (ex: alguma chamada à API falhou), em linguagem de captador, sem detalhe técnico.

**Onde salva.** Grava os ids do CaptaHub nos arquivos locais (`perfil-osc.md`, `estado.md`) na primeira vez que cada registro é criado lá.

**Travas e dependências.** Sempre confere o id antes de criar (idempotência: nunca duplica OSC nem projeto). Se a API falhar em algo, não trava a elaboração: lista como pendente e segue.

**Próximo passo sugerido.** Nenhum específico; é um comando de manutenção.

---

# ÁREA 5. MARKETING DO CAPTADOR (FASE 2. POSICIONAR)

> Diferente das áreas anteriores: aqui o contexto não é uma OSC, é o próprio captador como negócio (`captador/perfil-captador.md`). O público é o gestor de OSC que pode contratar a assessoria.

## `/captador-perfil`

**Para que serve.** Cadastra ou atualiza o perfil do captador e da marca da assessoria. É a fundação de toda a Fase 2: sem esse perfil, qualquer conteúdo ou página sai genérico.

**Quando usar.** Antes de qualquer outro comando desta área.

**Contexto que ele lê.** Verifica se já existe `captador/perfil-captador.md`; se existir, oferece atualizar em vez de recomeçar do zero.

**Passo a passo (entrevista, uma pergunta por vez):**
1. Nome do captador e nome da assessoria (se tiver).
2. Cidade, região de atuação e tempo de experiência em captação.
3. Projetos já aprovados (valor, financiador, ano); se ainda não tem nenhum, registra que a autoridade será construída pela jornada e pelo método.
4. A jornada de origem: o que enfrentou antes de ter método, e qual foi a virada.
5. Áreas e temas que mais domina.
6. Perfil das OSCs que quer atender e quem decide a contratação.
7. Serviços que quer oferecer (proposta avulsa, triagem, contrato anual) e faixa de preço pretendida.
8. Tom de voz e canais que usa ou quer usar.

**O que entrega.** O perfil completo do captador como negócio, base de todo o conteúdo e páginas seguintes.

**Onde salva.** `captador/perfil-captador.md`.

**Travas e dependências.** Nenhuma.

**Próximo passo sugerido.** `/assessoria-estruturar` para definir a oferta, ou `/captador-conteudo` para já começar a se posicionar.

---

## `/captador-conteudo`

**Para que serve.** Gera conteúdo de autoridade (carrossel, post de texto ou roteiro de reel) que posiciona o captador como referência em captação e atrai gestores de OSC.

**Quando usar.** Quer publicar algo esta semana para reforçar seu posicionamento.

**Contexto que ele lê.** `captador/perfil-captador.md`. Se não existir, orienta `/captador-perfil` primeiro.

**Passo a passo:**
1. Pergunta o formato: 1. Carrossel, 2. Post de texto, 3. Roteiro de reel.
2. Pergunta o ângulo, com opções sugeridas: erro que reprova, bastidor do método, mito x verdade, antes e depois, pergunta do público, edital da semana, número que choca. Você escolhe ou pede uma sugestão.
3. Pergunta (opcional) um tema específico ou dor do gestor a trabalhar.
4. Aciona o agente `posicionador-captador`, que gera a peça sempre nascendo de uma dor, dúvida ou desejo do gestor de OSC, nunca do serviço em si.

**O que entrega.** Para carrossel: os textos por card mais a legenda. Para reel: o roteiro com tempos. Para post: o texto com tese e argumento.

**Onde salva.** `captador/entregas/conteudo/`.

**Travas e dependências.** Exige `captador/perfil-captador.md` existente. Regras de escrita: sem travessão, sem ponto de exclamação, sem promessa vaga; o serviço não aparece logo no início.

**Próximo passo sugerido.** Nenhum específico; é uma entrega recorrente.

---

## `/captador-pagina`

**Para que serve.** Gera a página de captura de leads da assessoria: copy completa das 9 seções mais o HTML de arquivo único, pronto para publicar.

**Quando usar.** Precisa de um link para direcionar tráfego (bio de rede social, anúncio, indicação).

**Contexto que ele lê.** `captador/perfil-captador.md` e, se já existir, `captador/oferta.md` (gerado por `/assessoria-estruturar`).

**Passo a passo:**
1. Pergunta o objetivo da página: 1. Captar leads para uma reunião de diagnóstico, 2. Vender direto um pacote de assessoria.
2. Pergunta as provas disponíveis (projetos aprovados, depoimentos com resultado, números).
3. Pergunta a chamada para ação principal (agendar diagnóstico, chamar no WhatsApp, preencher formulário).
4. Aciona o agente `posicionador-captador`, que escreve as 9 seções (dobra inicial, problema real, método dos 4 agentes, prova, como funciona, oferta, autoridade, objeções/FAQ, chamada final) e gera o HTML no design de referência (navy e ciano), com placeholders para foto e logo.

**O que entrega.** O arquivo HTML pronto para abrir no navegador, mais a copy em markdown ao lado.

**Onde salva.** `captador/entregas/pagina/`.

**Travas e dependências.** Exige `captador/perfil-captador.md`. Não mostra o código no chat; só informa os caminhos.

**Próximo passo sugerido.** `/captador-anuncio` para levar tráfego até essa página.

---

## `/captador-anuncio`

**Para que serve.** Gera anúncios (copy e direção de criativo) para levar gestores de OSC até a página da assessoria ou o diagnóstico.

**Quando usar.** Vai investir em tráfego pago ou impulsionamento.

**Contexto que ele lê.** `captador/perfil-captador.md`.

**Passo a passo:**
1. Pergunta o objetivo: 1. Atrair quem não conhece, 2. Relacionamento com quem já segue, 3. Conversão para diagnóstico ou contratação.
2. Pergunta a dor ou desejo principal a tocar (depender de um financiador, reprovar sempre, perder prazos, querer previsibilidade).
3. Pergunta o destino (página da assessoria, WhatsApp, perfil).
4. Aciona o agente `posicionador-captador`, que gera o gancho (tocando a dor, nunca o serviço), dois parágrafos de argumento com tese, chamada para ação, e a direção do criativo, com variações por objetivo.

**O que entrega.** A copy do anúncio e a direção do criativo.

**Onde salva.** `captador/entregas/anuncios/`.

**Travas e dependências.** Exige `captador/perfil-captador.md`.

**Próximo passo sugerido.** Nenhum específico.

---

# ÁREA 6. VENDA E PRESTAÇÃO DO SERVIÇO (FASE 2 E 3. OFERTA E ASSESSORAR)

## `/assessoria-estruturar`

**Para que serve.** Estrutura o serviço de assessoria do captador: o que entra, em quais pacotes, por quanto, e gera a proposta comercial pronta para apresentar.

**Quando usar.** Antes de sair vendendo: precisa decidir o que está oferecendo e por quanto.

**Contexto que ele lê.** `captador/perfil-captador.md`.

**Passo a passo:**
1. Pergunta os modelos que quer oferecer: 1. Proposta avulsa, 2. Triagem de edital avulsa, 3. Contrato anual, 4. Combinação.
2. Pergunta a capacidade de entrega (quantos editais por mês consegue atender, sozinho ou com apoio).
3. Pergunta a faixa de preço pretendida em cada modelo.
4. Pergunta o que incluir e o que deixar de fora do escopo.
5. Monta os pacotes (nome, escopo, entregáveis, número de editais cobertos, preço), a precificação ancorada (proposta avulsa R$ 3.000 a R$ 8.000, contrato anual R$ 20.000 a R$ 30.000, ancorada no valor de um edital aprovado), o modelo de cobrança e a proposta comercial com as 5 objeções mais comuns já respondidas.

**O que entrega.** A oferta estruturada da assessoria e a proposta comercial pronta para apresentar a uma OSC.

**Onde salva.** `captador/oferta.md` e a proposta comercial em `captador/entregas/comercial/`.

**Travas e dependências.** Exige `captador/perfil-captador.md`. Preço sempre com lógica e ancoragem, nunca no chute.

**Próximo passo sugerido.** `/captador-pagina` para publicar a oferta, ou `/assessoria-pitch` para o roteiro da reunião de venda.

---

## `/assessoria-pitch`

**Para que serve.** Gera o playbook completo de venda do contrato anual de assessoria para uma OSC específica, com script consultivo e objeções mapeadas.

**Quando usar.** Vai ter uma reunião de fechamento com uma organização prospectada.

**Contexto que ele lê.** `minhas-oscs/.ativa` e o `perfil-osc.md` (a OSC ativa pode ser o alvo da proposta ou um caso de referência).

**Passo a passo:**
1. Pergunta qual OSC é o alvo da proposta de assessoria.
2. Pergunta o modelo de cobrança pretendido: 1. Proposta avulsa (R$ 3.000 a R$ 8.000), 2. Contrato anual (R$ 20.000 a R$ 30.000), 3. Misto.
3. Pergunta a dor principal dessa OSC (não capta, depende de um financiador, perde prazos, reprova sempre).
4. Monta o playbook: abertura consultiva (diagnóstico da situação de captação), reconhecimento da dor com os 4 motivos de reprovação, apresentação do serviço como linha de montagem dos 4 agentes (com o diferencial do CaptaScore), ancoragem de valor, proposta comercial com escopo e valor, objeções mapeadas com respostas ("e se não aprovar?", "por que pagar antes do resultado?", "já tentamos sozinhos") e o fechamento.

**O que entrega.** O playbook completo, pronto para conduzir a reunião.

**Onde salva.** `minhas-oscs/{ativa}/assessoria/pitch-{osc-alvo}.md`.

**Travas e dependências.** Nenhuma. O argumento é sempre ancorado em dado e no método, sem promessa vazia.

**Próximo passo sugerido.** A própria reunião de fechamento.

---

# ÁREA 7. APOIO E SISTEMA

## `/configurar`

**Para que serve.** Centraliza as conexões e integrações da AMC IA num único lugar.

**Quando usar.** Configuração inicial do projeto, ou ajuste de alguma integração.

**Contexto que ele lê.** Nenhum específico; é um menu de opções.

**Passo a passo.** Pergunta o que você quer fazer:
1. Conectar ao CaptaHub (encaminha para `/captahub-conectar`).
2. Atualizar os editais agora (roda o script que puxa do CaptaHub e atualiza o cache local).
3. Configurar geração de imagens, opcional, para os criativos da Fase 2 (`OPENROUTER_API_KEY` no `.env`).

**O que entrega.** A integração configurada e testada, conforme a opção escolhida.

**Onde salva.** Variáveis no `.env` da raiz do projeto.

**Travas e dependências.** Tokens e chaves só no `.env`, nunca em outro arquivo; sempre mascarados na exibição.

**Próximo passo sugerido.** Depende da opção escolhida.

---

## `/sala-agentes`

**Para que serve.** Abre a Sala dos Agentes: um escritório visual em pixel art que mostra em tempo real qual agente está trabalhando e em que etapa, conforme o sistema executa.

**Quando usar.** Quer acompanhar visualmente o sistema em ação, ou mostrar para alguém como o método funciona.

**Contexto que ele lê.** O hook `agentes-status.py` já grava o status do agente ativo a cada ação; a página lê esse arquivo a cada 2 segundos.

**Passo a passo.** Executa direto o arquivo `abrir-sala-dos-agentes.bat` na raiz do projeto, que abre a página no navegador padrão sozinho, sem precisar de nenhum clique seu. Se o comando falhar, informa o caminho do `.bat` para você abrir manualmente com dois cliques (nunca clicando no `.html` dentro do editor, que só mostra o código-fonte).

**O que entrega.** A página aberta no navegador, com um boneco por agente (MINERADOR, CAPTADOC, CAPTABUILDER, CAPTABUDGET, CAPTASCORE, POSICIONADOR, ORQUESTRADOR), cada um andando até sua estação e mostrando a atividade num balão, conforme os comandos rodam.

**Onde salva.** Não gera arquivo; é uma visualização ao vivo.

**Travas e dependências.** Funciona sem servidor. O selo "claude ativo/inativo" só acende quando há atividade recente; se tudo estiver parado, é porque nada aconteceu nos últimos segundos, não é erro.

**Próximo passo sugerido.** Deixar a aba aberta ao lado enquanto trabalha nos outros comandos.

---

# ÁREA 8. AGENTES ESPECIALISTAS (POR TRÁS DOS COMANDOS)

Os comandos acima acionam agentes especializados. Normalmente você não invoca um agente diretamente, mas é útil saber quem faz o quê:

| Agente | Acionado por | O que faz |
|---|---|---|
| **CaptaDoc** (`captador-doc`) | `/projeto-elegibilidade` | Triagem documental e elegibilidade. Guardião do Gate de Elegibilidade. |
| **CaptaBuilder** (`captador-builder`) | `/projeto-escrever` | Elaboração estratégica da proposta, bloco a bloco. |
| **CaptaBudget** (`captador-budget`) | `/projeto-orcamento` | Orçamento técnico por rubrica, com memória de cálculo e pesquisa de preço quando o edital exige. |
| **CaptaScore** (`captador-score`) | `/projeto-avaliar` | Avaliação com visão de banca: nota, chance de aprovação, reescrita dos campos críticos. |
| **revisor-proposta** | `/projeto-revisar` | Revisão final de completude, coerência e português antes da submissão. |
| **minerador-editais** | `/edital-minerar` | Puxa e prioriza editais do CaptaHub conforme o perfil da OSC. |
| **minerador-web** | Fallback automático de `/edital-minerar` | Busca editais na web quando o CaptaHub não traz nada alinhado ao perfil. |
| **posicionador-captador** | `/captador-conteudo`, `/captador-pagina`, `/captador-anuncio` | Marketing e posicionamento do captador como negócio. |
| **orquestrador-captacao** | Uso interno | Diagnostica em que etapa da linha de montagem o captador está e direciona para o comando certo. |

---

# ÁREA 9. BASES DE CONHECIMENTO (SKILLS CONSULTADAS PELOS AGENTES)

Não são comandos, mas fundamentam as respostas dos agentes. Cite-as se quiser entender de onde vem um critério ou uma regra:

| Base de conhecimento | Consultada por | Conteúdo |
|---|---|---|
| `editais-fundamentos` | `/edital-analisar`, `/descricao-edital`, CaptaDoc | MROSC, tipos de parceria, naturezas jurídicas, plataformas de submissão, leis de incentivo. |
| `elaboracao-proposta` | CaptaBuilder | Estrutura de proposta seção a seção, como construir objetivos, metas, indicadores, metodologia e cronograma. |
| `orcamento-tecnico` | CaptaBudget | Rubricas, memória de cálculo, regras de teto e percentual, despesas vedadas, 3 cotações, glosa. |
| `avaliacao-projeto` | CaptaScore | Critérios de pontuação, fases de seleção, riscos de desclassificação, como estimar chance de aprovação. |
| `posicionamento-captador` | posicionador-captador | Público da assessoria, ângulos de conteúdo, precificação da oferta, Light Copy adaptada à captação. |

---

# FLUXO COMPLETO DE UM PROJETO, DO ZERO À SUBMISSÃO

Para visualizar a jornada inteira, do primeiro contato com a OSC até o arquivo pronto para enviar:

```
1.  /osc-nova (ou /osc-importar)      → cadastra ou importa a organização
2.  /edital-minerar                   → encontra o edital certo
3.  /edital-analisar                  → entende o edital a fundo
4.  /projeto-elegibilidade            → CaptaDoc dá o veredito (Gate de Elegibilidade)
5.  /projeto-escrever                 → CaptaBuilder escreve a proposta
6.  /projeto-orcamento                → CaptaBudget monta o orçamento
7.  /projeto-avaliar                  → CaptaScore dá a nota e a chance de aprovação
8.  /projeto-revisar                  → checklist final pré-submissão
9.  /projeto-exportar                 → gera Word, PDF e planilha
10. (no CaptaHub) atualizar o status do projeto para "submetido"
```

Em paralelo, sempre que fizer sentido: `/captahub-sincronizar` para manter a carteira e o pipeline espelhados.

---

# PERGUNTAS RÁPIDAS. "QUERO FAZER X, QUAL COMANDO USO?"

| Eu quero... | Comando |
|---|---|
| Cadastrar uma organização nova | `/osc-nova` |
| Trazer uma OSC que já está no CaptaHub | `/osc-importar` |
| Trabalhar com outro cliente agora | `/osc-trocar` |
| Ver ou corrigir os dados da organização | `/osc-perfil` |
| Achar um edital bom para a OSC ativa | `/edital-minerar` |
| Entender um edital específico a fundo (dentro de um projeto de uma OSC) | `/edital-analisar` |
| Entender rápido um edital avulso, sem vincular a nenhuma OSC | `/descricao-edital` |
| Cadastrar editais novos que chegaram na pasta de trabalho | `/editais-pasta-processar` |
| Saber se a OSC pode concorrer a este edital | `/projeto-elegibilidade` |
| Escrever a proposta do projeto | `/projeto-escrever` |
| Montar o orçamento do projeto | `/projeto-orcamento` |
| Saber a chance de aprovação antes de enviar | `/projeto-avaliar` |
| Fazer a checagem final antes de submeter | `/projeto-revisar` |
| Gerar os arquivos finais (Word, PDF, planilha) | `/projeto-exportar` |
| Conectar ou reconectar ao CaptaHub | `/captahub-conectar` |
| Colocar tudo em dia com o CaptaHub | `/captahub-sincronizar` |
| Cadastrar meu perfil como captador | `/captador-perfil` |
| Criar um post ou carrossel para atrair clientes | `/captador-conteudo` |
| Gerar minha página de captação de leads | `/captador-pagina` |
| Criar um anúncio para tráfego pago | `/captador-anuncio` |
| Definir pacotes e preços da assessoria | `/assessoria-estruturar` |
| Preparar o discurso de venda para uma OSC | `/assessoria-pitch` |
| Configurar integrações do projeto | `/configurar` |
| Ver os agentes trabalhando visualmente | `/sala-agentes` |

---

## O que NÃO existe aqui (e onde procurar)

A AMC IA não tem pipeline, kanban nem CRM. Gestão de carteira, prazos de vários projetos e status de clientes ficam **sempre no CaptaHub**. Se a dúvida for "em que pé está cada projeto" ou "quais clientes tenho no total", a resposta está lá, não em um comando desta apostila.
