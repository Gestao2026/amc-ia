# Decisões Técnicas. Registro Vivo

> Base de conhecimento de decisões de arquitetura da AMC IA. Consultar antes de propor uma solução nova para um problema que pareça familiar; registrar aqui sempre que uma decisão técnica não óbvia for tomada, para não redescutir do zero no futuro.

## Como registrar uma decisão nova

Ao final desta lista, adicione uma entrada com:

```
### SOL-000X. Título curto

Problema: {o que estava acontecendo}
Solução: {o que foi decidido}
Alternativas descartadas: {se houver}
Impacto: {o que muda na prática}
Data: {AAAA-MM-DD}
```

## Registro

### SOL-0001. Checklist completo de triagem antes do veredito do CaptaDoc

Problema: o parecer de elegibilidade podia ficar restrito à checagem documental (natureza jurídica, certidões, tempo de existência) e deixar passar exigência de outra natureza do edital (categoria errada, item vedado, critério de desempate), que só aparecia como problema mais tarde, na proposta ou no orçamento.

Solução: o CaptaDoc passou a seguir um checklist fixo de 13 dimensões do edital (dados gerais, participação, categorias, critérios, documentos, cronograma, itens financiáveis e vedados, contrapartida, acessibilidade, prestação de contas e riscos) antes de emitir o veredito. Ver `.claude/rules/checklist-triagem-captadoc.md`.

Alternativas descartadas: manter a triagem só na parte documental e deixar o CaptaBuilder reinterpretar o restante do edital do zero (gera retrabalho e risco de inconsistência entre o que o CaptaDoc aprovou e o que o CaptaBuilder assume).

Impacto: `elegibilidade.md` fica mais completo e passa a ser reaproveitado pelo CaptaBuilder para as partes que já foram checadas (categoria, itens vedados, critérios de pontuação), em vez de reler o edital do zero para isso.

Data: 2026-07-28

### SOL-0002. Caça obrigatória a exigências operacionais específicas de base de cálculo externa

Problema: a primeira versão da ficha descritiva do edital FAOP-FEC 04/2026 citou o IDHM e a população do município apenas como exemplo genérico de "critério que pontua ao contrário do intuitivo", sem extrair a tabela real de faixas e valores. Esse tipo de exigência (base de cálculo externa e variável, como IDHM, faixa de população do IBGE, renda per capita ou outro índice) muda de edital para edital e é fácil de tratar como observação lateral em vez de checagem obrigatória.

Solução: tanto o `/descricao-edital` (seção 8, quadro de avaliação e pontuação) quanto o checklist do CaptaDoc (`.claude/rules/checklist-triagem-captadoc.md`, item 6) passam a exigir a checagem explícita: existe base de cálculo externa e variável neste edital? Se sim, extrair a tabela real de faixas e valores, e indicar qual documento ou fonte prevalece para apurá-la. Se não, registrar isso explicitamente em vez de omitir a checagem.

Alternativas descartadas: manter a menção como exemplo dentro da lista geral de "pontos de atenção" (já demonstrou gerar extração incompleta na prática).

Impacto: toda ficha descritiva e todo parecer de elegibilidade passam a trazer, quando existir, a tabela exata do critério (não uma direção genérica tipo "quanto menor, mais pontua"), reduzindo o risco de a proposta perder pontos por cálculo errado dessa base.

Data: 2026-07-29

### SOL-0003. /descricao-edital passa a checar duplicidade no CaptaHub, mas não cria edital

Problema: o captador esperava que, ao gerar a ficha avulsa de um edital, o sistema também "lançasse" esse edital no CaptaHub (pipeline "Encontrar cliente"). Ao investigar, `scripts/captahub-api.py` só expõe leitura de editais (`editais`, `edital`), não existe `edital-criar`; o próprio `/editais-pasta-processar` já registra essa limitação ("ainda não existe endpoint confirmado de criação de edital via API"). `projeto-criar` também exige `cliente_id` e `edital_id` obrigatórios, então não dá para abrir um projeto no pipeline sem OSC definida.

Solução: o `/descricao-edital` continua gerando a ficha `.doc` avulsa normalmente (isso não muda). Depois disso, roda a mesma checagem de duplicidade usada pelo `/editais-pasta-processar` (`scripts/editais-pasta-checar-duplicado.py`) e, se o edital for novo, busca uma OSC compatível na carteira via `captahub-api.py clientes` (nunca lendo `minhas-oscs/`) e acrescenta o edital, com a OSC sugerida se houver, em `editais-para-cadastrar/prontos-para-cadastro.json`. O cadastro final no CaptaHub continua manual até existir endpoint de criação.

Alternativas descartadas: simular a criação chamando `projeto-criar` com um cliente fictício ou vazio (violaria a exigência de campo obrigatório da API e poderia poluir o pipeline real do CaptaHub com projetos falsos).

Impacto: `/descricao-edital` (`.claude/commands/descricao-edital.md`, Passo 5 e 6) nunca mais some sem checar o CaptaHub, mas também nunca afirma "cadastrado" quando só foi preparado localmente. Quando a API do CaptaHub ganhar um endpoint de criação de edital, revisar este comando e o `/editais-pasta-processar` juntos para automatizar o cadastro de fato.

Data: 2026-07-30

### SOL-0004. Persona compartilhada "Captador" em vez de agente novo

Problema: cada agente da CaptaSuite (CaptaDoc, CaptaBuilder, CaptaBudget, CaptaScore) abria com uma persona própria e isolada, sem fio condutor de autoridade entre eles. O captador queria sentir um único consultor sênior (25+ anos de mercado, domínio do arcabouço legal do terceiro setor) atuando nas quatro frentes, e levantou a dúvida se isso deveria ser um agente novo que "chefia" os outros ou uma persona compartilhada.

Solução: criado `.claude/rules/persona-captador.md`, lido no Passo 0 de todos os 6 agentes do sistema (CaptaDoc, CaptaBuilder, CaptaBudget, CaptaScore, orquestrador-captacao, posicionador-captador), seguindo o mesmo padrão já usado para `metodo-captar.md`. Cada agente veste essa identidade comum no parágrafo de abertura, por cima da sua especialização. A legislação específica continua exclusivamente em `.claude/skills/editais-fundamentos/SKILL.md` e no edital em análise; a persona nunca cita lei ou artigo, porque não existe hoje um dono designado para manter essa referência atualizada.

Alternativas descartadas: criar um agente "Captador" novo que efetivamente chamasse os outros quatro. Investigação técnica mostrou que nenhum agente da suíte tem a ferramenta `Agent` hoje (quem aciona cada um é a thread principal, via comando); dar essa ferramenta a um agente novo exigiria redesenhar como o Gate de Elegibilidade e os checkpoints humanos (entrevista, confirmação, aprovação) do Fluxo Padrão de 6 Passos são preservados numa execução encadeada. Essa evolução foi registrada à parte, como roadmap, em SOL-0005.

Impacto: os 6 agentes falam com uma única voz de consultor sênior, sem duplicar texto de persona nem criar uma camada de orquestração nova. `CLAUDE.md` (seção "Quem Você É") referencia o mesmo arquivo para manter o assistente principal alinhado. O arquivo foi desenhado para ser herdado por referência, permitindo a evolução de SOL-0005 sem reescrita.

Data: 2026-07-30

