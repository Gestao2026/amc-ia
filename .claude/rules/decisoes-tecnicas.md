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