### SOL-0005. Roadmap. Evoluir o orquestrador-captacao para Agente Mestre "Captador"

> Status: roadmap, não implementado. Registrado para orientar quando esta evolução for planejada e executada, não como arquitetura em vigor.

Problema: hoje `orquestrador-captacao` só diagnostica o estado do projeto e recomenda o próximo comando (`.claude/agents/orquestrador-captacao.md`); ele não tem a ferramenta `Agent` e não executa CaptaDoc, CaptaBuilder, CaptaBudget ou CaptaScore. O captador quer, no futuro, um Agente Mestre "Captador" que efetivamente controle o fluxo entre os agentes e futuras ferramentas (ex: AMC-IA).

Solução planejada: evoluir o `orquestrador-captacao` existente, sem criar um segundo orquestrador. A evolução deve:
- manter `.claude/rules/persona-captador.md` como identidade principal, já herdada desde SOL-0004, sem reescrever;
- ganhar a ferramenta `Agent` para poder invocar CaptaDoc, CaptaBuilder, CaptaBudget, CaptaScore e futuras ferramentas;
- trocar a lógica de "Saída" de recomendação de comando para controle de fluxo real (decidir e invocar o próximo agente, em vez de só indicar o comando);
- absorver o Gate de Elegibilidade como condição de parada dentro do próprio fluxo, não mais dependente de um humano decidir não rodar o próximo comando;
- preservar os checkpoints humanos (entrevista por blocos do CaptaBuilder, confirmação antes de gerar, aprovação antes de salvar) que hoje existem naturalmente porque cada agente é chamado numa conversa direta com o captador. Isso precisa ser desenhado com cuidado na execução encadeada, para não perder qualidade.

Alternativas descartadas: criar um agente "Captador" separado do `orquestrador-captacao` (duplicaria a responsabilidade de diagnóstico de estado que já existe hoje).

Impacto quando implementado: muda o modelo de execução de "comando por comando, com um humano no meio" para "fluxo controlado pelo Agente Mestre, com checkpoints preservados por desenho". É uma mudança de execução mais profunda que SOL-0004; não deve ser feita sem uma sessão de planejamento própria quando chegar o momento.

Data: 2026-07-30

### SOL-0006. Correção de arquitetura: edital novo vira Controle no CaptaHub, nunca escrita na base de editais

Problema: SOL-0003 partiu da premissa errada de que o caminho certo era, um dia, escrever diretamente na base de editais (`POST /v1/editais`). Teste real confirmou `POST /v1/editais` como `404` ("Rota não encontrada"), e uma investigação mais ampla (código, documentação técnica, material de treinamento do CaptaHub) não achou nenhuma variante de escrita de edital, nem endpoint, nem fluxo oficial de importação. Ficou definido que a base de editais é administrada pelo próprio CaptaHub e não deve ser escrita pela AMC IA. O destino correto da automação é outro: abrir um **Controle** no pipeline (o mesmo efeito do botão "Novo Controle" da tela), começando na etapa "Encontrar cliente".

Solução: testado ao vivo (30/07/2026) que `POST /v1/projetos` aceita a criação de um Controle **sem** `cliente_id` nem `edital_id` (contrariando o que `criar_projeto` supunha como obrigatório), com o card nascendo direto no `status` pedido. Criado `criar_controle` em `scripts/captahub-api.py` (subcomando `controle-criar`), que chama exatamente essa rota. `/descricao-edital` (Passo 5) e `/editais-pasta-processar` (Passo 6) passaram a checar duplicidade de Controle (não mais de edital) e, se novo, chamar `controle-criar` com `--status encontrar_cliente`, sem vincular OSC automaticamente mesmo quando uma candidata compatível é encontrada (fica só informativo, para o captador confirmar). `editais-para-cadastrar/prontos-para-cadastro.json` foi substituído por `editais-para-cadastrar/controles-criados.json` nesse fluxo.

Limite real confirmado no mesmo teste, e que precisa ficar visível para quem mexer nisso depois: o campo `edital` (dict com os dados extraídos do edital) é aceito pelo servidor no `POST /v1/projetos`, mas **não é persistido** (a resposta voltou com `edital_id: null`, nenhum subcampo do objeto `edital` retornado). Por isso os dois comandos continuam gravando os campos extraídos do edital localmente (`controles-criados.json`), porque o CaptaHub hoje não guarda essa informação em lugar nenhum recuperável pela API.

Alternativas descartadas: manter a hipótese de SOL-0003 (aguardar um `POST /v1/editais` que nunca foi confirmado); tentar vincular a OSC compatível automaticamente na criação do Controle (violaria o pedido explícito de sempre nascer em "Encontrar cliente", mesmo com candidata óbvia).

Impacto: `docs/especificacao-endpoint-criacao-edital.md` fica marcado como superado (a pergunta que ele respondia deixou de ser o caminho certo). `docs/integracao-captahub-api.md` ganha o subcomando `controle-criar` e uma seção explicando a distinção Edital (leitura) vs. Controle (escrita real). Se o CaptaHub um dia passar a persistir o campo `edital` de fato, revisar `criar_controle` e os dois comandos para parar de duplicar o dado localmente.

Data: 2026-07-30

### SOL-0007. Regra de negócio oficial de dedup, compatibilidade e posicionamento no pipeline de Controle

> Status: arquitetura oficial registrada. A checagem de terminologia (ponto 4) já está conforme (nenhuma correção necessária). Os pontos 1, 2, 3 e 5 ainda não estão implementados de ponta a ponta; ver lacunas ao final, deixadas propositalmente para uma sessão de implementação própria, a pedido do captador.

Problema: a criação de Controle no CaptaHub cresceu em mais de uma origem (`/descricao-edital`, `/editais-pasta-processar`, e futuramente a mineração via `/edital-minerar`) sem uma regra de negócio única. Investigação do estado atual encontrou:

- Dois mecanismos de dedup diferentes e não compartilhados: `scripts/editais-pasta-checar-duplicado.py` (título+órgão normalizados, limiar 0,82, ou URL idêntica) checa duplicidade contra o **catálogo de editais**, só usado por `/editais-pasta-processar`; já a duplicidade de **Controle** é checada de forma manual e ad hoc, comparando `nome` "muito parecido" contra `projetos --all`, duplicada inline em `/descricao-edital` (Passo 5.1) e `/editais-pasta-processar` (Passo 6.1), sem reaproveitar a mesma função de similaridade.
- A origem "mineração" (`/edital-minerar`, agentes `minerador-editais` e `minerador-web`) hoje não cria Controle nenhum (só sugere abrir a pasta local `projetos/{slug}/edital.md`), logo não tem nenhuma checagem de duplicidade de Controle.
- A busca de OSC compatível já existe em `/descricao-edital` (Passo 5.3), mas por decisão explícita do SOL-0006 é **só informativa**: o Controle nasce sempre em `encontrar_cliente`, mesmo com uma candidata óbvia. `/editais-pasta-processar` nem faz essa busca.
- Terminologia: `[Ee]ncontrar[ _-]?(OSC|osc|organiza[çc][ãa]o)` não teve nenhuma ocorrência no repositório. "Encontrar cliente" (rótulo) e `encontrar_cliente` (status) já são o único termo usado em comandos, script e documentação. Nada a corrigir neste ponto.

Solução: fica registrada como arquitetura oficial da integração, a partir de agora, a seguinte regra de negócio (substitui a parte do SOL-0006 que mandava nunca vincular OSC automaticamente):

1. **Dedup obrigatório antes de qualquer criação de Controle**, independentemente da origem (CaptaHub, Web avulsa, Pasta Local ou mineração). Um edital nunca gera dois Controles. Se já existir Controle para aquele edital, ele é atualizado, nunca duplicado.
2. **Verificação de compatibilidade com a carteira de OSCs só roda quando o edital é realmente novo** (passou pelo dedup do ponto 1 sem encontrar Controle existente).
3. **Fluxo de posicionamento no pipeline:** havendo OSC compatível, o Controle nasce já vinculado a ela (`cliente_id` preenchido) na etapa **Selecionado**; não havendo, nasce sem vínculo na etapa **Encontrar cliente**.
4. **Nome oficial da etapa 2: "Encontrar cliente"** (status `encontrar_cliente`). Qualquer variante ("Encontrar OSC", "Encontrar organização") é incorreta e deve ser substituída onde aparecer.
5. **Regra de ouro:** um edital existe no máximo uma vez no pipeline. Status muda, OSC vinculada muda, dados são enriquecidos; nunca existem dois Controles para o mesmo edital.

Alternativas descartadas: manter a dedup de Controle fragmentada por comando (risco real de um comando bloquear uma duplicata que outro deixaria passar, já que não compartilham a mesma lógica de comparação hoje); manter a decisão do SOL-0006 de nunca vincular OSC automaticamente (foi uma escolha deliberada na época, mas o captador decidiu agora que compatibilidade clara deve vincular e pular direto para "Selecionado", encurtando o funil manual).

Impacto: esta entrada registra a regra de negócio, não a implementação. Fica pendente, para quando o captador pedir a implementação:
- Extrair a checagem de duplicidade de Controle para uma função única (reaproveitando ou espelhando `editais-pasta-checar-duplicado.py`, mas comparando contra `projetos --all`/Controles existentes, não contra o catálogo de editais), chamada por `/descricao-edital`, `/editais-pasta-processar` e por um futuro fluxo de criação de Controle a partir da mineração.
- Adicionar ao `edital-minerar`/`minerador-editais`/`minerador-web` a criação de Controle (hoje inexistente), já seguindo esta regra.
- Ajustar `/descricao-edital` (Passo 5.3) e `/editais-pasta-processar` (que hoje não busca OSC) para vincular automaticamente e escolher o status inicial (`selecionado` vs `encontrar_cliente`) conforme o ponto 3, substituindo o comportamento "sempre informativo, nunca vincula" herdado do SOL-0006.
- Definir o critério objetivo de "OSC compatível o suficiente para vincular automaticamente" (hoje a aderência do `/edital-minerar` é qualitativa, ALTA/MÉDIA/BAIXA; decidir se some um piso mínimo, ex: só vincula automaticamente aderência ALTA).

Data: 2026-07-31

### SOL-0008. Implementação do SOL-0007: `controle-resolver.py` e dois bugs reais corrigidos no caminho

Problema: o SOL-0007 registrou a regra de negócio, mas nada foi implementado. O captador pediu a implementação, com prioridade explícita: um mecanismo central único, reutilizado pelas três origens que hoje criam Controle (`/descricao-edital`, `/editais-pasta-processar`, `/edital-minerar`), antes de qualquer novo trabalho na sincronização da tela "Editar Controle".

Solução: criado `scripts/controle-resolver.py`, único ponto de decisão de dedup + compatibilidade + etapa inicial do pipeline (documentado em `docs/integracao-captahub-api.md`, seção 3.5). Não escreve no CaptaHub, só decide; os três comandos (`.claude/commands/descricao-edital.md` Passo 5, `editais-pasta-processar.md` Passo 6, `edital-minerar.md` Passo 4.1, este último novo, mineração não abria Controle antes) passaram a chamá-lo e agir sobre o resultado.

Decisões de parâmetro tomadas nesta implementação (ajustáveis, documentadas como constantes no topo do script):
- Dedup de Controle: `edital_id` exato quando conhecido; senão título normalizado contra o `nome` dos Controles existentes, `SequenceMatcher`, limiar 0,82 (mesmo limiar do dedup de catálogo já existente, para previsibilidade, mesmo sendo um sinal mais fraco já que o Controle não guarda instituição nem link).
- Pontuação de compatibilidade edital -> OSC (direção inversa da já existente em `minerar-editais.py`, que pontua editais para uma OSC): categoria exata +3, categoria aproximada +2, palavra-chave (até 3) +1 cada, território local +4, alcance nacional/internacional +1, fora do território -6.
- Bandas: ALTA (score ≥ 6), MÉDIA (≥ 3), BAIXA (resto). **Só ALTA vincula automaticamente** (`BANDA_MINIMA_PARA_VINCULO_AUTOMATICO = "ALTA"`), resolvendo a pendência que o SOL-0007 tinha deixado em aberto. Critério deliberadamente conservador: evitar vínculo errado de OSC direto na etapa Selecionado.
- `--cliente-id` no resolvedor: modo alternativo que avalia compatibilidade só contra uma OSC específica (não a carteira inteira), usado por `/edital-minerar`, que já opera no contexto da OSC ativa.

Bugs reais encontrados e corrigidos durante a implementação (não hipotéticos, reproduzidos):
1. **Marcador de bloco machine-readable inexistente.** `editais-pasta-checar-duplicado.py` (e o rascunho inicial deste resolvedor) procuravam o texto fixo `=== JSON ===` na saída de `captahub-api.py`, mas o script sempre imprime `=== {RÓTULO} ===` (`=== EDITAIS ===`, `=== PROJETOS ===`, `=== CLIENTES ===`...). Isso nunca gerava exceção, então o efeito era silencioso: `buscar_captahub()` sempre retornava lista vazia, e a checagem de duplicidade ao vivo contra o CaptaHub em `/editais-pasta-processar` nunca funcionou de fato, mesmo com o CaptaHub conectado (caía sempre para "sem duplicata" sem avisar). Corrigido nos dois arquivos: busca por regex `^=== .+ ===$` em vez de string fixa.
2. **Ordem de impressão invertida em `cmd_projeto` e `cmd_cliente`.** Essas duas funções imprimiam o bloco `=== JSON ===` antes da linha de texto legível (`cmd_edital`, ao lado, já fazia na ordem certa: texto primeiro, JSON por último). Isso quebra qualquer parser que leia "tudo depois do marcador" (o JSON fica com uma linha de texto solta depois, erro de parsing). Só apareceu porque o resolvedor precisou chamar `projeto --id`/`cliente --id` pela primeira vez de forma automatizada; nenhum uso anterior desses dois subcomandos dependia de parsear a saída via `=== JSON ===`. Corrigido invertendo a ordem das duas linhas em ambas as funções.
3. **Windows decodifica `subprocess.run(..., text=True)` em cp1252 por padrão**, mas a saída do processo filho é UTF-8 (`sys.stdout.reconfigure`); com acento no texto (comum em pt-BR), a leitura do stdout quebrava com `UnicodeDecodeError`. Corrigido passando `encoding="utf-8"` explicitamente nas duas chamadas de `subprocess.run` (`controle-resolver.py` e `editais-pasta-checar-duplicado.py`).

Também estendido `projeto-atualizar` (`scripts/captahub-api.py`) com `--cliente-id` e `--edital-id`, ausentes até então na CLI (o método do cliente já aceitava qualquer campo via `**campos`, só a CLI não expunha), necessários para o backfill do ponto 3 do SOL-0007 (edital já existente ganha o vínculo ou o `edital_id` que ainda não tinha).

Testado ao vivo (31/07/2026) contra o pipeline real: duplicidade por `edital_id` exato, duplicidade por título (100% de similaridade), edital novo sem OSC compatível na carteira, edital novo com aderência MÉDIA (não vincula) e edital novo com aderência ALTA (vincula e sugere `selecionado`), nos dois modos (carteira inteira e `--cliente-id` específico).

Alternativas descartadas: manter a checagem de compatibilidade qualitativa (ALTA/MÉDIA/BAIXA por julgamento do agente, como o `minerador-editais` já faz) em vez de uma pontuação determinística; descartada porque o vínculo automático de OSC é uma ação de escrita (não só uma recomendação em texto), e precisa de um critério reproduzível e testável, não uma estimativa de agente que pode variar entre execuções.

Impacto: o que fica explicitamente fora desta implementação, por pedido do captador ("somente após essa validação voltaremos à sincronização da tela Editar Controle"):
- Nenhum enriquecimento de campo (Descrição, Prazo, Categoria, Valor do Captador etc.) em Controle já existente. A ação "atualizar" do SOL-0007, nesta fase, significa só "não duplicar" mais o backfill pontual de `edital_id`/`cliente_id` quando estavam nulos.
- A pontuação de compatibilidade aqui é independente da lógica qualitativa do `minerador-editais` (que ranqueia editais para uma OSC); as duas podem, em tese, divergir de rótulo (ALTA/MÉDIA/BAIXA) para o mesmo par edital-OSC, porque respondem perguntas de direção inversa com heurísticas próprias. Não foi unificado nesta rodada.
- Próximo passo combinado com o captador: testes com editais reais para validar ausência de duplicidade end-to-end, antes de retomar a decisão pendente sobre a sincronização da tela "Editar Controle" (captura de rede feita, mas decisão entre pedir ao CaptaHub vs. usar a rota crua do Supabase ainda em aberto).

Data: 2026-07-31

### SOL-0009. Checagem obrigatória de prazo vencido, e relatório unificado de tudo que não virou Controle novo

Problema: `/editais-pasta-processar` extraía o campo `deadline` de cada edital (Passo 4), mas nunca comparava com a data atual antes de abrir o Controle no CaptaHub. Um edital com inscrição já encerrada podia virar Controle normalmente, poluindo o pipeline com oportunidades que não podem mais ser buscadas. Além disso, o relatório final já informava duplicados (catálogo, Passo 5, e Controle, Passo 6) e vencidos em blocos e formatos diferentes, dificultando ver de uma vez tudo que não gerou Controle novo e por quê.

Solução: adicionado o Passo 4.1 ao comando (`.claude/commands/editais-pasta-processar.md`), obrigatório em toda execução: para todo edital com `is_continuous: false` e `deadline` preenchido, compara com a data de hoje. Se vencido, o edital não passa pela checagem de duplicidade (Passo 5) nem pelo resolvedor de Controle (Passo 6), e não é movido para `processados/` (fica na pasta para o captador decidir o destino). O relatório final (Passo 7) foi reformulado: vencidos e duplicados (tanto duplicado no catálogo de editais quanto duplicado como Controle já existente no pipeline) entram juntos numa única seção "Não viraram Controle novo no CaptaHub", cada item com seu status (vencido / duplicado no catálogo / duplicado no pipeline). Programas contínuos (`is_continuous: true`) ou sem `deadline` informado não entram na checagem de vencimento, por não terem vencimento.

Alternativas descartadas: deixar o captador conferir manualmente o prazo depois de ver o relatório de Controles criados (o pedido explícito foi tornar essa checagem parte fixa do processo); manter vencidos e duplicados em seções separadas do relatório (o captador pediu explicitamente a visão consolidada, com status por item).

Impacto: todo cadastro em lote via `/editais-pasta-processar` filtra editais vencidos automaticamente e relata, numa lista só, tudo que não resultou em Controle novo (vencido ou duplicado), com o motivo de cada um. O arquivo do edital vencido permanece em `editais-para-cadastrar/`; os duplicados continuam sendo movidos para `processados/`, por já estarem tratados.

Data: 2026-08-06

### SOL-0010. Fechada a decisão pendente do SOL-0008: API do CaptaHub não aceita os campos da tela "Editar Controle"

Problema: o SOL-0008 tinha deixado em aberto se a sincronização campo a campo da tela "Editar Controle" (Prazo do Edital, Fluxo Contínuo, Valor do Projeto, Valor do Captador, Categoria, Abrangência, Descrição, Link do Edital, upload de PDF com preenchimento automático por IA) devia usar um endpoint oficial a pedir ao CaptaHub ou a rota crua do Supabase por trás da tela. O captador pediu explicitamente para essa etapa (preencher o Controle depois de criado) entrar no processo de cadastro em lote.

Solução: testado ao vivo em produção, `PATCH /v1/projetos/{id}` no Controle da Ambipar (`628e9afb-26c0-45a1-9257-8bb0ad69f475`) com os nomes prováveis desses campos (`prazo`, `deadline`, `is_continuous`, `categoria`, `category`, `abrangencia`, `scope`, `valor_captador`, `link_edital`, `url`). Resposta: `HTTP 422 validation_error: Nenhum campo válido para atualizar`. Confirmado que a API pública do CaptaHub, hoje, só aceita escrever em `nome`, `descricao`, `status`, `nota_tecnica`, `chance_aprovacao`, `valor_solicitado`, `valor_aprovado`, `data_submissao`, `cliente_id`, `edital_id` num Controle (`GET /v1/projetos/{id}` também confirma que o objeto retornado só tem essas chaves, nenhuma das seis citadas acima existe no schema). O upload de PDF com IA não tem endpoint equivalente conhecido. Decisão do captador: por ora, esses seis campos e o PDF ficam manuais, preenchidos por ele direto na tela do CaptaHub. `/editais-pasta-processar` (Passo 6.1) passou a montar, para cada Controle novo, um bloco pronto com os dados já extraídos do edital (Passo 4) para colar nesses campos, incluindo o caminho do arquivo a anexar; `Valor do Captador` é sinalizado como "definir com o captador" (não vem do edital).

Alternativas descartadas: usar a rota crua do Supabase por trás da tela (SOL-0008 já cogitava isso) — descartada pelo captador por ser rota não documentada e não oficial, que pode mudar ou quebrar sem aviso; pedir ao CaptaHub para expor esses campos na API — fica como possibilidade futura, mas não bloqueia o processo agora.

Impacto: fecha a pendência do SOL-0008. `/editais-pasta-processar` nunca mais tenta (nem promete) preencher prazo, categoria, abrangência, valor do captador, link do edital ou anexar PDF via API; em vez disso entrega ao captador, no relatório final, o texto pronto para colar manualmente em cada Controle novo. Se o CaptaHub um dia expuser esses campos na API, revisar o Passo 6.1 para voltar a escrever automaticamente.

Data: 2026-08-06

### SOL-0011. Destino fixo dos editais vencidos: pasta externa de histórico, não `editais-para-cadastrar/`

Problema: o SOL-0009 definiu que o edital vencido não é processado (não roda duplicidade nem Controle), mas deixava o arquivo parado dentro de `editais-para-cadastrar/` "para o captador decidir depois". Na prática, isso empilhava arquivo vencido misturado com arquivo ainda não processado na mesma pasta de trabalho, e a decisão sobre onde arquivar ficava manual toda vez.

Solução: o captador já mantém, fora do amc-ia, uma pasta de histórico dedicada a isso (`C:\Users\rosep\Desktop\_82 - Rosepaula Aparecida Andrade Rodrigues\04 - Controle de Submissão_\01 - Mineração de Editais\04 - Histórico de Editais _ Não Submetidos`, irmã da pasta matriz já usada como origem padrão, ver `[[reference_pasta_matriz_editais]]`), organizada em subpastas por instituição/edital. `/editais-pasta-processar` (Passo 4.1) passou a mover automaticamente o arquivo do edital vencido para lá (subpasta existente da mesma instituição/edital, se houver, ou subpasta nova numerada em sequência), em vez de deixá-lo em `editais-para-cadastrar/`.

Alternativas descartadas: manter o arquivo em `editais-para-cadastrar/` só marcado como vencido no relatório (é o comportamento anterior, do SOL-0009; gerava acúmulo manual repetido); criar essa pasta de histórico dentro do próprio amc-ia (o captador já tem e usa uma estrutura própria no Desktop para isso, replicar duplicaria organização).

Impacto: `.claude/commands/editais-pasta-processar.md` (Passo 4.1 e Passo 7) documenta o caminho fixo e a regra de subpasta por instituição. Editais vencidos nunca mais ficam soltos em `editais-para-cadastrar/` depois da execução do comando.

Data: 2026-08-07

### SOL-0012. Sincronização automática diária corrigida, e confirmado: commit local automático, push sempre manual

Problema: a tarefa do Agendador de Tarefas do Windows `AMC-IA-SincronizacaoDiaria` (roda `scripts/sincronizacao-diaria.py` todo dia às 06h, faz commit local do que passa numa checagem técnica básica de sintaxe Python/JSON, nunca dá push) estava falhando todos os dias desde 02/08/2026 (código de erro 2). Causa raiz: a ação da tarefa apontava para `C:\Users\rosep\OneDrive - Organizacao Multidisciplinar De Voluntariado E-missao\Documentos\amc-ia\scripts\sincronizacao-diaria.py`, caminho de antes do projeto ser movido para `C:\amc-ia` (onde vive hoje); a tarefa nunca foi atualizada na migração. Investigação também achou uma pasta duplicada, `C:\amc-ia - Copia`, um clone antigo do mesmo repositório (ainda com o remote `upstream` do fork original configurado), provável resíduo dessa mesma migração; não está associada a nenhuma tarefa agendada ativa e não foi mexida.

Solução: corrigido o argumento da tarefa via `Set-ScheduledTaskAction` para `C:\amc-ia\scripts\sincronizacao-diaria.py`, testado rodando o script manualmente (funcionou, commit local criado). Na mesma conversa, o captador colocou em pauta se valia a pena eliminar a intervenção manual por completo (também automatizar o push). Decisão explícita do captador: manter como está, commit automático diário sim, push para o GitHub sempre por pedido manual (numa conversa aqui ou direto pelo captador). Motivo discutido: a checagem do script só pega quebra técnica de sintaxe (Python/JSON), nunca conteúdo (valor errado, dado sensível que entrou sem querer); o repositório carrega dados reais de captação, então o push continua exigindo alguém ter olhado antes, como já dizia o comentário original do próprio script.

Alternativas descartadas: automatizar também o push (ex: rodar `git push` no fim do `sincronizacao-diaria.py`, ou outra tarefa agendada separada para isso) — descartada explicitamente pelo captador nesta conversa, por remover o único ponto de revisão humana antes de publicar no GitHub.

Impacto: a tarefa diária volta a funcionar a partir de 08/08/2026. Fica registrado, para não ser revisitado à toa: este projeto nunca deve ganhar push automático sem pedido explícito do captador, mesmo que o commit local continue automatizado. Se a pasta `C:\amc-ia - Copia` um dia for confirmada como lixo de migração, pode ser removida manualmente (fora do escopo desta decisão).

Data: 2026-08-07

### SOL-0013. Pasta `_82` sincroniza em mão única: a Área de Trabalho manda, o Google Drive só recebe

Problema: o captador relatou que a pasta `_82 - Rosepaula Aparecida Andrade Rodrigues` da conta do Google (gestao.mobilizando@gmail.com) estava atualizando a pasta de mesmo nome na Área de Trabalho, e queria o sentido contrário: só a Área de Trabalho pode alterar a cópia no Drive. A primeira hipótese, investigada e descartada, foi o próprio app Drive para computador. Ele está em modo "Transmitir" (unidade `G:`) e a tabela `roots` do `root_preference_sqlite.db` está vazia, ou seja, nenhuma pasta do computador configurada para sincronizar. A causa real era outra: a tarefa agendada do Windows `AMC-IA-Sincronizar-Pasta82` (todo dia à 01h) executa `C:\Users\rosep\Scripts\sincronizar-pasta-82\sincronizar-pasta-82.ps1`, script fora do repositório amc-ia, que fazia reconciliação **bidirecional**. Os logs comprovam a descida indesejada: 744 arquivos do Drive para o Desktop em 02/08/2026, 264 em 06/08, 41 em 07/08 e 156 em 08/08.

Solução: removido do script apenas o bloco que copiava do Drive para o Desktop. Ele passou a registrar no log o que existe só no Drive ("Existe so no Drive, ignorado (mao unica)") em vez de baixar. Os outros dois blocos ficaram intactos: envio Desktop para Drive, e conflito de tamanho resolvido a favor do Desktop. O script continua **nunca apagando arquivo** em nenhum dos dois lados, o que é justamente o que dispensou a alternativa de espelho. Antes de aplicar a mudança, foi feito um resgate único (`robocopy /E /XC /XN /XO`, que não sobrescreve nada existente) trazendo do Drive para o Desktop os 4 arquivos reais que só existiam na nuvem: `Viabilidade 14-01-2025[1].pdf`, `Lei Utilidade Pública Organização Multidisciplinar[1].pdf`, `FireShot Capture 001 - Programa PAPS 2027` (os três da E-Missão) e `Mídia Kit 2026.pdf` (STK Produções). Isso importa porque, pela regra `.claude/rules/fonte-documentos-clientes.md`, a pasta local `06 - Clientes` é a fonte única de verdade documental, e depois desta mudança nada mais desce automaticamente. Também foi apagada a tarefa `AMC-IA Backup Drive` (criada em 03/08/2026, rodava de hora em hora, chamava `C:\Users\rosep\.amc-ia-backup\backup.ps1`, arquivo e pasta inexistentes, sem nenhuma referência no repositório, falhando desde a criação).

Testado ao vivo (08/08/2026) com três arquivos de controle numa subpasta temporária, depois removidos dos dois lados: arquivo criado só no Drive não desceu; arquivo criado só no Desktop subiu; arquivo existente nos dois lados com tamanhos diferentes teve a versão do Drive sobrescrita pela do Desktop.

Alternativas descartadas: espelho unidirecional com `robocopy /MIR` agendado (foi o plano inicial, montado quando ainda se achava que a causa era o app do Drive) — descartado porque `/MIR` apaga no destino tudo que não existe na origem, e a simulação mostrou que isso apagaria do Google 3 documentos em formato nativo (`.gdoc`) que não têm cópia possível em disco: Edital de Convocação e Lista de presença da Assembleia da Levanta e Brilha, e o Projeto Elas no Esporte da Ponto Cultural. Configurar o sentido único no próprio app do Drive — impossível, o Drive para computador só opera em mão dupla, tanto em "Espelhar" quanto em "fazer backup de pasta do computador".

Impacto: a partir de 08/08/2026 a pasta `_82` da Área de Trabalho é a fonte da verdade e o Drive é só destino. Consequências a não esquecer: (1) nunca ativar "Espelhar" nem "Fazer backup desta pasta" no app do Drive para a `_82`, porque isso reintroduz a mão dupla e não existe configuração no app que impeça; (2) arquivo apagado no Desktop continua existindo no Drive, já que o script não apaga nada; (3) arquivos nativos do Google (`.gdoc`, `.gsheet`, `.gslides`) nunca terão cópia local, só saem de lá baixados manualmente como Word ou PDF. O script vive fora deste repositório, em `C:\Users\rosep\Scripts\sincronizar-pasta-82\`, com logs por execução na subpasta `logs\`.

Data: 2026-08-08

### SOL-0014. Colchete em nome de arquivo é curinga no PowerShell: usar sempre `-LiteralPath`

Problema: ao testar a sincronização da pasta `_82` (ver SOL-0013), notou-se que os mesmos 5 arquivos eram copiados em toda execução e nunca chegavam ao Google Drive. O script reportava "copiado" e `0 erros`, mas o arquivo não existia no destino. Causa raiz: os 5 arquivos tinham colchete no nome (`[PRORROGADO]202604_.pdf`, `...Multidisciplinar[1].pdf`, `...[www.papsfsa.com.br].pdf`, `...11°[1] (1).pdf`, `..._Ano_I[1] (1).docx`) e o script usava `Copy-Item -Path`. O parâmetro `-Path` interpreta `[` e `]` como classe de caracteres curinga, então o padrão passava a mirar um arquivo inexistente e a cópia não acontecia, sem gerar erro capturável. O efeito era o pior possível: perda silenciosa de backup, com o log afirmando sucesso.

Solução: trocado `-Path` por `-LiteralPath` em todas as leituras e cópias de `sincronizar-pasta-82.ps1` (`Get-ChildItem`, `Test-Path`, `Copy-Item`), e substituído `Join-Path`/`Split-Path -Parent` por concatenação direta e `[System.IO.Path]::GetDirectoryName()`, porque `Split-Path -LiteralPath -Parent` é um conjunto de parâmetros ambíguo no PowerShell 5.1 e falha. Acrescentada também uma verificação pós-cópia (`if (-not (Test-Path -LiteralPath $destino)) { throw }`), para que uma cópia que não chega ao destino nunca mais seja contada como sucesso, qualquer que seja a causa futura.

Comprovação: duas execuções seguidas. A primeira copiou os 4 arquivos que faltavam, a segunda copiou zero (antes, copiava 5 indefinidamente). Auditados os 10 arquivos com colchete no nome que existem na pasta `_82`: todos os 10 conferem no Drive, com tamanho idêntico ao original.

Alternativas descartadas: escapar os colchetes com crase antes de passar para `-Path` (funciona, mas exige lembrar do escape em cada chamada nova, e o próximo caractere especial voltaria a quebrar); renomear os arquivos da captadora para remover colchete (mexe no dado dela para contornar limitação de ferramenta, e o padrão `[1]` aparece naturalmente em download de navegador).

Impacto: regra geral para qualquer script deste projeto que manipule arquivos reais da captadora, cujos nomes vêm de download e trazem colchete, acento, `°`, parênteses e espaço: **usar sempre `-LiteralPath`, nunca `-Path`**. Vale também para `Get-ChildItem`, `Test-Path`, `Remove-Item` e `Get-Content`. Como o `-Path` falha em silêncio, toda operação de cópia que precise ser confiável deve confirmar o resultado depois de executar, em vez de confiar na ausência de exceção.

Data: 2026-08-08

### SOL-0015. Sincronização da `_82` de hora em hora, e vigia com alerta, sem push automático de e-mail

Problema: depois de SOL-0013, a sincronização rodava uma vez por dia à 01h e as configurações da tarefa tinham `DisallowStartIfOnBatteries` e `StopIfGoingOnBatteries` ligados. Num laptop isso significa não rodar se a máquina não estiver na tomada à 01h. Os logs comprovaram o efeito: entre 27/07/2026 (criação da tarefa) e 01/08/2026 não houve nenhuma execução, seis dias sem backup. A captadora também pediu que, se a sincronização deixasse de acontecer, um relatório de alerta fosse gerado, enviado para gestao.mobilizando@gmail.com e sinalizado no chat.

Solução: a tarefa `AMC-IA-Sincronizar-Pasta82` passou a rodar **de hora em hora** (gatilho às 01h com repetição `PT1H`) mais um gatilho **ao fazer logon**, sem trava de bateria e com `StartWhenAvailable`. O `sincronizar-pasta-82.ps1` passou a gravar `estado.json` com o resultado de cada execução. Criado `verificar-sincronizacao.ps1` e a tarefa `AMC-IA-Vigia-Pasta82` (09h e ao logon), que lê esse estado e, se passar de 24h sem sincronizar ou a última execução tiver falhado, gera `ALERTA - SINCRONIZACAO PASTA 82.txt` na Área de Trabalho com o diagnóstico e o passo a passo de verificação, e mostra notificação do Windows. Quando a situação normaliza, o alerta é apagado sozinho.

Sobre o e-mail, limite real registrado para não ser reinvestigado: uma tarefa agendada do Windows só envia pela conta Gmail da captadora com uma senha de app, credencial que o assistente não cria nem manipula; e o conector Gmail disponível nesta sessão só expõe criação de rascunho, não envio. O `verificar-sincronizacao.ps1` já traz o bloco de envio pronto, lendo `SMTP_USUARIO`, `SMTP_SENHA_APP` e `ALERTA_DESTINO` de um `.env` em `C:\Users\rosep\Scripts\sincronizar-pasta-82\`, conforme a regra de segredos só no `.env`. Sem esse arquivo, o envio é pulado sem quebrar nada e o alerta continua funcionando pelos outros dois canais.

Alternativas descartadas: rodar a sincronização na nuvem para cobrir o laptop desligado (impossível, a origem dos dados é o disco da máquina, nenhum serviço lê um disco sem energia); trabalhar direto na unidade `G:` para a nuvem ficar sempre atual (elimina a cópia local, exige internet para abrir qualquer arquivo e contraria `.claude/rules/fonte-documentos-clientes.md`, que define a pasta local como fonte única de verdade documental).

Impacto: a janela de risco caiu de até 24h (na prática, já foram 6 dias) para no máximo 1 hora enquanto o laptop estiver ligado. Com o laptop desligado nada acontece, e não há como ser diferente, mas a sincronização dispara sozinha no logon seguinte. Ao abrir sessão, o assistente deve ler `estado.json` e sinalizar à captadora se a última sincronização falhou ou está parada há mais de 24h.

Data: 2026-08-08

### SOL-0016. Scripts versionados, dados das OSCs com backup, e o repositório é público

Problema: três lacunas apareceram ao revisar o que tinha sido feito. Primeira: os scripts de sincronização (SOL-0013 a SOL-0015) viviam só em `C:\Users\rosep\Scripts\sincronizar-pasta-82\`, fora de qualquer controle de versão. O repositório guardava a descrição do que eles faziam, mas não o código, então um problema no laptop levaria os dois embora. Segunda: `C:\amc-ia\minhas-oscs` (232 arquivos, 3,9 MB, com os perfis das 18 OSCs reais, 32 pareceres de elegibilidade, 10 propostas e 9 orçamentos) não tinha backup em lugar nenhum, por estar simultaneamente no `.gitignore` (protege dado de cliente), fora da pasta `_82` (que é o que vai para o Drive) e fora do histórico do git. Os documentos dos clientes já estavam cobertos pela `_82`; o que faltava era justamente o que o sistema produz. Terceira: verificado que `github.com/Gestao2026/amc-ia` é **público**, fato que não estava registrado em lugar nenhum e que muda o critério do que pode ser versionado.

Solução: os dois scripts passaram para `C:\amc-ia\scripts\sincronizar-pasta-82\`, com os valores específicos da máquina (caminho da pasta mãe, id da pasta compartilhada do Drive, pasta de dados de execução, limite de horas do vigia) isolados em `config.local.ps1`, que entrou no `.gitignore`; `config.exemplo.ps1` fica versionado como modelo. As duas tarefas agendadas foram reapontadas e testadas pelo próprio Agendador. As cópias antigas foram apagadas, para não existirem duas versões divergentes. O script ganhou a lista `$BackupPastas`: pastas de fora recebem cópia dentro da pasta mãe (`robocopy /MIR`, seguro porque o destino é gerenciado só por ele) antes do envio, herdando o backup no Drive sem tarefa nova. Os contadores de erro foram movidos para antes desse bloco, senão uma falha de backup seria zerada antes do resumo. Também foi ligado o despertar do laptop na bateria (`powercfg` `RTCWAKE` em CA e CC, mais `WakeToRun` na tarefa), a pedido da captadora, que preferiu cobertura total ao consumo de energia. O envio do alerta por e-mail foi recusado por ela: o bloco continua no `verificar-sincronizacao.ps1`, inativo, porque não existe `.env` com credencial SMTP, e os avisos seguem pelo arquivo na Área de Trabalho e pela notificação do Windows.

Limpeza feita na mesma rodada: a reorganização de pastas da captadora tinha deixado 186 arquivos no Drive em caminhos que já não existiam no computador (mover pasta, num modelo que nunca apaga, gera cópia no lugar antigo e no novo). Foi feita a conferência por hash SHA256 dos dois lados, 183 confirmados byte a byte idênticos a um arquivo da Área de Trabalho e apagados, e 3 preservados por existirem só na nuvem (os `.gdoc` do Google, que não têm cópia possível em disco). A sincronização rodada logo depois copiou zero, provando que arquivo apagado no Drive não volta a subir, porque o script só envia o que existe hoje na pasta mãe.

Alternativas descartadas: manter os scripts fora do repositório e apenas documentá-los (é o estado que gerou o problema); versionar `minhas-oscs` no git removendo a regra do `.gitignore` (publicaria dado real de cliente num repositório público); criar uma tarefa agendada separada só para o backup das OSCs (mais uma coisa para falhar em silêncio, quando a sincronização de hora em hora já resolve).

Impacto: nada mais depende de uma cópia única. Regra que passa a valer para este projeto: **o repositório é público, então nenhum caminho pessoal, id de pasta do Drive, credencial ou dado de cliente pode entrar em arquivo versionado**; valor específico de máquina vai para `config.local.ps1` ou `.env`, ambos no `.gitignore`. Consequência do modelo que nunca apaga, e que vai se repetir: toda vez que a captadora mover ou renomear uma pasta grande, o Drive fica com o conteúdo no caminho antigo e no novo. Não é erro nem risco, mas acumula, e a limpeza correta é sempre a deste registro: conferir por hash antes de apagar, e nunca apagar o que só existe na nuvem.

Data: 2026-08-09

### SOL-0017. Push automático das 02h COM guarda de conteúdo (substitui SOL-0012)

> Esta entrada reverte a decisão do SOL-0012 ("push sempre manual"). A preocupação daquele registro continua válida e o que mudou foi existir agora uma checagem de conteúdo, que era exatamente o que faltava.

Problema: a captadora pediu push automático de madrugada, com a condição, formulada por ela, de que "aquilo que for suspeito e perigoso para o nosso trabalho você não sobe e gera um relatório", mais um retorno diário do que precisou de ação automática, dizendo se deu certo ou não e, em caso negativo, o motivo. O pedido colide de frente com o SOL-0012, cujo argumento era que a checagem existente só pega quebra de sintaxe, nunca conteúdo, e por isso o push precisava de um humano olhando antes. Agravante descoberto no mesmo dia (SOL-0016): o repositório é público, então um arquivo que escape do `.gitignore` vira conteúdo indexável na internet, e apagar depois não desfaz cache.

Solução: criado `scripts/push-diario-seguro.ps1` e a tarefa `AMC-IA-Push-Diario` (02h, desperta o computador, roda na bateria). O script nunca publica às cegas: varre `git diff origin/main..HEAD` antes de qualquer envio e bloqueia se encontrar token JWT, chave da OpenAI, token do GitHub, chave da AWS, token do Telegram, atribuição de senha ou token no código, CPF, CNPJ, identificador de pasta do Google Drive, conta bancária, e-mail de terceiro (só `gestao.mobilizando@gmail.com` e `noreply@anthropic.com` são permitidos), arquivo protegido (`.env`, `config.local`, `.key`, `.pem`) ou qualquer arquivo real sob `minhas-oscs/` que não seja o exemplo fictício ou o modelo. Bloqueando, nada é publicado, o motivo vai para o relatório e um alerta aparece na Área de Trabalho, que some sozinho quando a situação normaliza. O relatório diário (`logs/push-diario/relatorio-AAAA-MM-DD.txt`, fora do controle de versão) cobre as três frentes: publicação, sincronização da `_82` e estado das quatro tarefas agendadas. O script tem `-Autoteste`, que exercita o detector contra amostras conhecidas sem publicar nada, e `-SoVerificar`, que varre e relata sem enviar.

Dois defeitos reais encontrados durante o próprio teste, e corrigidos:
1. **O detector bloqueou o commit que o criava.** As amostras do autoteste continham um CPF, um CNPJ, um token e um id de pasta do Drive escritos por extenso, e o detector, corretamente, os encontrou no `diff`. Pior: a primeira versão usou como exemplo o **id real** da pasta compartilhada do Drive e o **CNPJ real** de uma OSC da carteira, que teriam ido para um repositório público. As amostras passaram a ser montadas por concatenação em tempo de execução, para que os padrões não existam literalmente no arquivo. O episódio é a melhor evidência de que a guarda funciona, e o commit foi corrigido antes de qualquer publicação.
2. **Alarme falso no relatório.** O Agendador do Windows devolve `267011` para tarefa que ainda não rodou e `267009` para tarefa em execução; tratados como falha, faziam o relatório acusar erro todo dia numa tarefa recém-criada. Passaram a ser reportados pelo que são.

Alternativas descartadas: manter o push manual como no SOL-0012 (a captadora reafirmou o pedido depois de eu apresentar o risco, e a decisão é dela); automatizar o push sem varredura (é exatamente o que o SOL-0012 recusava, e o repositório ser público piora); tornar o repositório privado para poder automatizar sem guarda (não foi pedido, e a guarda é útil de qualquer forma, porque protege contra o erro humano de commitar dado de cliente sem perceber).

Impacto: `commit` e `push` deixam de ter níveis de automação diferentes, mas o push passa a ter uma condição que o commit não tem. Regra que fica valendo: **nenhuma automação deste projeto pode chamar `git push` direto**; toda publicação passa por `push-diario-seguro.ps1`. Se o detector bloquear, o correto é revisar o achado com a captadora, nunca liberar por parecer alarme falso. Ao abrir sessão, o assistente deve ler o relatório mais recente em `logs/push-diario/` e avisar se houve bloqueio ou falha, junto com a checagem de `estado.json` que o SOL-0015 já pedia.

**Complemento do mesmo dia, a pedido da captadora.** Ela pediu que o commit continue acontecendo logo depois de cada alteração feita em conversa (como já era a prática), e que também tenha vigia, mantendo o push das 02h com a guarda. Duas mudanças: (1) o commit diário automático saiu das 06h para 01h30, para que o push das 02h venha sempre depois dele, e não publique o estado da véspera; ele permanece só como rede de segurança, para alteração feita fora das conversas. (2) Criado o hook `post-commit` em `.githooks/` (ativado com `git config core.hooksPath .githooks`, por isso versionado em vez de ficar em `.git/hooks`), que roda `push-diario-seguro.ps1 -PosCommit` a cada commit: a mesma varredura de conteúdo, mas sem gerar relatório nem alerta, para não poluir a Área de Trabalho durante o trabalho normal. O hook **não bloqueia nem desfaz o commit**, apenas avisa na hora, o que é deliberado: o Git ignora o código de saída do `post-commit`, e o objetivo é a pessoa descobrir o problema no momento em que ele foi criado, e não às 02h. Também foi ampliado o alerta do relatório diário: antes só aparecia em caso de publicação bloqueada, agora cobre qualquer pendência que exija ação (tarefa agendada que falhou, `_82` parada há mais de 24h ou com erro, publicação bloqueada ou falha, alteração que ficou sem ser salva), no mesmo modelo do vigia da `_82`, sumindo sozinho quando normaliza. Motivo declarado por ela: "daí que fico pedindo coisas manuais, pois tem grande chance de esquecer".

Testado ao vivo: commit limpo passa e o vigia informa quantas alterações estão prontas; commit com CPF e e-mail de terceiro é detectado e avisado na hora. O teste do caso ruim foi feito num ramo descartável (`teste-vigia`, apagado em seguida), para não deixar resíduo no histórico da `main`.

Data: 2026-08-09

### SOL-0018. Sincronização da pasta _82 passa a refletir também modificação e exclusão, não só inclusão

Problema: desde o SOL-0013, `sincronizar-pasta-82.ps1` só copiava para o Drive o que era novo ou tinha tamanho diferente, e nunca apagava nada em nenhum dos dois lados, por decisão deliberada (proteger os arquivos nativos do Google, que só existem na nuvem). A captadora apagou uma pasta de teste na Área de Trabalho e viu que ela continuava no Drive, e considerou que isso quebra a expectativa básica de "sincronização": pediu que qualquer alteração feita na Área de Trabalho (incluir, modificar ou apagar) se refletisse no Drive, senão o processo não faz sentido para ela.

Solução: o script passou a gravar, a cada execução, um manifesto (`manifesto-desktop.json`, em `$DadosDir`) com os caminhos relativos de tudo que existia na Área de Trabalho naquela execução. Na execução seguinte, um arquivo que estava no manifesto anterior e não existe mais no Desktop é apagado também no Drive; pastas que ficam vazias no Drive por causa disso são removidas em cascata (ignorando o `desktop.ini` que o próprio Google Drive cria sozinho dentro de pastas, senão elas nunca pareceriam vazias). Arquivo que nunca esteve na Área de Trabalho (nativo do Google, ou qualquer coisa colocada direto na nuvem) nunca entra no manifesto e por isso nunca é tocado, preservando a proteção original do SOL-0013. Como o manifesto não existe na primeira execução após a mudança, essa primeira rodada só cria a base, sem apagar nada; a pasta de teste que já tinha ficado órfã no Drive precisou ser removida manualmente uma vez.

Foi acrescentado um circuito de segurança contra exclusão em massa: se mais de 30% dos arquivos do manifesto anterior (e mais de 15 arquivos) somem de uma vez, o script não apaga nada no Drive nessa execução, só gera um alerta (`ALERTA - EXCLUSAO EM MASSA NA PASTA 82.txt`, mesmo padrão do alerta do SOL-0015) explicando a situação e pedindo confirmação. Isso protege contra o cenário mais perigoso: um problema de leitura da pasta (permissão, antivírus, unidade temporariamente desconectada no meio da varredura) fazer parecer que quase tudo sumiu, e o script apagar isso tudo no Drive por engano.

Bug real encontrado e corrigido durante a implementação: a primeira versão também comparava a data de modificação do arquivo (além do tamanho) para detectar edição, pensando em cobrir o caso raro de um arquivo editado que mantém o mesmo tamanho. Um teste ao vivo (10/08/2026) mostrou que isso gerava 621 falsos positivos numa única execução, porque milhares de arquivos antigos têm datas de modificação diferentes nos dois lados mesmo com conteúdo idêntico (chegaram em cada lado em momentos diferentes da história da pasta, antes desta automação existir). Revertido para comparar só o tamanho, como já era feito desde o SOL-0013, critério mais simples e sem esse efeito colateral. Nenhum dado foi perdido nesse episódio (o conteúdo já era idêntico, só recopiou à toa).

Testado ao vivo (10/08/2026) com arquivos descartáveis dentro da própria pasta real: inclusão, exclusão de arquivo, exclusão de pasta inteira (incluindo o `desktop.ini` residual do Drive) e o cenário de reversão da falsa comparação por data, todos com o resultado esperado.

Alternativas descartadas: manter a regra antiga de nunca apagar (era o pedido explícito da captadora ir na direção contrária); apagar sem nenhum controle de proporção (arriscado demais dado o cenário de leitura parcial da pasta); usar hash de conteúdo em vez de tamanho para detectar edição (mais correto, mas caro demais para rodar de hora em hora numa pasta com milhares de arquivos, e o ganho de precisão não compensa o custo).

Impacto: a sincronização da `_82` agora é, na prática, um espelho de mão única completo (inclusão, modificação e exclusão), com duas redes de segurança: o manifesto (nunca apaga o que só existe na nuvem) e o circuito de exclusão em massa (nunca apaga tudo de uma vez sem confirmação). `estado.json` ganhou o campo `apagados_no_drive`. Documentos apagados no Drive por este processo normalmente vão para a Lixeira do Drive antes de sumir de vez, o que dá uma margem extra de recuperação.

Data: 2026-08-10
